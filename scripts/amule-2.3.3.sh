#!/usr/bin/bash

set -e

if [ "$USE_LLVM" == "yes" ]
then
    rc=$PWD/scripts/llvm-windres.sh
else
    rc=$TARGET-windres
fi

cd src
tar -xf aMule-2.3.3.tar.xz
cd aMule-2.3.3

patch -p0 < ../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 < ../../patches/amule-fix-wchar_t.patch
patch -p0 < ../../patches/amule-fix-exception.patch
patch -p1 < ../../patches/amule-fix-unzip.patch
patch -p1 < ../../patches/amule-fix-boost_llvm.patch

./autogen.sh
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib"  \
    --prefix=$BUILDDIR/amule --host=$TARGET \
    --enable-amule-daemon --enable-webserver --enable-amulecmd --enable-amule-gui \
    --enable-cas --enable-wxcas --enable-alc --enable-alcc --enable-fileview \
    --enable-static --enable-geoip --disable-debug --enable-optimize --enable-mmap \
    --with-zlib=$BUILDDIR/zlib \
    --with-wx-prefix=$BUILDDIR/wxwidgets --with-wx-config=$BUILDDIR/wxwidgets/bin/wx-config \
    --with-crypto-prefix=$BUILDDIR/cryptopp \
    --with-libintl-prefix=$BUILDDIR/gettext --with-libiconv-prefix=$BUILDDIR/libiconv \
    --with-geoip-static -with-geoip-lib=$BUILDDIR/geoip/lib --with-geoip-headers=$BUILDDIR/geoip/include \
    --with-libpng-prefix=$BUILDDIR/libpng --with-libpng-config=$BUILDDIR/libpng/bin/libpng-config \
    --enable-static-boost --with-boost=$BUILDDIR/boost \
    --with-libupnp-prefix=$BUILDDIR/libupnp --with-denoise-level=0 

make BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lws2_32" BOOST_SYSTEM_LDFLAGS="-L$BUILDDIR/boost/lib" RC=$rc -j$(nproc)
make install

cd ..
rm -rf aMule-2.3.3

$TARGET-strip $BUILDDIR/amule/bin/*.exe

cd ..
mkdir amule
cp $BUILDDIR/amule/bin/*.exe amule
cp -r $BUILDDIR/amule/share/locale/ amule
cp -r $BUILDDIR/amule/share/amule/* amule
mkdir amule/docs
cp $BUILDDIR/amule/share/doc/amule/* amule/docs
7z a -mx9 amule-2.3.3-windows-$ARCH.7z amule
rm -rf amule