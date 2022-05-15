#!/bin/bash

set -e

cd src/wxWidgets-3.0.5
mkdir build-$TARGET
cd build-$TARGET
../configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib" \
    --host=$TARGET --prefix=$BUILDDIR/wxwidgets --with-zlib=sys --with-libpng=sys --with-msw --with-libiconv-prefix=$BUILDDIR/libiconv \
    --disable-shared --disable-debug_flag --disable-mediactrl --enable-optimise --enable-unicode
mkdir -p $BUILDDIR/wxwidgets/lib
ln -s lib $BUILDDIR/wxwidgets/lib64
make -j$(nproc)
make install
make clean

WX_INCLUDE=$BUILDDIR/wxwidgets/include/wx-3.0/wx/msw

if [ "$ARCH" == "win32-arm" ]; then
    cp $WX_INCLUDE/amd64.manifest $WX_INCLUDE/arm.manifest
    sed -i 's/amd64/arm/g' $WX_INCLUDE/arm.manifest
    rc_line=$(sed -n -e '/error "One of WX_CPU_XXX constants must be defined/=' $WX_INCLUDE/wx.rc)
    sed -i "$rc_line c\wxMANIFEST_ID 24 \"wx/msw/arm.manifest\"" $WX_INCLUDE/wx.rc
fi

cd $BUILDDIR/wxwidgets/lib

for file in *.a; do
    newfile="${file//"-$TARGET"/""}"
    ln -s $file $newfile
done