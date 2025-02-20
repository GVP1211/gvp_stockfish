# Stockfish for Flutter
# Usage
```dart
import 'package:gvp_stockfish/gvp_stockfish.dart' as sf;

main() async {
  final gvp = sf.GvpStockfish.instance;
  await gvp.init();
  await gvp.setoption("name Threads value 4");

  String info = await gvp.uci();
  print('uci: $info');

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
        print('full: depth ${full.depth} seldepth ${full.selDepth} multipv ${full.multiPV} score ${full.score} wdl ${full.wdl} nodes ${full.nodes} nps ${full.nps} hashfull ${full.hashfull} tbhits ${full.tbHits} time ${full.timeMs} pv ${full.pv}');
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
  await gvp.go('depth 10');
}
```
