#!/usr/bin/bash

set -e

cd llvm-mingw

sed  -i "s/DEFAULT_MSVCRT:=ucrt/DEFAULT_MSVCRT:=msvcrt/"  build-mingw-w64.sh

./build-all.sh ../toolchain/clang

git restore .