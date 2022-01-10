#!/usr/bin/bash

# Dependencies: g++ autoconf automake make patch autopoint bison flex gawk texinfo libtool git wget unzip gettext p7zip-full

set -e

export BUILDDIR=$PWD/../amule-build
export TARGET=i686-w64-mingw32
export PATH=$PWD/../mingw32-cross/bin:$PATH

mkdir -p $BUILDDIR

# zlib
cd $BUILDDIR
wget http://www.zlib.net/zlib-1.2.11.tar.gz
tar -xf zlib-1.2.11.tar.gz
cd zlib-1.2.11/
CC=$TARGET-gcc AR="$TARGET-ar" RANLIB=$TARGET-ranlib ./configure --prefix=$BUILDDIR/tmp/zlib --static
make install

# cryptopp
cd $BUILDDIR
wget http://cryptopp.com/cryptopp610.zip
mkdir cryptopp
cd cryptopp
7z x ../cryptopp610.zip
patch -p0 <  ../../patches/cryptopp-fix-makefile.patch
CXX=$TARGET-g++ RANLIB=$TARGET-ranlib AR=$TARGET-ar LDLIBS=-lws2_32 make static -f GNUmakefile
PREFIX=$BUILDDIR/tmp/cryptopp make -f GNUmakefile install

# libiconv
cd $BUILDDIR
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
tar -xf libiconv-1.16.tar.gz
cd libiconv-1.16
./configure --host=$TARGET --prefix=$BUILDDIR/tmp/libiconv --enable-static=yes --enable-shared=no
make install

# gettext
cd $BUILDDIR
wget http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.3.2.tar.gz
tar -xf gettext-0.18.3.2.tar.gz
cd gettext-0.18.3.2
./configure --host=$TARGET --prefix=$BUILDDIR/tmp/gettext --with-libiconv-prefix=$BUILDDIR/tmp/libiconv --enable-shared=no --enable-static=yes --enable-threads=posix
make install

# boost
cd $BUILDDIR
wget https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.7z
7z x boost_1_78_0.7z
cd boost_1_78_0/

cd tools/build/
./bootstrap.sh
./b2 install --prefix=$BUILDDIR/tmp/boost.build

export PATH=$PATH:$BUILDDIR/tmp/boost.build/bin
cd $BUILDDIR/boost_1_78_0/
echo "using gcc : mingw : $TARGET-g++ ;"  > user-config.jam
b2 --user-config=./user-config.jam --build-dir=$PWD/build-boost --prefix=$BUILDDIR/tmp/boost link=static runtime-link=static toolset=gcc-mingw target-os=windows variant=release threading=multi  address-model=32 install

# wx
cd $BUILDDIR
wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.5/wxWidgets-3.0.5.tar.bz2
tar -xf wxWidgets-3.0.5.tar.bz2
cd wxWidgets-3.0.5
./configure CPPFLAGS="-I$BUILDDIR/tmp/zlib/include" LDFLAGS="-L$BUILDDIR/tmp/zlib/lib"  --host=$TARGET --prefix=$BUILDDIR/tmp/wxwidgets --with-zlib=sys --with-msw --with-libiconv-prefix=$BUILDDIR/tmp/libiconv --disable-shared --disable-debug_flag
make install

# geoip
cd $BUILDDIR
git clone https://github.com/maxmind/geoip-api-c.git
cd geoip-api-c
./bootstrap
./configure --host=$TARGET --prefix=$BUILDDIR/tmp/geoip --enable-shared=no
make install

# libpng
cd $BUILDDIR
wget https://download.sourceforge.net/libpng/libpng-1.6.37.tar.xz
tar -xf libpng-1.6.37.tar.xz
cd libpng-1.6.37
./configure CPPFLAGS="-I$BUILDDIR/tmp/zlib/include" CFLAGS="-I$BUILDDIR/tmp/zlib/include" LDFLAGS="-L$BUILDDIR/tmp/zlib/lib" --host=$TARGET --prefix=$BUILDDIR/tmp/libpng --with-zlib-prefix=$BUILDDIR/tmp/zlib --enable-shared=no 
make install
sed -i 's/libs="-lpng16"/libs="-lpng16 -lz"/g'  $BUILDDIR/tmp/libpng/bin/libpng-config

# libupnp
cd $BUILDDIR
wget https://github.com/pupnp/pupnp/releases/download/release-1.14.12/libupnp-1.14.12.tar.bz2
tar -xf libupnp-1.14.12.tar.bz2
cd libupnp-1.14.12
./configure --host=$TARGET --prefix=$BUILDDIR/tmp/libupnp --enable-static=yes --enable-shared=no --disable-samples
make install
sed -i 's/-lupnp -lixml/& -liphlpapi -lws2_32 /g'  $BUILDDIR/tmp/libupnp/lib/pkgconfig/libupnp.pc

# aMule
cd $BUILDDIR
wget http://prdownloads.sourceforge.net/amule/aMule-2.3.3.tar.xz
tar -xf aMule-2.3.3.tar.xz
cd aMule-2.3.3

patch -p0 < ../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 < ../../patches/amule-fix-wchar_t.patch

./autogen.sh
./configure CPPFLAGS="-I$BUILDDIR/tmp/zlib/include -I$BUILDDIR/tmp/libpng/include" LDFLAGS="-L$BUILDDIR/tmp/zlib/lib -L$BUILDDIR/tmp/libpng/lib"  --prefix=$BUILDDIR/pkg --host=$TARGET --enable-amule-daemon --enable-webserver --enable-amulecmd --enable-amule-gui --enable-cas --enable-wxcas --enable-alc --enable-alcc --enable-fileview --enable-static --enable-geoip --disable-debug --enable-optimize --enable-mmap --with-zlib=$BUILDDIR/tmp/zlib  --with-wx-prefix=$BUILDDIR/tmp/wxwidgets --with-wx-config=$BUILDDIR/tmp/wxwidgets/bin/wx-config --with-crypto-prefix=$BUILDDIR/tmp/cryptopp --with-libintl-prefix=$BUILDDIR/tmp/gettext --with-libiconv-prefix=$BUILDDIR/tmp/libiconv --with-geoip-static -with-geoip-lib=$BUILDDIR/tmp/geoip/lib --with-geoip-headers=$BUILDDIR/tmp/geoip/include  --with-libpng-prefix=$BUILDDIR/tmp/libpng --with-libpng-config=$BUILDDIR/tmp/libpng/bin/libpng-config --enable-static-boost --with-boost=$BUILDDIR/tmp/boost --with-libupnp-prefix=$BUILDDIR/tmp/libupnp --with-denoise-level=0 
make install BOOST_SYSTEM_LIBS="$BUILDDIR/tmp/boost/lib/libboost_system.a -lws2_32" 

# strip and archive 
$TARGET-strip $BUILDDIR/pkg/bin/*

cd $BUILDDIR
mkdir amule
cp pkg/bin/*.exe amule
cp -r pkg/share/locale/ amule
cp -r pkg/share/amule/* amule
mkdir amule/docs
cp pkg/share/doc/amule/* amule/docs
7z a amule-2.3.3-win32.7z amule