#!/bin/bash
set -x

# Update sources.list to use old-releases
sed -i 's|http://archive.ubuntu.com/ubuntu/|http://old-releases.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

# Update package list and install essential build tools and dependencies
apt-get update
apt-get install -y \
    build-essential \
    libssl-dev \
    libboost-all-dev \
    wget \
    git \
    libglib2.0-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    libxml2-dev \
    libxpm-dev \
    libexpat-dev \
    zlib1g-dev

# Download and build Berkeley DB 4.8 from source
cd /tmp
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix

# Configure, build, and install Berkeley DB
../dist/configure --prefix=/usr/local --enable-cxx
make -j4
make install

# Set the correct include and library paths for Berkeley DB
export BDB_INCLUDE_PATH=/usr/local/include
export BDB_LIB_PATH=/usr/local/lib

# Install miniupnpc
cd /usr/local
wget http://miniupnp.tuxfamily.org/files/miniupnpc-1.6.tar.gz
tar -xzvf miniupnpc-1.6.tar.gz
cd miniupnpc-1.6
make -j4
make install

# Build wxWidgets from source
cd /usr/local
wget https://github.com/wxWidgets/wxWidgets/releases/download/v2.9.2/wxWidgets-2.9.2.tar.bz2
tar -xjvf wxWidgets-2.9.2.tar.bz2
cd wxWidgets-2.9.2
mkdir buildgtk
cd buildgtk
../configure --with-gtk \
    --enable-debug \
    --disable-shared \
    --enable-monolithic \
    --without-libpng \
    --disable-svg \
    --prefix=/usr/local
make -j4
make install
ldconfig

# Clone Bitcoin repository and checkout version 0.4.0
cd /root
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
git checkout tags/v0.4.0

# Modify the makefile to include the Berkeley DB paths and ensure correct wxWidgets paths
sed -i.bak \
    -e '/^CXXFLAGS=/ s|$| -I$BDB_INCLUDE_PATH| \\' \
    -e '/^LIBS=/ s|$| -L$BDB_LIB_PATH|' \
    -e 's|wx-config|/usr/local/bin/wx-config|g' \
    /root/bitcoin/src/makefile.unix

# Build Bitcoin with GUI
cd src
make -f makefile.unix USE_UPNP=1 \
    BDB_INCLUDE_PATH=${BDB_INCLUDE_PATH} \
    BDB_LIB_PATH=${BDB_LIB_PATH} \
    -j4 bitcoind

echo "Bitcoin build completed successfully."