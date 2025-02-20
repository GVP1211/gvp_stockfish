import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'stockfish_bindings_generated.dart';

part 'callbacks.dart';
part 'handlers.dart';
part 'library.dart';

class GvpStockfish {
  static GvpStockfish? _instance = null;

  GvpStockfish._() {
    _onIterCallable =
        NativeCallable<on_iter_callbackFunction>.listener(_onIter);
    _onUpdateNoMovesCallable =
        NativeCallable<on_update_no_moves_callbackFunction>.listener(
            _onUpdateNoMoves);
    _onUpdateFullCallable =
        NativeCallable<on_update_full_callbackFunction>.listener(_onUpdateFull);
    _onBestMoveCallable =
        NativeCallable<on_bestmove_callbackFunction>.listener(_onBestMove);
    _onPrintInfoStringCallable =
        NativeCallable<on_print_info_string_callbackFunction>.listener(
            _onPrintInfoString);
  }

  static get instance {
    return _instance ??= GvpStockfish._();
  }

  late NativeCallable<on_iter_callbackFunction> _onIterCallable;
  late NativeCallable<on_update_no_moves_callbackFunction>
      _onUpdateNoMovesCallable;
  late NativeCallable<on_update_full_callbackFunction> _onUpdateFullCallable;
  late NativeCallable<on_bestmove_callbackFunction> _onBestMoveCallable;
  late NativeCallable<on_print_info_string_callbackFunction>
      _onPrintInfoStringCallable;

  late StreamController<InfoBase> _streamController;

  dispose() {
    _streamController.close();
  }

  Stream<InfoBase> get stream => _streamController.stream;

  Future<void> init() async {
    _streamController = StreamController<InfoBase>.broadcast();
    await _invoke(_Init());
    await _invoke(
      _New(
        onIter: _onIterCallable.nativeFunction,
        onUpdateFull: _onUpdateFullCallable.nativeFunction,
        onBestMove: _onBestMoveCallable.nativeFunction,
        onUpdateNoMoves: _onUpdateNoMovesCallable.nativeFunction,
        onPrintInfoString: _onPrintInfoStringCallable.nativeFunction,
      ),
    );
  }

  Future<void> delete() async {
    await _invoke(_Delete());
  }

  Future<String> uci() async {
    return ((await _invoke(_Uci())) as _UciResponse).result;
  }

  Future<void> setoption(String option) async {
    await _invoke(_SetOption(option));
  }

  Future<void> position(String token) async {
    await _invoke(_Position(token));
  }

  Future<void> ucinewgame() async {
    await _invoke(_Ucinewgame());
  }

  Future<String> go(String limits) async {
    return ((await _invoke(_Go(limits))) as _GoResponse).result;
  }

  Future<void> stop() async {
    await _invoke(_Stop());
  }

  Future<void> ponderhit() async {
    await _invoke(_Ponderhit());
  }

  void _onIter(int depth, Pointer<Char> currmove, int currmovenumber) {
    var info = InfoIter(
      depth: depth,
      currmove: currmove.cast<Utf8>().toDartString(),
      currmovenumber: currmovenumber,
    );
    calloc.free(currmove);
    _streamController.add(info);
  }

  void _onUpdateNoMoves(int depth, Pointer<Char> score) {
    var info = InfoNoMoves(
      depth: depth,
      score: score.cast<Utf8>().toDartString(),
    );
    calloc.free(score);
    _streamController.add(info);
  }

  void _onUpdateFull(
    int depth,
    Pointer<Char> score,
    int selDepth,
    int multiPV,
    Pointer<Char> wdl,
    Pointer<Char> bound,
    int timeMs,
    int nodes,
    int nps,
    int tbHits,
    Pointer<Char> pv,
    int hashfull,
  ) {
    var info = InfoFull(
      depth: depth,
      score: score.cast<Utf8>().toDartString(),
      selDepth: selDepth,
      multiPV: multiPV,
      wdl: wdl.cast<Utf8>().toDartString(),
      bound: bound.cast<Utf8>().toDartString(),
      timeMs: timeMs,
      nodes: nodes,
      nps: nps,
      tbHits: tbHits,
      pv: pv.cast<Utf8>().toDartString(),
      hashfull: hashfull,
    );
    calloc.free(score);
    calloc.free(wdl);
    calloc.free(bound);
    calloc.free(pv);
    _streamController.add(info);
  }

  void _onBestMove(Pointer<Char> bestMove, Pointer<Char> ponder) {
    var info = InfoBestMove(
      bestMove: bestMove.cast<Utf8>().toDartString(),
      ponder: ponder.cast<Utf8>().toDartString(),
    );
    calloc.free(bestMove);
    calloc.free(ponder);
    _streamController.add(info);
  }

  void _onPrintInfoString(Pointer<Char> print) {
    var info = InfoPrintInfoString(
      info: print.cast<Utf8>().toDartString(),
    );
    calloc.free(print);
    _streamController.add(info);
  }
}
