#!/usr/bin/bash

set -e

git clone https://github.com/mstorsjo/llvm-mingw.git
cd llvm-mingw
sed  -i "s/DEFAULT_MSVCRT:=ucrt/DEFAULT_MSVCRT:=msvcrt/"  build-mingw-w64.sh

./build-all.sh ../toolchain/clang
./strip-llvm.sh ../toolchain/clang

cd ..
rm -rf llvm-mingw