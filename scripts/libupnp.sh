#!/usr/bin/bash

set -e

cd src
tar -xf libupnp-1.14.12.tar.bz2
cd libupnp-1.14.12
./configure --host=$TARGET --prefix=$BUILDDIR/libupnp --enable-static=yes --enable-shared=no --disable-samples --disable-ipv6
mkdir -p $BUILDDIR/libupnp/lib
ln -s lib $BUILDDIR/libupnp/lib64
make -j$(nproc)
make install
sed -i 's/-lupnp -lixml/& -liphlpapi -lws2_32 /g' $BUILDDIR/libupnp/lib/pkgconfig/libupnp.pc
cd ..
rm -rf libupnp-1.14.12
