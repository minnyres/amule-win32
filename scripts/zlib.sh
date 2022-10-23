#!/bin/bash

set -e

cd src/zlib-1.2.13
mkdir -p build-$TARGET
cd build-$TARGET
CC=$TARGET-gcc AR=$TARGET-ar RANLIB=$TARGET-ranlib ../configure --prefix=$BUILDDIR/zlib --static
make -j$(nproc)
make install
make clean
