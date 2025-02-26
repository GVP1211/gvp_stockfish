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

#include "stockfish.h"

#include <string.h>

#include "bitboard.h"
#include "engine.h"
#include "misc.h"
#include "position.h"
#include "search.h"
#include "tune.h"
#include "uci.h"

using namespace Stockfish;

Stockfish::Engine *engine = NULL;

on_iter_callback on_iter = NULL;
on_update_no_moves_callback on_update_no_moves = NULL;
on_update_full_callback on_update_full = NULL;
on_bestmove_callback on_bestmove = NULL;
on_print_info_string_callback on_print_info_string = NULL;

void engine_on_iter(const Engine::InfoIter& info)
{
    if (on_iter == NULL)
        return;
    on_iter(info.depth, strdup(std::string(info.currmove).c_str()), info.currmovenumber);
}

void engine_on_update_no_moves(const Engine::InfoShort& info)
{
    if (on_update_no_moves == NULL)
        return;
    std::string score = UCIEngine::format_score(info.score);
    on_update_no_moves(info.depth, strdup(score.c_str()));
}

void engine_on_update_full(const Engine::InfoFull& info)
{
    if (on_update_full == NULL)
        return;
    std::string score = UCIEngine::format_score(info.score);
    on_update_full(
        info.depth,
        strdup(score.c_str()),
        info.selDepth,
        info.multiPV,
        strdup(std::string(info.wdl).c_str()),
        strdup(std::string(info.bound).c_str()),
        info.timeMs,
        info.nodes,
        info.nps,
        info.tbHits,
        strdup(std::string(info.pv).c_str()),
        info.hashfull
    );
}

void engine_on_bestmove(std::string_view bestmove, std::string_view ponder)
{
    if (on_bestmove == NULL)
        return;
    on_bestmove(strdup(std::string(bestmove).c_str()), strdup(std::string(ponder).c_str()));
}

void engine_print_info_string(std::string_view str)
{
    if (on_print_info_string == NULL)
        return;
    on_print_info_string(strdup(std::string(str).c_str()));
}

static void init_update_listeners()
{
    engine->set_on_iter(engine_on_iter);
    engine->set_on_update_no_moves(engine_on_update_no_moves);
    engine->set_on_update_full(engine_on_update_full);
    engine->set_on_bestmove(engine_on_bestmove);
    engine->set_on_verify_networks(engine_print_info_string);
}

FFI_PLUGIN_EXPORT void stockfish_init(void)
{
    Bitboards::init();
    Position::init();
}

FFI_PLUGIN_EXPORT void stockfish_new(
    on_iter_callback on_iter_cb,
    on_update_no_moves_callback on_update_no_moves_cb,
    on_update_full_callback on_update_full_cb,
    on_bestmove_callback on_bestmove_cb,
    on_print_info_string_callback on_print_info_string_cb)
{
    engine = new Engine();
    // std::istringstream is("name EvalFile value None");
    // engine->get_options().setoption(is);
    // is = std::istringstream("name EvalFileSmall value None");
    // engine->get_options().setoption(is);
    Tune::init(engine->get_options());

    on_iter = on_iter_cb;
    on_update_no_moves = on_update_no_moves_cb;
    on_update_full = on_update_full_cb;
    on_bestmove = on_bestmove_cb;
    on_print_info_string = on_print_info_string_cb;
    init_update_listeners();
}

FFI_PLUGIN_EXPORT void stockfish_delete(void)
{
    delete engine;
}

FFI_PLUGIN_EXPORT char* stockfish_uci(void)
{
    std::stringstream ss;
    ss << "id name " << engine_info(true) << "\n" << engine->get_options();
    return strdup(ss.str().c_str());
}

FFI_PLUGIN_EXPORT void stockfish_setoption(const char* option)
{
    std::istringstream is(option);
    engine->wait_for_search_finished();
    engine->get_options().setoption(is);
}

constexpr auto StartFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

FFI_PLUGIN_EXPORT void stockfish_position(const char* ptoken)
{
    std::stringstream is(ptoken);
    std::string token;
    std::string fen;

    is >> token;

    if (token == "startpos")
    {
        fen = StartFEN;
        is >> token;  // Consume the "moves" token, if any
    }
    else if (token == "fen")
        while (is >> token && token != "moves")
            fen += token + " ";
    else
        return;

    std::vector<std::string> moves;

    while (is >> token)
    {
        moves.push_back(token);
    }

    engine->set_position(fen, moves);
}

FFI_PLUGIN_EXPORT void stockfish_ucinewgame(void)
{
    engine->search_clear();
}

FFI_PLUGIN_EXPORT char *stockfish_go(const char* plimits)
{
    std::stringstream is(plimits);

    Search::LimitsType limits = UCIEngine::parse_limits(is);

    if (limits.perft) {
        std::stringstream ss;
        auto nodes = engine->perft(engine->fen(), limits.perft, engine->get_options()["UCI_Chess960"]);
        ss << "\nNodes searched: " << nodes << "\n";
        return strdup(ss.str().c_str());
    } else {
        engine->go(limits);

    }

    return NULL;
}

FFI_PLUGIN_EXPORT void stockfish_stop(void)
{
    engine->stop();
}

FFI_PLUGIN_EXPORT void stockfish_ponderhit(void)
{
    engine->set_ponderhit(false);
}
