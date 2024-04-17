FROM debian:latest as builder

RUN buildDeps='g++ python3 python3-jinja2 python3-jsonschema automake cmake make patch bison flex libtool git wget gettext texinfo p7zip-full pkg-config autopoint bzip2' \
    && apt update \
    && apt install -y $buildDeps \
    && wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz \
    && tar xf autoconf-2.69.tar.xz \
    && cd autoconf-2.69 \
    && ./configure --prefix=/usr \
    && make install \
    && mkdir /build

VOLUME /build