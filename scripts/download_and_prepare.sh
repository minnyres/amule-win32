#!/bin/bash

set -e

mkdir -p $PWD/src
cd $PWD/src

libiconv_version=1.17
gettext_version=0.22.2

git clone --branch v1.3 --depth 1 https://github.com/madler/zlib.git 
git clone --branch v1.6.40 --depth 1 https://github.com/glennrp/libpng.git
git clone --branch release-1.14.12 --depth 1 https://github.com/pupnp/pupnp.git
git clone --branch v3.4.1 --depth 1 https://github.com/Mbed-TLS/mbedtls.git
git clone --branch curl-8_3_0 --depth 1 https://github.com/curl/curl.git
git clone --branch v3.0.5.1 --depth 1 https://github.com/wxWidgets/wxWidgets.git
git clone --branch 2.3.3 --depth 1 https://github.com/amule-project/amule.git
git clone --branch CRYPTOPP_8_8_0 --depth 1 https://github.com/weidai11/cryptopp.git
git clone --branch CRYPTOPP_8_8_0 --depth 1 https://github.com/noloader/cryptopp-autotools.git
git clone --depth 1 https://github.com/persmule/amule-dlp.antiLeech.git
git clone https://github.com/persmule/amule-dlp.git
git clone --depth 1 https://github.com/maxmind/geoip-api-c.git

wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.7z -O boost.7z
wget https://ftp.gnu.org/gnu/libiconv/libiconv-${libiconv_version}.tar.gz
wget https://ftp.gnu.org/gnu/gettext/gettext-${gettext_version}.tar.xz
7z x boost.7z
mv boost_* boost
tar xf libiconv-${libiconv_version}.tar.gz
mv libiconv-${libiconv_version} libiconv
tar xf gettext-${gettext_version}.tar.xz
mv gettext-${gettext_version} gettext

cd cryptopp
cp ../cryptopp-autotools/Makefile.am .
cp ../cryptopp-autotools/configure.ac .
cp ../cryptopp-autotools/libcryptopp.pc.in .
cp ../cryptopp-autotools/bootstrap.sh .
mkdir -p m4

cd ../amule-dlp
git checkout 62eb92fc6cf5f28da24bcc78a80e22d608240aa2