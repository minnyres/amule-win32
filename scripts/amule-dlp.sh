#!/bin/bash

set -e

mkdir amule-dlp

if [ "$USE_LLVM" == "yes" ]; then
    export RC=$PWD/scripts/llvm-windres.sh
    denoise_level=0
else
    cp curl-ca-bundle.crt amule-dlp
    denoise_level=4
fi

# amule-dlp
cd src/amule-dlp-master

./autogen.sh
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include -DHAVE_LIBCURL" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib" \
    CXXFLAGS="-DCURL_STATICLIB" CFLAGS="-DCURL_STATICLIB" \
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
    --with-libupnp-prefix=$BUILDDIR/libupnp --with-denoise-level=$denoise_level --enable-ccache

make BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lws2_32" BOOST_SYSTEM_LDFLAGS="-L$BUILDDIR/boost/lib" -j$(nproc)
make install
make clean

# libantileech

cd ../amule-dlp.antiLeech-master
PATH=$BUILDDIR/wxwidgets/bin:$PATH
$TARGET-g++ -g0 -Os -s -static -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o antileech.dll $(wx-config --cppflags) $(wx-config --libs)
mv antileech.dll $BUILDDIR/amule-dlp/bin

$TARGET-strip $BUILDDIR/amule-dlp/bin/*.exe

cd ../..
cp $BUILDDIR/amule-dlp/bin/*.exe amule-dlp
cp $BUILDDIR/amule-dlp/bin/*.dll amule-dlp
cp -r $BUILDDIR/amule-dlp/share/locale/ amule-dlp
cp -r $BUILDDIR/amule-dlp/share/amule-dlp/* amule-dlp
mkdir amule-dlp/docs
cp $BUILDDIR/amule-dlp/share/doc/amule-dlp/* amule-dlp/docs
7z a -mx9 amule-dlp-$(printf '%(%Y-%m-%d)T\n' -1)-$ARCH.7z amule-dlp
rm -rf amule-dlp
