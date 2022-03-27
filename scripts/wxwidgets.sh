#!/usr/bin/bash

set -e

cd src
tar -xf wxWidgets-3.0.5.tar.bz2
cd wxWidgets-3.0.5
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib"  \
    --host=$TARGET --prefix=$BUILDDIR/wxwidgets --with-zlib=sys --with-libpng=sys --with-msw --with-libiconv-prefix=$BUILDDIR/libiconv \
    --disable-shared --disable-debug_flag --disable-mediactrl --enable-optimise --enable-unicode 
mkdir -p $BUILDDIR/wxwidgets/lib
ln -s lib $BUILDDIR/wxwidgets/lib64
make -j$(nproc)
make install
cd ..
rm -rf wxWidgets-3.0.5

WX_INCLUDE=$BUILDDIR/wxwidgets/include/wx-3.0/wx/msw

if [ "$ARCH" == "arm32" ]
then
    cp $WX_INCLUDE/amd64.manifest $WX_INCLUDE/arm.manifest
    sed -i 's/amd64/arm/g'  $WX_INCLUDE/arm.manifest
    rc_line=$(sed -n -e '/error "One of WX_CPU_XXX constants must be defined/=' $WX_INCLUDE/wx.rc)
    sed -i "$rc_line c\wxMANIFEST_ID 24 \"wx/msw/arm.manifest\"" $WX_INCLUDE/wx.rc
fi