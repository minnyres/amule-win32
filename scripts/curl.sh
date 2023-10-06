#!/bin/bash

set -e

if [ "$USE_LLVM" == "yes" ]; then
    ssl_option="--with-schannel"
else
    ssl_option="--with-mbedtls=$BUILDDIR/mbedtls --with-ca-bundle=./curl-ca-bundle.crt"
fi

cd src/curl
autoreconf -fi
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/curl --disable-debug --enable-optimize --enable-ipv6 \
    --enable-pthreads $ssl_option --with-zlib=$BUILDDIR/zlib --disable-shared --enable-static
make -j$(nproc)
make install
make clean
