#!/bin/bash

set -e

mkdir -p $PWD/src
cd $PWD/src

wget http://zlib.net/zlib-1.2.12.tar.gz
wget http://cryptopp.com/cryptopp860.zip
wget https://github.com/noloader/cryptopp-autotools/archive/refs/tags/CRYPTOPP_8_6_0.tar.gz -O cryptopp-autotools-CRYPTOPP_8_6_0.tar.gz
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.16.tar.gz
wget http://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.xz
wget https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.7z
wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.5/wxWidgets-3.0.5.tar.bz2
wget https://download.sourceforge.net/libpng/libpng-1.6.37.tar.xz
wget https://github.com/pupnp/pupnp/releases/download/release-1.14.12/libupnp-1.14.12.tar.bz2
wget http://prdownloads.sourceforge.net/amule/aMule-2.3.3.tar.xz
git clone https://github.com/maxmind/geoip-api-c.git
wget https://github.com/persmule/amule-dlp.antiLeech/archive/refs/heads/master.zip -O amule-dlp.antiLeech-master.zip
wget https://github.com/persmule/amule-dlp/archive/refs/heads/master.zip -O amule-dlp-master.zip
wget https://curl.se/download/curl-7.83.0.tar.xz
wget https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v3.1.0.tar.gz -O mbedtls-3.1.0.tar.gz

tar -xf zlib-1.2.12.tar.gz
tar -xf libpng-1.6.37.tar.xz
tar -xf libiconv-1.16.tar.gz
tar -xf libupnp-1.14.12.tar.bz2
tar -xf gettext-0.21.tar.xz
tar -xf mbedtls-3.1.0.tar.gz
tar -xf curl-7.83.0.tar.xz
tar -xf wxWidgets-3.0.5.tar.bz2
7z x boost_1_78_0.7z

tar -xf aMule-2.3.3.tar.xz
7z x amule-dlp-master.zip
7z x amule-dlp.antiLeech-master.zip

cd aMule-2.3.3
patch -p1 <../../patches/amule-fix-curl_with_tls.patch
patch -p1 <../../patches/amule-fix-geoip_url.patch
patch -p0 <../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 <../../patches/amule-fix-wchar_t.patch
patch -p0 <../../patches/amule-fix-exception.patch
patch -p1 <../../patches/amule-fix-unzip.patch
patch -p1 <../../patches/amule-fix-boost_llvm.patch

cd ../amule-dlp-master
patch -p1 <../../patches/amule-fix-curl_with_tls.patch
patch -p1 <../../patches/amule-fix-geoip_url.patch
patch -p0 <../../patches/amule-fix-upnp_cross_compile.patch
patch -p0 <../../patches/amule-fix-wchar_t.patch
patch -p0 <../../patches/amule-fix-exception.patch
patch -p1 <../../patches/amule-fix-unzip.patch
patch -p1 <../../patches/amule-fix-dlp.patch
patch -p1 <../../patches/amule-fix-boost_llvm.patch

cd ../amule-dlp.antiLeech-master
patch -p1 <../../patches/amule-fix-libantiLeech.patch

cd ..
mkdir cryptopp
cd cryptopp
7z x ../cryptopp860.zip

tar -xf ../cryptopp-autotools-CRYPTOPP_8_6_0.tar.gz
cp cryptopp-autotools-CRYPTOPP_8_6_0/* .
rm -rf cryptopp-autotools-CRYPTOPP_8_6_0
mkdir -p m4