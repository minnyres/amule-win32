#!/bin/bash

set -e

mkdir -p amule

if [ "$USE_LLVM" == "yes" ]; then
    export RC=$PWD/scripts/llvm-windres.sh
    denoise_level=0
else
    cp curl-ca-bundle.crt amule
    denoise_level=4
fi

cd src/aMule-2.3.3

patch -p1 <../../patches/amule-fix-curl_with_tls.patch
patch -p1 <../../patches/amule-fix-geoip_url.patch
patch -p0 <../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 <../../patches/amule-fix-wchar_t.patch
patch -p0 <../../patches/amule-fix-exception.patch
patch -p1 <../../patches/amule-fix-unzip.patch
patch -p1 <../../patches/amule-fix-boost_llvm.patch

./autogen.sh
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include -DHAVE_LIBCURL" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib" \
    CXXFLAGS="-DCURL_STATICLIB" CFLAGS="-DCURL_STATICLIB" \
    --prefix=$BUILDDIR/amule --host=$TARGET \
    --enable-amule-daemon --enable-webserver --enable-amulecmd --enable-amule-gui \
    --enable-cas --enable-wxcas --enable-alc --enable-alcc --enable-fileview \
    --enable-static --enable-geoip --disable-debug --enable-optimize --enable-mmap \
    --with-zlib=$BUILDDIR/zlib \
    --with-wx-prefix=$BUILDDIR/wxwidgets --with-wx-config=$BUILDDIR/wxwidgets/bin/wx-config \
    --with-crypto-prefix=$BUILDDIR/cryptopp \
    --with-libcurl=$BUILDDIR/curl \
    --with-libintl-prefix=$BUILDDIR/gettext --with-libiconv-prefix=$BUILDDIR/libiconv \
    --with-geoip-static -with-geoip-lib=$BUILDDIR/geoip/lib --with-geoip-headers=$BUILDDIR/geoip/include \
    --with-libpng-prefix=$BUILDDIR/libpng --with-libpng-config=$BUILDDIR/libpng/bin/libpng-config \
    --enable-static-boost --with-boost=$BUILDDIR/boost \
    --with-libupnp-prefix=$BUILDDIR/libupnp --with-denoise-level=$denoise_level --enable-ccache

make BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lws2_32" BOOST_SYSTEM_LDFLAGS="-L$BUILDDIR/boost/lib" -j$(nproc)
make install
make clean

patch -p1 -R <../../patches/amule-fix-boost_llvm.patch
patch -p1 -R <../../patches/amule-fix-unzip.patch
patch -p0 -R <../../patches/amule-fix-exception.patch
patch -p0 -R <../../patches/amule-fix-wchar_t.patch
patch -p0 -R <../../patches/amule-fix-upnp_cross_compile.patch
patch -p1 -R <../../patches/amule-fix-geoip_url.patch
patch -p1 -R <../../patches/amule-fix-curl_with_tls.patch

$TARGET-strip $BUILDDIR/amule/bin/*.exe

cd ../..
cp $BUILDDIR/amule/bin/*.exe amule
cp -r $BUILDDIR/amule/share/locale/ amule
cp -r $BUILDDIR/amule/share/amule/* amule
mkdir -p amule/docs
cp $BUILDDIR/amule/share/doc/amule/* amule/docs
7z a -mx9 amule-2.3.3-$ARCH.7z amule
rm -rf amule
