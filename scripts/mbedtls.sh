#!/bin/bash

set -e

cd src/mbedtls-3.1.0
patch -p1 <../../patches/mbedtls-fix-vsnprintf_on_winxp.patch
export WINDOWS_BUILD=1
export CC=$TARGET-gcc
make no_test -j$(nproc)
make install DESTDIR=$BUILDDIR/mbedtls
make clean
