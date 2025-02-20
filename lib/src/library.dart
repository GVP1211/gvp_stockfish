part of 'gvp_stockfish.dart';

const String _libName = 'gvp_stockfish';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final StockfishBindings _bindings = StockfishBindings(_dylib);

class _RequestBase {
  static int _nextMainRequestId = 0;
  late int id;

  _RequestBase() {
    id = _nextMainRequestId++;
  }
}

class _ResponseBase {
  final int id;

  const _ResponseBase(this.id);
}

void _mainLoop(SendPort sendPort) async {
  final ReceivePort helperReceivePort = ReceivePort();

  // Send the port to the main isolate on which we can receive requests.
  sendPort.send(helperReceivePort.sendPort);

  helperReceivePort.listen((dynamic request) {
    // On the helper isolate listen to requests and respond to them.
    Function? handler = _commands[request.runtimeType];
    if (handler != null) {
      _ResponseBase response = handler(request);
      sendPort.send(response);
    } else {
      throw UnsupportedError(
          'Unsupported message type: ${request.runtimeType}');
    }
  });
}

final _getIsolateSendPort = () {
  SendPort? sendPort;

  return () async {
    sendPort ??= await _createHelperIsolateSendPort();
    return sendPort!;
  };
}();

final Map<int, Completer<_ResponseBase>> _requests =
    <int, Completer<_ResponseBase>>{};

Future<_ResponseBase> _invoke(_RequestBase request) async {
  final SendPort sendPort = await _getIsolateSendPort();

  final Completer<_ResponseBase> completer = Completer<_ResponseBase>();
  _requests[request.id] = completer;
  sendPort.send(request);
  return completer.future;
}

/// The SendPort belonging to the helper isolate.
Future<SendPort> _createHelperIsolateSendPort() async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is _ResponseBase) {
        // The helper isolate sent us a response to a request we sent.
        final Completer<_ResponseBase> request = _requests[data.id]!;
        _requests.remove(data.id);
        request.complete(data);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn(_mainLoop, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}
