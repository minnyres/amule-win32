#!/bin/bash

set -e

cd src
tar -xf curl-7.83.0.tar.xz
cd curl-7.83.0
./configure --host=$TARGET --prefix=$BUILDDIR/curl --disable-debug --enable-optimize --enable-ipv6 \
    --enable-pthreads --with-mbedtls=$BUILDDIR/mbedtls --with-zlib=$BUILDDIR/zlib --disable-shared --enable-static
make -j$(nproc)
make install
cd ..
rm -rf curl-7.83.0
