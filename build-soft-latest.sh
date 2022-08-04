#!/bin/bash

export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

CHECKOUT=0
ROOTDIR="$HOME/astro-soft"

JOBS=$(grep -c ^processor /proc/cpuinfo)
# 64 bit systems need more memory for compilation
if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
then
	echo "Low memory limiting to JOBS=2"
	JOBS=2
fi

[ ! -d "$ROOTDIR" ] && mkdir $ROOTDIR
cd "$ROOTDIR"

[ ! -d "indi" ] && git clone --depth=1 https://github.com/indilib/indi.git
cd indi
git pull origin
[ ! -d ../build-indi ] && { cmake -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI failed"; exit 1; } }
cd ../build-indi
make -j $JOBS || { echo "INDI failed"; exit 1; }
sudo make install || { echo "INDI failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi-3rdparty" ] && git clone --depth=1 https://github.com/indilib/indi-3rdparty.git
cd indi-3rdparty
git pull origin
[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib failed"; exit 1; } }
cd ../build-indi-lib
make -j $JOBS || { echo "INDI lib failed"; exit 1; }
sudo make install || { echo "INDI lib failed"; exit 1; }

[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib failed"; exit 1; } }
cd ../build-indi-3rdparty
make -j $JOBS || { echo "INDI 3rd-party failed"; exit 1; }
sudo make install || { echo "INDI lib failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "stellarsolver" ] && git clone --depth=1 https://github.com/rlancaste/stellarsolver.git
cd stellarsolver
git pull origin
[ ! -d ../build-stellarsolver ] && { cmake -B ../build-stellarsolver ../stellarsolver -DCMAKE_BUILD_TYPE=Release || { echo "Stellarsolfer failed"; exit 1; } }
cd ../build-stellarsolver
make -j $JOBS || { echo "Stellarsolver failed"; exit 1; }
sudo make install || { echo "Stellarsolver failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "kstars" ] && git clone --depth=1 https://invent.kde.org/education/kstars.git
cd kstars
git pull origin
[ ! -d ../build-kstars ] && { cmake -B ../build-kstars -DBUILD_TESTING=Off ../kstars -DCMAKE_BUILD_TYPE=Release || { echo "KStars failed"; exit 1; } }
cd ../build-kstars
make -j $JOBS || { echo "KStars failed"; exit 1; }
sudo make install || { echo "KStars failed"; exit 1; }

exit
cd "$ROOTDIR"
[ ! -d "phd2" ] && git clone --depth=1 https://github.com/OpenPHDGuiding/phd2.git
cd phd2
[ $CHECKOUT == 1 ] && git pull origin
[ ! -d ../build-phd2 ] && cmake -B ../build-phd2 ../phd2 -DCMAKE_BUILD_TYPE=Release || { echo "PHD2 failed"; exit 1; }
cd ../build-phd2 || { echo "PHD2 failed"; exit 1; }
make -j $JOBS || { echo "PHD2 failed"; exit 1; }
sudo make install
