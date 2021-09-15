#!/bin/bash

export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

INDI_COMMIT="8647cdd1c750142b437f9b331cfad60d6ee39ea9"
INDI_3RD_COMMIT="ec46f582618823e418d9f11f3ea5de2cf2f83e98"
STELLAR_COMMIT="65d2327e1ab90fa92b42287812ab278e86a37bbc"
KSTARS_COMMIT="7b8d9a153d937237c55a4f319c6d340c9ee6dc0c"

ROOTDIR="$HOME/astro-soft-stable"

JOBS=$(grep -c ^processor /proc/cpuinfo)

[ ! -d "$ROOTDIR" ] && mkdir $ROOTDIR
cd "$ROOTDIR"

[ ! -d "indi" ] && git clone https://github.com/indilib/indi.git
cd indi
git fetch origin
git checkout $INDI_COMMIT
[ ! -d ../build-indi ] && { cmake -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI failed"; exit 1; } }
cd ../build-indi
make -j $JOBS || { echo "INDI failed"; exit 1; }
sudo make install || { echo "INDI failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi-3rdparty" ] && git clone https://github.com/indilib/indi-3rdparty.git
cd indi-3rdparty
git fetch origin
git checkout $INDI_3RD_COMMIT
[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib failed"; exit 1; } }
cd ../build-indi-lib
make -j $JOBS || { echo "INDI lib failed"; exit 1; }
sudo make install || { echo "INDI lib failed"; exit 1; }

[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib failed"; exit 1; } }
cd ../build-indi-3rdparty
make -j $JOBS || { echo "INDI 3rd-party failed"; exit 1; }
sudo make install || { echo "INDI lib failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "stellarsolver" ] && git clone https://github.com/rlancaste/stellarsolver.git
cd stellarsolver
git fetch origin
git checkout $STELLAR_COMMIT
[ ! -d ../build-stellarsolver ] && { cmake -B ../build-stellarsolver ../stellarsolver -DCMAKE_BUILD_TYPE=Release || { echo "Stellarsolfer failed"; exit 1; } }
cd ../build-stellarsolver
make -j $JOBS || { echo "Stellarsolver failed"; exit 1; }
sudo make install || { echo "Stellarsolver failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "kstars" ] && git clone https://invent.kde.org/education/kstars.git
cd kstars
git fetch origin
git checkout $KSTARS_COMMIT
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
