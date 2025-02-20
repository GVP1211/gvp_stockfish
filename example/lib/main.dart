import 'package:gvp_stockfish/gvp_stockfish.dart' as sf;

main() async {
  final gvp = sf.GvpStockfish.instance;
  await gvp.init();

  String result = await gvp.uci();
  print('uci: $result');

  var stream = gvp.stream;
  stream.listen((event) {
    switch (event) {
      case sf.InfoIter iter:
        print('iter ${iter.depth} ${iter.currmove} ${iter.currmovenumber}');
        break;
      case sf.InfoNoMoves noMoves:
        print('noMoves ${noMoves.depth} ${noMoves.score}');
        break;
      case sf.InfoFull full:
        print('full ${full.bound} ${full.selDepth} ${full.nodes} ${full.pv}');
        break;
      case sf.InfoBestMove bestMove:
        print('bestmove ${bestMove.bestMove} ${bestMove.ponder}');
        break;
      case sf.InfoPrintInfoString printInfoString:
        print('printinfo ${printInfoString.info}');
        break;
    }
  });

  await gvp.ucinewgame();
  await gvp.position('startpos');
  await gvp.go('depth 4');
}
