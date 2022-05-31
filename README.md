# amule-win32

[aMule](https://github.com/amule-project/amule) is an eMule-like client for the eDonkey and Kademlia networks. This repository distributes my personal [aMule](https://github.com/amule-project/amule) build for Windows. In addition to official [aMule](https://github.com/amule-project/amule), we also build the community fork [amule-dlp](https://github.com/persmule/amule-dlp) which supports dynamic leech protection (DLP).

## Download

You can download the binary files at the [releases](https://github.com/minnyres/amule-win32/releases/latest) page. 

## Usage

### Use translations

The default GUI language is English. To use translations, select your language at `Preferences->General->Language`.

### Enable GeoIP

With GeoIP aMule shows the country flags of peers. To enable GeoIP, you need to download the [GeoIP data file](https://mailfud.org/geoip-legacy/GeoIP.dat.gz), extract it and place it in aMule's configuration folder, which should be `C:\Users\<USER_NAME>\AppData\Roaming\aMule` in most cases. Then, enable the option "Show country flags for clients" at `Preferences->Interface`.

## Build from source

### Prerequisite

The scripts build aMule for Windows by cross compiling with Mingw-w64 GCC/LLVM on GNU/Linux. To compile from source yourself, you need to work on a GNU/Linux system and install necessary packages. 

For openSUSE tumbleweed, install via `zypper`

    sudo zypper install gcc-c++ autoconf automake make patch bison flex libtool git wget gettext-runtime makeinfo 7zip pkgconf-pkg-config

For Debian, install via `apt`

    sudo apt install g++ autoconf automake make patch bison flex libtool git wget gettext texinfo p7zip-full pkg-config

### Download

Checkout the repository

    git clone https://github.com/minnyres/amule-win32.git
    cd amule-win32
    
Download and prepare the source code

    ./scripts/download_and_prepare.sh
    
### Build the cross toolchain

You can build either GCC or LLVM toolchain for cross compiling. To build aMule for Windows on ARM (WoA), you should choose LLVM since currently GCC does not support WoA.

Build Mingw-w64 GCC

    ./scripts/gcc-mingw.sh -arch=x86
    
Build Mingw-w64 LLVM

    ./scripts/llvm-mingw.sh -crt=ucrt
    

### Build aMule 

Build for Windows x86 with GCC: 

    ./scripts/build-all.sh -arch=x86 -cc=gcc

Build for Windows x86 with LLVM: 

    ./scripts/build-all.sh -arch=x86 -cc=clang

Build for Windows ARM32 with LLVM: 

    ./scripts/build-all.sh -arch=arm32 -cc=clang

This script will build the third party libraries, official [aMule](https://github.com/amule-project/amule) and [amule-dlp](https://github.com/persmule/amule-dlp). The build package for official [aMule](https://github.com/amule-project/amule) is archived in `amule-<version>-<arch>.7z`, while the build package for [amule-dlp](https://github.com/persmule/amule-dlp) is archived in `amule-dlp-<date>-<arch>.7z`.
