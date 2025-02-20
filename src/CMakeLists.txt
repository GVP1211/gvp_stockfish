# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(gvp_stockfish VERSION 1.0.0 LANGUAGES C CXX)

file(GLOB_RECURSE STOCKFISH_SOURCES "../darwin/Stockfish/src/*.cpp")

add_library(gvp_stockfish SHARED
  "stockfish.cpp"
  ${STOCKFISH_SOURCES}
)

include_directories(../darwin/Stockfish/src/)

set_target_properties(gvp_stockfish PROPERTIES
  PUBLIC_HEADER stockfish.h
  OUTPUT_NAME "gvp_stockfish"
  LINKER_LANGUAGE CXX
)

target_compile_definitions(gvp_stockfish PUBLIC DART_SHARED_LIB)

file(DOWNLOAD https://tests.stockfishchess.org/api/nn/nn-1c0000000000.nnue ${CMAKE_BINARY_DIR}/nn-1c0000000000.nnue)
file(DOWNLOAD https://tests.stockfishchess.org/api/nn/nn-37f18f62d772.nnue ${CMAKE_BINARY_DIR}/nn-37f18f62d772.nnue)

if(ANDROID_ABI STREQUAL arm64-v8a)
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(gvp_stockfish PRIVATE -DDEBUG -DUSE_PTHREADS -DIS_64BIT -DUSE_POPCNT -DUSE_NEON=8)
  else()
    target_compile_options(gvp_stockfish PRIVATE -DNDEBUG -O3 -fno-exceptions -funroll-loops -DUSE_PTHREADS -DIS_64BIT -DUSE_POPCNT -DUSE_NEON=8)
  endif()
else()
  if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(gvp_stockfish PRIVATE -DDEBUG -DUSE_PTHREADS)
  else()
    target_compile_options(gvp_stockfish PRIVATE -DNDEBUG -O3 -fno-exceptions -DUSE_PTHREADS)
  endif()
endif()
