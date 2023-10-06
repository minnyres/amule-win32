#!/bin/bash

set -e

help_msg="Usage: ./scripts/gcc-mingw.sh -arch=[x86|x64]"

if [ $# == 1 ]; then
    if [ $1 == "-arch=x86" ]; then
        arch=x86
    elif [ $1 == "-arch=x64" ]; then
        arch=x64
    else
        echo $help_msg
        exit -1
    fi
else
    echo $help_msg
    exit -1
fi

if [ $arch == "x86" ]; then
    TARGET=i686-w64-mingw32
    BUILDDIR=$PWD/toolchain/mingw32
    mingw_lib32=yes
    mingw_lib64=no
else
    TARGET=x86_64-w64-mingw32
    BUILDDIR=$PWD/toolchain/mingw64
    mingw_lib32=no
    mingw_lib64=yes
fi

GCC_VERSION=13.2.0
MINGW_VERSION=11.0.0
BINUTILS_VERSION=2.41

mkdir -p $BUILDDIR/tmp
cd $BUILDDIR/tmp
wget https://ftpmirror.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz
wget https://ftpmirror.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz
wget https://jaist.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$MINGW_VERSION.tar.bz2

# binutils
cd $BUILDDIR/tmp
tar -xf binutils-$BINUTILS_VERSION.tar.xz
cd binutils-$BINUTILS_VERSION
./configure CFLAGS="-g0 -O2" LDFLAGS="-s" --prefix=$BUILDDIR --target=$TARGET --with-sysroot=$BUILDDIR --disable-multilib
make -j$(nproc)
make install

# mingw-w64 headers
cd $BUILDDIR/tmp
tar -xf mingw-w64-v$MINGW_VERSION.tar.bz2
cd mingw-w64-v$MINGW_VERSION/mingw-w64-headers
./configure --prefix=$BUILDDIR/$TARGET --host=$TARGET --enable-sdk=all --enable-idl --enable-secure-api --with-default-msvcrt=msvcrt --with-default-win32-winnt=0x0502
make all
make install

# gcc-core
cd $BUILDDIR/tmp
tar -xf gcc-$GCC_VERSION.tar.xz
cd gcc-$GCC_VERSION
./contrib/download_prerequisites

mkdir -p build
cd build
../configure CFLAGS="-g0 -O2" CXXFLAGS="-g0 -O2" CFLAGS_FOR_TARGET="-g0 -O2" \
    CXXFLAGS_FOR_TARGET="-g0 -O2" BOOT_CFLAGS="-g0 -O2" BOOT_CXXFLAGS="-g0 -O2" \
    LDFLAGS="-s" LDFLAGS_FOR_TARGET="-s" BOOT_LDFLAGS="-s" \
    --prefix=$BUILDDIR --target=$TARGET --with-sysroot=$BUILDDIR \
    --disable-multilib --disable-shared --enable-languages=c,c++ \
    --enable-threads=posix --disable-win32-registry --enable-version-specific-runtime-libs \
    --enable-fully-dynamic-string --enable-libgomp --enable-libssp --enable-lto \
    --disable-libstdcxx-pch --disable-libstdcxx-verbose

ln -snf $TARGET $BUILDDIR/mingw

make -j$(nproc) all-gcc
make install-gcc

PATH=$BUILDDIR/bin:$PATH

# mingw-w64 crt
mkdir -p $BUILDDIR/$TARGET/lib
ln -snf lib $BUILDDIR/$TARGET/lib64
cd $BUILDDIR/tmp/mingw-w64-v$MINGW_VERSION/mingw-w64-crt/
./configure CFLAGS="-g0 -O2" LDFLAGS="-s" --prefix=$BUILDDIR/$TARGET --host=$TARGET --enable-lib64=$mingw_lib64 --enable-lib32=$mingw_lib32 --with-default-msvcrt=msvcrt --with-default-win32-winnt=0x0502
make
make install

# winpthreads
cd $BUILDDIR/tmp/mingw-w64-v$MINGW_VERSION/mingw-w64-libraries/winpthreads/
./configure CFLAGS="-g0 -O2" LDFLAGS="-s" --prefix=$BUILDDIR/$TARGET --host=$TARGET --enable-shared=no --enable-static
make -j$(nproc)
make install

# gcc libs
cd $BUILDDIR/tmp/gcc-$GCC_VERSION/build
make -j$(nproc)
make install

# clean
cd $BUILDDIR/
rm -rf $BUILDDIR/tmp/
rm $BUILDDIR/mingw
