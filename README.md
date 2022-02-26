# amule-win32

[aMule](https://github.com/amule-project/amule) is an eMule-like client for the eDonkey and Kademlia networks. This repository distributes my personal [aMule](https://github.com/amule-project/amule) build for Windows.

## Install

Download the binary files at the [releases](https://github.com/minnyres/amule-win32/releases/) page. There is no need to install. Just extract and use it. 

## Usage

### Use translations

The default GUI language is English. To use translations, select your language at `Preferences->General->Language`.

### Enable GeoIP

With GeoIP aMule shows the country flags of peers. To enable GeoIP, you need to download the [GeoIP data file](https://mailfud.org/geoip-legacy/GeoIP.dat.gz), extract it and place it in aMule's configuration folder, which should be `C:\Users\<USER_NAME>\AppData\Roaming\aMule` in most cases. Then, enable the option "Show country flags for clients" at `Preferences->Interface`.

## Build from source

I build aMule for Windows by cross compiling with Mingw-w64 GCC on GNU/Linux. To compile from source yourself, you need to work on a GNU/Linux system, with these packages installed:
 + g++
 + autoconf
 + automake
 + make
 + patch
 + bison
 + flex
 + gawk
 + libtool
 + git
 + wget 
 + gettext 
 + p7zip-full 
 + ccache

Checkout the repository

    git clone https://github.com/minnyres/amule-win32.git
    cd amule-win32
    
Download the source code

    ./scripts/download.sh

Build the Mingw-w64 cross toolchain:

    ./scripts/mingw32_cross.sh
    
Add the toolchain path to the environment:

    export PATH=$PWD/toolchain/mingw32/bin/:$PATH

Build aMule 

    TARGET=i686-w64-mingw32 ./scripts/build-all.sh

The build package is archived in the 7-Zip file `amule-<version>-win32.7z`.
