#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET

# amule-dlp
cd src/amule-dlp

patch -p0 < ../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 < ../../patches/amule-fix-wchar_t.patch
patch -p0 < ../../patches/amule-fix-exception.patch
patch -p1 < ../../patches/amule-fix-unzip.patch
patch -p1 < ../../patches/amule-fix-dlp.patch

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
    --with-libupnp-prefix=$BUILDDIR/libupnp \
    --enable-ccache --with-denoise-level=3 >configure.log.txt 2>&1

make BOOST_SYSTEM_LIBS="$BUILDDIR/boost/lib/libboost_system.a -lws2_32" -j$(nproc)
make install
make clean
make distclean

patch -p0 -R < ../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 -R < ../../patches/amule-fix-wchar_t.patch
patch -p0 -R < ../../patches/amule-fix-exception.patch
patch -p1 -R < ../../patches/amule-fix-unzip.patch
patch -p1 -R < ../../patches/amule-fix-dlp.patch

# libantileech
cd ../amule-dlp.antiLeech
patch -p1 < ../../patches/amule-fix-libantiLeech.patch
export PATH=$BUILDDIR/wxwidgets/bin:$PATH
$TARGET-g++ -O2 -s -fPIC -shared antiLeech.cpp antiLeech_wx.cpp Interface.cpp -o antileech.dll $(wx-config --cppflags) $(wx-config --libs)
mv antileech.dll $BUILDDIR/amule-dlp/bin
patch -p1 -R < ../../patches/amule-fix-libantiLeech.patch

$TARGET-strip $BUILDDIR/amule-dlp/bin/*.exe

cd ../..
mkdir amule-dlp
cp $BUILDDIR/amule-dlp/bin/*.exe amule-dlp
cp $BUILDDIR/amule-dlp/bin/*.dll amule-dlp
cp -r $BUILDDIR/amule-dlp/share/locale/ amule-dlp
cp -r $BUILDDIR/amule-dlp/share/amule-dlp/* amule-dlp
mkdir amule-dlp/docs
cp $BUILDDIR/amule-dlp/share/doc/amule-dlp/* amule-dlp/docs
7z a amule-dlp-$(printf '%(%Y-%m-%d)T\n' -1)-win32.7z amule-dlp
rm -rf amule-dlp