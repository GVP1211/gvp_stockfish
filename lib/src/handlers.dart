/*
MIT License

Copyright (c) 2025 Virunpat Puengrostham

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

part of 'gvp_stockfish.dart';

final Map<Type, Function> _commands = {
  _Init: _init,
  _New: _new,
  _Delete: _delete,
  _Uci: _uci,
  _SetOption: _setoption,
  _Position: _position,
  _Ucinewgame: _ucinewgame,
  _Go: _go,
  _Stop: _stop,
  _Ponderhit: _ponderhit,
};

class _Init extends _RequestBase {}

class _InitResponse extends _ResponseBase {
  _InitResponse(super.id);
}

_InitResponse _init(_Init request) {
  _bindings.stockfish_init();
  return _InitResponse(request.id);
}

class _New extends _RequestBase {
  Pointer<NativeFunction<on_iter_callbackFunction>> onIter;
  Pointer<NativeFunction<on_update_no_moves_callbackFunction>> onUpdateNoMoves;
  Pointer<NativeFunction<on_update_full_callbackFunction>> onUpdateFull;
  Pointer<NativeFunction<on_bestmove_callbackFunction>> onBestMove;
  Pointer<NativeFunction<on_print_info_string_callbackFunction>>
  onPrintInfoString;

  _New({
    required this.onIter,
    required this.onUpdateNoMoves,
    required this.onUpdateFull,
    required this.onBestMove,
    required this.onPrintInfoString,
  });
}

class _NewResponse extends _ResponseBase {
  _NewResponse(super.id);
}

_NewResponse _new(_New request) {
  _bindings.stockfish_new(
    request.onIter,
    request.onUpdateNoMoves,
    request.onUpdateFull,
    request.onBestMove,
    request.onPrintInfoString,
  );
  return _NewResponse(request.id);
}

class _Delete extends _RequestBase {}

class _DeleteResponse extends _ResponseBase {
  _DeleteResponse(super.id);
}

_DeleteResponse _delete(_Delete request) {
  _bindings.stockfish_delete();
  return _DeleteResponse(request.id);
}

class _Stop extends _RequestBase {}

class _StopResponse extends _ResponseBase {
  _StopResponse(super.id);
}

_StopResponse _stop(_Stop request) {
  _bindings.stockfish_stop();
  return _StopResponse(request.id);
}

class _Uci extends _RequestBase {}

class _UciResponse extends _ResponseBase {
  final String result;

  const _UciResponse(super.id, this.result);
}

_UciResponse _uci(_Uci request) {
  final pointer = _bindings.stockfish_uci();
  if (pointer != nullptr) {
    final info = pointer.cast<Utf8>().toDartString();
    calloc.free(pointer);
    return _UciResponse(request.id, info);
  }
  return _UciResponse(request.id, '');
}

class _SetOption extends _RequestBase {
  final String option;

  _SetOption(this.option);
}

class _SetOptionResponse extends _ResponseBase {
  _SetOptionResponse(super.id);
}

_SetOptionResponse _setoption(_SetOption request) {
  _bindings.stockfish_setoption(request.option.toNativeUtf8().cast());
  return _SetOptionResponse(request.id);
}

class _Position extends _RequestBase {
  final String token;

  _Position(this.token);
}

class _PositionResponse extends _ResponseBase {
  _PositionResponse(super.id);
}

_PositionResponse _position(_Position request) {
  _bindings.stockfish_position(request.token.toNativeUtf8().cast());
  return _PositionResponse(request.id);
}

class _Ucinewgame extends _RequestBase {}

class _UcinewgameResponse extends _ResponseBase {
  _UcinewgameResponse(super.id);
}

_UcinewgameResponse _ucinewgame(_Ucinewgame request) {
  _bindings.stockfish_ucinewgame();
  return _UcinewgameResponse(request.id);
}

class _Go extends _RequestBase {
  final String limits;

  _Go(this.limits);
}

class _GoResponse extends _ResponseBase {
  final String result;

  _GoResponse(super.id, this.result);
}

_GoResponse _go(_Go request) {
  final pointer = _bindings.stockfish_go(request.limits.toNativeUtf8().cast());
  if (pointer != nullptr) {
    final info = pointer.cast<Utf8>().toDartString();
    calloc.free(pointer);
    return _GoResponse(request.id, info);
  }
  return _GoResponse(request.id, '');
}

class _Ponderhit extends _RequestBase {
  _Ponderhit();
}

class _PonderhitResponse extends _ResponseBase {
  _PonderhitResponse(super.id);
}

_PonderhitResponse _ponderhit(_Ponderhit request) {
  _bindings.stockfish_ponderhit();
  return _PonderhitResponse(request.id);
}
