#!/usr/bin/bash

set -e

export TARGET=i686-w64-mingw32
export BUILDDIR=$PWD/build-$TARGET
export USE_LLVM=no

if [ "$USE_LLVM" == "yes" ]
then
    export PATH=$PWD/toolchain/clang/bin/:$PATH
else
    export PATH=$PWD/toolchain/mingw32/bin/:$PATH
fi

./scripts/zlib.sh
./scripts/cryptopp-autotools.sh
./scripts/libiconv.sh 
./scripts/gettext.sh
./scripts/boost.sh
./scripts/wxwidgets.sh
./scripts/geoip.sh
./scripts/libpng.sh 
./scripts/libupnp.sh 
./scripts/amule-2.3.3.sh
./scripts/amule-dlp.sh 