#!/bin/bash

set -e

cd src/zlib
CC=$TARGET-gcc AR=$TARGET-ar RANLIB=$TARGET-ranlib ./configure --prefix=$BUILDDIR/zlib --static
make -j$(nproc)
make install
make clean
git restore .
git clean -f
