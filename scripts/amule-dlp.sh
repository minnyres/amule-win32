#!/usr/bin/bash

set -e

if [ "$USE_LLVM" == "yes" ]
then
    export RC=$PWD/toolchain/mingw32/bin/i686-w64-mingw32-windres
fi

# amule-dlp
cd src
7z x amule-dlp-master.zip
cd amule-dlp-master

patch -p0 < ../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 < ../../patches/amule-fix-wchar_t.patch
patch -p0 < ../../patches/amule-fix-exception.patch
patch -p1 < ../../patches/amule-fix-unzip.patch
patch -p1 < ../../patches/amule-fix-dlp.patch
patch -p1 < ../../patches/amule-fix-boost_llvm.patch

./autogen.sh
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib"  \
    --prefix=$BUILDDIR/amule-dlp --host=$TARGET \
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

make BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lws2_32" BOOST_SYSTEM_LDFLAGS="-L$BUILDDIR/boost/lib" -j$(nproc)
make install
cd ..
rm -rf amule-dlp-master

# libantileech
7z x amule-dlp.antiLeech-master.zip
cd amule-dlp.antiLeech-master
patch -p1 < ../../patches/amule-fix-libantiLeech.patch
export PATH=$BUILDDIR/wxwidgets/bin:$PATH
$TARGET-g++ -std=c++20 -g0 -O3 -s -static -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o antileech.dll $(wx-config --cppflags) $(wx-config --libs)
mv antileech.dll $BUILDDIR/amule-dlp/bin
cd ..
rm -rf amule-dlp.antiLeech-master

$TARGET-strip $BUILDDIR/amule-dlp/bin/*.exe

cd ..
mkdir amule-dlp
cp $BUILDDIR/amule-dlp/bin/*.exe amule-dlp
cp $BUILDDIR/amule-dlp/bin/*.dll amule-dlp
cp -r $BUILDDIR/amule-dlp/share/locale/ amule-dlp
cp -r $BUILDDIR/amule-dlp/share/amule-dlp/* amule-dlp
mkdir amule-dlp/docs
cp $BUILDDIR/amule-dlp/share/doc/amule-dlp/* amule-dlp/docs
7z a amule-dlp-$(printf '%(%Y-%m-%d)T\n' -1)-win32.7z amule-dlp
rm -rf amule-dlp