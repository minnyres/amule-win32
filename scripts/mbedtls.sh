#!/bin/bash

set -e

cd src/mbedtls

export WINDOWS_BUILD=1
export CC=$TARGET-gcc
make no_test -j$(nproc)
make install DESTDIR=$BUILDDIR/mbedtls
make clean
