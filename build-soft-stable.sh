#!/bin/bash

export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

LIBXISF_COMMIT="v0.2.11"
INDI_COMMIT="v2.0.6"
INDI_3RD_COMMIT="v2.0.6"
STELLAR_COMMIT="e415e51d99224f239c24634519c030ef60969723"
KSTARS_COMMIT="origin/stable-3.6.9"

# you can set custom BUILD_DIR
BUILD_DIR=${BUILD_DIR:-$HOME}
ROOTDIR="$BUILD_DIR/astro-soft-stable"

JOBS=$(grep -c ^processor /proc/cpuinfo)

# 64 bit systems need more memory for compilation
if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
then
	echo "Low memory limiting to JOBS=2"
	JOBS=2
fi

[ ! -d "$ROOTDIR" ] && mkdir -p "$ROOTDIR"
cd "$ROOTDIR"

[ ! -d "libXISF" ] && git clone https://gitea.nouspiro.space/nou/libXISF.git
cd libXISF
git fetch origin
git switch -d --discard-changes $LIBXISF_COMMIT
[ ! -d ../build-libXISF ] && { cmake -B ../build-libXISF ../libXISF -DCMAKE_BUILD_TYPE=Release || { echo "LibXISF configuration failed"; exit 1; } }
cd ../build-libXISF
make -j $JOBS || { echo "LibXISF compilation failed"; exit 1; }
sudo make install || { echo "LibXISF installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi" ] && git clone https://github.com/indilib/indi.git
cd indi
git fetch origin
git switch -d --discard-changes $INDI_COMMIT
[ ! -d ../build-indi ] && { cmake -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI configuration failed"; exit 1; } }
cd ../build-indi
make -j $JOBS || { echo "INDI compilation failed"; exit 1; }
sudo make install || { echo "INDI installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi-3rdparty" ] && git clone https://github.com/indilib/indi-3rdparty.git
cd indi-3rdparty
git fetch origin
git switch -d --discard-changes $INDI_3RD_COMMIT
[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
cd ../build-indi-lib
make -j $JOBS || { echo "INDI lib compilation failed"; exit 1; }
sudo make install || { echo "INDI lib installation failed"; exit 1; }

[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
cd ../build-indi-3rdparty
make -j $JOBS || { echo "INDI 3rd-party compilation failed"; exit 1; }
sudo make install || { echo "INDI lib installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "stellarsolver" ] && git clone https://github.com/rlancaste/stellarsolver.git
cd stellarsolver
git fetch origin
git switch -d --discard-changes $STELLAR_COMMIT
[ ! -d ../build-stellarsolver ] && { cmake -B ../build-stellarsolver ../stellarsolver -DCMAKE_BUILD_TYPE=Release || { echo "Stellarsolfer configuration failed"; exit 1; } }
cd ../build-stellarsolver
make -j $JOBS || { echo "Stellarsolver compilation failed"; exit 1; }
sudo make install || { echo "Stellarsolver installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "kstars" ] && git clone https://invent.kde.org/education/kstars.git
cd kstars
git fetch origin
git switch -d --discard-changes $KSTARS_COMMIT
[ ! -d ../build-kstars ] && { cmake -B ../build-kstars -DBUILD_TESTING=Off ../kstars -DCMAKE_BUILD_TYPE=Release || { echo "KStars configuration failed"; exit 1; } }
cd ../build-kstars
make -j $JOBS || { echo "KStars compilation failed"; exit 1; }
sudo make install || { echo "KStars installation failed"; exit 1; }

sudo ldconfig

[ "$1" != "phd2" ] && exit

cd "$ROOTDIR"
[ ! -d "phd2" ] && git clone https://github.com/OpenPHDGuiding/phd2.git
cd phd2
git fetch origin
git switch -d --discard-changes "v2.6.12"
[ ! -d ../build-phd2 ] && cmake -B ../build-phd2 -DCMAKE_BUILD_TYPE=Release || { echo "PHD2 configuration failed"; exit 1; }
cd ../build-phd2
make -j $JOBS || { echo "PHD2 compilation failed"; exit 1; }
sudo make install

