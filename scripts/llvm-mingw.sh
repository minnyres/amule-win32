#!/bin/bash

set -e

help_msg="Usage: ./scripts/llvm-mingw.sh -crt=[ucrt|msvcrt]"

if [ $# == 1 ]; then
    if [ $1 == "-crt=ucrt" ]; then
        CRT=ucrt
    elif [ $1 == "-crt=msvcrt" ]; then
        CRT=msvcrt
    else
        echo $help_msg
        exit -1
    fi
else
    echo $help_msg
    exit -1
fi

git clone --depth 1 --branch 20220323 https://github.com/mstorsjo/llvm-mingw.git
cd llvm-mingw

sed -i "s/DEFAULT_MSVCRT:=ucrt/DEFAULT_MSVCRT:=$CRT/" build-mingw-w64.sh

./build-all.sh ../toolchain/clang
./strip-llvm.sh ../toolchain/clang

cd ..
rm -rf llvm-mingw
