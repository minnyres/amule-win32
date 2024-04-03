#!/bin/bash

set -e

if [ "$USE_LLVM" == "yes" ]; then
    export RC=$PWD/scripts/llvm-windres.sh
    denoise_level=0
else
    denoise_level=4
fi

cd src/amule
[ -z "$amule_version" ] && amule_version=$(git describe --tags --abbrev=0)

patch -p1 <../../patches/amule-fix-curl_with_tls.patch
patch -p1 <../../patches/amule-fix-geoip_url.patch
patch -p0 <../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 <../../patches/amule-fix-exception.patch
patch -p1 <../../patches/amule-fix-unzip.patch
patch -p1 <../../patches/amule-fix-boost_llvm.patch
patch -p1 <../../patches/0001-Apply-the-patch-for-wx-3.2-support-customized-by-deb.patch

./autogen.sh
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include -I$BUILDDIR/gettext/include -DHAVE_LIBCURL -Wno-error=register -D_UNICODE=1 -DUNICODE=1" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib -L$BUILDDIR/gettext/lib -lintl -lpthread" \
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

make BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lwsock32 -lws2_32" BOOST_SYSTEM_LDFLAGS="-L$BUILDDIR/boost/lib" -j$(nproc)
make install
make clean

git restore .
git clean -f

$TARGET-strip $BUILDDIR/amule/bin/*.exe

cd ../..
cp $BUILDDIR/amule/bin/*.exe amule
cp -r $BUILDDIR/amule/share/locale/ amule
cp -r $BUILDDIR/amule/share/amule/* amule
mkdir -p amule/docs
cp $BUILDDIR/amule/share/doc/amule/* amule/docs
7z a -mx9 amule-${amule_version}-$ARCH.7z amule
