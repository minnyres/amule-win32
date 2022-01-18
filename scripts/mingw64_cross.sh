#!/usr/bin/bash

# Dependencies: g++ autoconf automake make patch autopoint bison flex gawk texinfo libtool wget

set -e

export TARGET=x86_64-w64-mingw32
export BUILDDIR=$PWD/../mingw64-cross
export GCC_VERSION=8.3.0
export MINGW_VERSION=6.0.0
export BINUTILS_VERSION=2.37
export MPFR_VERSION=4.1.0
export MPC_VERSION=1.2.1
export GMP_VERSION=6.2.1
export ISL_VERSION=0.24

mkdir $BUILDDIR/tmp -p
cd $BUILDDIR/tmp
wget http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz
wget http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz
wget http://ftp.gnu.org/gnu/gmp/gmp-$GMP_VERSION.tar.xz
wget http://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VERSION.tar.xz
wget http://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz
wget https://gcc.gnu.org/pub/gcc/infrastructure/isl-$ISL_VERSION.tar.bz2
wget https://jaist.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$MINGW_VERSION.tar.bz2

# binutils
cd $BUILDDIR/tmp
tar -xf binutils-$BINUTILS_VERSION.tar.xz
cd binutils-$BINUTILS_VERSION
./configure --prefix=$BUILDDIR --target=$TARGET --with-sysroot=$BUILDDIR --disable-multilib 
make -j$(nproc) && make install

# mingw-w64 headers
cd $BUILDDIR/tmp
tar -xf mingw-w64-v$MINGW_VERSION.tar.bz2
cd mingw-w64-v$MINGW_VERSION/mingw-w64-headers
./configure --prefix=$BUILDDIR/$TARGET --host=$TARGET
make all && make install

# gcc-core
cd $BUILDDIR/tmp
tar -xf gcc-$GCC_VERSION.tar.xz
cd gcc-$GCC_VERSION
tar -xf ../mpfr-$MPFR_VERSION.tar.xz
mv -v mpfr-$MPFR_VERSION mpfr
tar -xf ../gmp-$GMP_VERSION.tar.xz
mv -v gmp-$GMP_VERSION gmp
tar -xf ../mpc-$MPC_VERSION.tar.gz
mv -v mpc-$MPC_VERSION mpc
tar -xf ../isl-$ISL_VERSION.tar.bz2
mv -v isl-$ISL_VERSION isl

mkdir build
cd build
../configure --prefix=$BUILDDIR --target=$TARGET --with-sysroot=$BUILDDIR --disable-multilib  --disable-shared --enable-languages=c,c++ --enable-threads=posix --disable-win32-registry --enable-version-specific-runtime-libs --enable-fully-dynamic-string --enable-libgomp --enable-libssp --enable-lto 

ln -s $TARGET $BUILDDIR/mingw

make -j$(nproc) all-gcc && make install-gcc

export PATH=$BUILDDIR/bin:$PATH

# mingw-w64 crt
cd $BUILDDIR/tmp/mingw-w64-v$MINGW_VERSION/mingw-w64-crt/
./configure --prefix=$BUILDDIR/$TARGET --host=$TARGET --enable-lib64 --enable-lib32=no 
make -j$(nproc) && make install

# winpthreads
ln -s lib $BUILDDIR/$TARGET/lib64
cd $BUILDDIR/tmp/mingw-w64-v$MINGW_VERSION/mingw-w64-libraries/winpthreads/
./configure --prefix=$BUILDDIR/$TARGET --host=$TARGET --enable-shared=no --enable-static
make -j$(nproc) && make install

# gcc libs
cd $BUILDDIR/tmp/gcc-$GCC_VERSION/build
make -j$(nproc) && make install

# clean
cd $BUILDDIR/
rm -rf $BUILDDIR/tmp/
rm $BUILDDIR/mingw

# strip
cd $BUILDDIR/
find -executable -type f -exec strip -s {} ";" >& /dev/null
find . -name "*.a" -type f -exec $TARGET-strip -d {} ";" >& /dev/null
find . -name "*.o" -type f -exec $TARGET-strip -d {} ";" >& /dev/null
