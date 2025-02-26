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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

typedef void (*on_iter_callback)(int, const char*, size_t);
typedef void (*on_update_no_moves_callback)(int, const char*);
typedef void (*on_update_full_callback)(
    int depth,
    const char* score,
    int selDepth,
    size_t multiPV,
    const char *wdl,
    const char *bound,
    size_t timeMs,
    size_t nodes,
    size_t nps,
    size_t tbHits,
    const char *pv,
    int hashfull
);
typedef void (*on_bestmove_callback)(const char*, const char*);
typedef void (*on_print_info_string_callback)(const char*);

#ifdef __cplusplus
extern "C" {
#endif

FFI_PLUGIN_EXPORT void stockfish_init(void);
FFI_PLUGIN_EXPORT void stockfish_new(
    on_iter_callback on_iter,
    on_update_no_moves_callback on_update_no_moves,
    on_update_full_callback on_update_full,
    on_bestmove_callback on_bestmove,
    on_print_info_string_callback on_print_info_string
);
FFI_PLUGIN_EXPORT void stockfish_delete(void);
FFI_PLUGIN_EXPORT char *stockfish_uci(void);
FFI_PLUGIN_EXPORT void stockfish_setoption(const char* option);
FFI_PLUGIN_EXPORT void stockfish_position(const char* token);
FFI_PLUGIN_EXPORT void stockfish_ucinewgame(void);
FFI_PLUGIN_EXPORT char *stockfish_go(const char* limits);
FFI_PLUGIN_EXPORT void stockfish_stop(void);
FFI_PLUGIN_EXPORT void stockfish_ponderhit(void);

#ifdef __cplusplus
}
#endif
