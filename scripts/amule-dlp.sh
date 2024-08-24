#!/bin/bash

set -e


if [ "$USE_LLVM" == "yes" ]; then
    export RC=$PWD/scripts/llvm-windres.sh
fi

# amule-dlp
cd src/amule-dlp

patch -p1 <../../patches/amule-fix-curl_with_tls.patch
patch -p1 <../../patches/amule-fix-geoip_url.patch
patch -p0 <../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 <../../patches/amule-fix-exception.patch
patch -p1 <../../patches/amule-fix-unzip.patch
patch -p1 <../../patches/amule-fix-dlp.patch
patch -p1 <../../patches/amule-fix-boost_llvm.patch

./autogen.sh
./configure CPPFLAGS="$CPPFLAGS -Wno-error=register -D_UNICODE=1 -DUNICODE=1" \
    LDFLAGS="$LDFLAGS -lintl -pthread" \
    CXXFLAGS="$CXXFLAGS -DCURL_STATICLIB -pthread" CFLAGS="$CFLAGS -DCURL_STATICLIB -pthread" \
    --prefix=$BUILDDIR/amule-dlp --host=$TARGET \
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
    --with-libupnp-prefix=$BUILDDIR/libupnp --with-denoise-level=0 --enable-ccache

make GDLIB_LIBS="-lgd -liconv -lpng16 -lz" BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lwsock32 -lws2_32" BOOST_SYSTEM_LDFLAGS="-L$BUILDDIR/boost/lib" -j$(nproc)
make install
make clean

git restore .
git clean -f

# libantileech

cd ../amule-dlp.antiLeech
patch -p1 <../../patches/amule-fix-libantiLeech.patch
PATH=$BUILDDIR/wxwidgets/bin:$PATH
$TARGET-g++ -g0 -Os -s -static -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o antileech.dll $(wx-config --cppflags) $(wx-config --libs)
mv antileech.dll $BUILDDIR/amule-dlp/bin
patch -p1 -R <../../patches/amule-fix-libantiLeech.patch

$TARGET-strip $BUILDDIR/amule-dlp/bin/*.exe

cd ../..
cp $BUILDDIR/amule-dlp/bin/*.exe amule-dlp
cp $BUILDDIR/amule-dlp/bin/*.dll amule-dlp
cp -r $BUILDDIR/amule-dlp/share/locale/ amule-dlp
cp -r $BUILDDIR/amule-dlp/share/amule-dlp/* amule-dlp
mkdir -p amule-dlp/docs
cp $BUILDDIR/amule-dlp/share/doc/amule-dlp/* amule-dlp/docs
7z a -mx9 amule-dlp-$(printf '%(%Y-%m-%d)T\n' -1)-$ARCH.7z amule-dlp
