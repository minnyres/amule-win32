#!/bin/bash

set -e

export CXXFLAGS="-g0 -Os"
export CFLAGS="-g0 -Os"
export LDFLAGS="-s"

cd src/geoip-api-c
./bootstrap
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/geoip --enable-shared=no
mkdir -p $BUILDDIR/geoip/lib
ln -snf lib $BUILDDIR/geoip/lib64
make -j$(nproc)
make install
make clean
