#!/usr/bin/bash

set -e

cd src
tar -xf zlib-1.2.11.tar.gz
cd zlib-1.2.11/
CC=$TARGET-gcc ./configure --prefix=$BUILDDIR/zlib --static
make -j$(nproc) 
make install
cd ..
rm -rf zlib-1.2.11/