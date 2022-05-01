#!/bin/bash

set -e

export CXXFLAGS="-g0 -Os"
export CFLAGS="-g0 -Os"
export LDFLAGS="-s"

cd src/geoip-api-c
./bootstrap
mkdir -p build-geoip
cd build-geoip
../configure --host=$TARGET --prefix=$BUILDDIR/geoip --enable-shared=no
mkdir -p $BUILDDIR/geoip/lib
ln -s lib $BUILDDIR/geoip/lib64
make -j$(nproc)
make install
cd ..
rm -rf build-geoip
