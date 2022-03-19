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

### Prerequisite

The scripts build aMule for Windows by cross compiling with Mingw-w64 GCC/LLVM on GNU/Linux. To compile from source yourself, you need to work on a GNU/Linux system, with these packages installed:
> g++, autoconf, automake, make, patch, bison, flex, pkg-config, libtool, git, wget, gettext, makeinfo, p7zip-full 

### Download

Checkout the repository

    git clone https://github.com/minnyres/amule-win32.git
    cd amule-win32
    
Download the source code of aMule and third party libraries

    ./scripts/download.sh
    
### Build the cross toolchain

You can build either GCC or LLVM toolchain for cross compiling. Note that currently GCC does not support Windows on ARM.

Build Mingw-w64 GCC with

    ./scripts/gcc-mingw.sh -arch=x86
    
Build Mingw-w64 LLVM with

    ./scripts/llvm-mingw.sh -crt=[ucrt/msvcrt]
    
Here, the option `-crt` specifies the C standard library for the toolchain. The toolchain uses UCRT with `-crt=ucrt`, and uses MSVCRT with `-crt=msvcrt`. The [MSYS2 document](https://www.msys2.org/docs/environments/) explains the differences between them.

### Build aMule 

    ./scripts/build-all.sh -arch=[x86/arm32] -cc=[gcc/clang]
    
Here, option `-arch` specifies the CPU architecture and `-cc` specifies the toolchain. The supported values of the options include:

+ build for Windows x86 with GCC: `-arch=x86 -cc=gcc`
+ build for Windows x86 with LLVM: `-arch=x86 -cc=clang`
+ build for Windows ARM32 with LLVM: `-arch=arm32 -cc=clang`

The build package is archived in the 7-Zip file `amule-<version>-windows-<arch>.7z`.
