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

abstract class InfoBase {}

class InfoIter implements InfoBase {
  final int depth;
  final String currmove;
  final int currmovenumber;

  InfoIter._({
    required this.depth,
    required this.currmove,
    required this.currmovenumber,
  });

  factory InfoIter({
    required int depth,
    required String currmove,
    required int currmovenumber,
  }) {
    return InfoIter._(
      depth: depth,
      currmove: currmove,
      currmovenumber: currmovenumber,
    );
  }
}

class InfoNoMoves implements InfoBase {
  final int depth;
  final String score;

  InfoNoMoves._({required this.depth, required this.score});

  factory InfoNoMoves({required int depth, required String score}) {
    return InfoNoMoves._(depth: depth, score: score);
  }
}

class InfoFull implements InfoBase {
  final int depth;
  final String score;
  final int selDepth;
  final int multiPV;
  final String wdl;
  final String bound;
  final int timeMs;
  final int nodes;
  final int nps;
  final int tbHits;
  final String pv;
  final int hashfull;

  InfoFull._({
    required this.depth,
    required this.score,
    required this.selDepth,
    required this.multiPV,
    required this.wdl,
    required this.bound,
    required this.timeMs,
    required this.nodes,
    required this.nps,
    required this.tbHits,
    required this.pv,
    required this.hashfull,
  });

  factory InfoFull({
    required int depth,
    required String score,
    required int selDepth,
    required int multiPV,
    required String wdl,
    required String bound,
    required int timeMs,
    required int nodes,
    required int nps,
    required int tbHits,
    required String pv,
    required int hashfull,
  }) {
    return InfoFull._(
      depth: depth,
      score: score,
      selDepth: selDepth,
      multiPV: multiPV,
      wdl: wdl,
      bound: bound,
      timeMs: timeMs,
      nodes: nodes,
      nps: nps,
      tbHits: tbHits,
      pv: pv,
      hashfull: hashfull,
    );
  }
}

class InfoBestMove implements InfoBase {
  final String bestMove;
  final String ponder;

  InfoBestMove._({required this.bestMove, required this.ponder});

  factory InfoBestMove({required String bestMove, required String ponder}) {
    return InfoBestMove._(bestMove: bestMove, ponder: ponder);
  }
}

class InfoPrintInfoString implements InfoBase {
  final String info;

  InfoPrintInfoString._({required this.info});

  factory InfoPrintInfoString({required String info}) {
    return InfoPrintInfoString._(info: info);
  }
}
