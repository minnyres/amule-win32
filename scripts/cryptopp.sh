#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET

cd src
mkdir cryptopp
cd cryptopp
7z x ../cryptopp860.zip
CXX=$TARGET-g++ RANLIB=$TARGET-ranlib AR=$TARGET-ar LDLIBS=-lws2_32 make -f GNUmakefile -j$(nproc)
PREFIX=$BUILDDIR/cryptopp make -f GNUmakefile install
cd ..
rm -rf cryptopp