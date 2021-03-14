#!/bin/bash

export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

INDI_COMMIT="8fdc1ce3989c36914450f3fd851ba6e3261ccc99"
INDI_3RD_COMMIT="f8972ed47f56fd52e083d8450ec2b43f4f03c60a"
STELLAR_COMMIT="820befc37cd84d2a79135ee538c403fe34490de0"
KSTARS_COMMIT="2e6e42f95e0511bad3d16242f4ef487032f0740b"

ROOTDIR="$HOME/astro-soft-stable"

[ ! -d "$ROOTDIR" ] && mkdir $ROOTDIR
cd "$ROOTDIR"

[ ! -d "indi" ] && git clone https://github.com/indilib/indi.git
cd indi
git fetch origin
git checkout $INDI_COMMIT
[ ! -d ../build-indi ] && { cmake -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI failed"; exit 1; } }
cd ../build-indi
make -j 4 || { echo "INDI failed"; exit 1; }
sudo make install || { echo "INDI failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi-3rdparty" ] && git clone https://github.com/indilib/indi-3rdparty.git
cd indi-3rdparty
git fetch origin
git checkout $INDI_3RD_COMMIT
[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib failed"; exit 1; } }
cd ../build-indi-lib
make -j 4 || { echo "INDI lib failed"; exit 1; }
sudo make install || { echo "INDI lib failed"; exit 1; }

[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib failed"; exit 1; } }
cd ../build-indi-3rdparty
make -j 4 || { echo "INDI 3rd-party failed"; exit 1; }
sudo make install || { echo "INDI lib failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "stellarsolver" ] && git clone https://github.com/rlancaste/stellarsolver.git
cd stellarsolver
git fetch origin
git checkout $STELLAR_COMMIT
[ ! -d ../build-stellarsolver ] && { cmake -B ../build-stellarsolver ../stellarsolver -DCMAKE_BUILD_TYPE=Release || { echo "Stellarsolfer failed"; exit 1; } }
cd ../build-stellarsolver
make -j 4 || { echo "Stellarsolver failed"; exit 1; }
sudo make install || { echo "Stellarsolver failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "kstars" ] && git clone https://invent.kde.org/education/kstars.git
cd kstars
git checkout 
[ ! -d ../build-kstars ] && { cmake -B ../build-kstars -DBUILD_TESTING=Off ../kstars -DCMAKE_BUILD_TYPE=Release || { echo "KStars failed"; exit 1; } }
cd ../build-kstars
make -j 4 || { echo "KStars failed"; exit 1; }
sudo make install || { echo "KStars failed"; exit 1; }

exit
cd "$ROOTDIR"
[ ! -d "phd2" ] && git clone --depth=1 https://github.com/OpenPHDGuiding/phd2.git
cd phd2
[ $CHECKOUT == 1 ] && git pull origin
[ ! -d ../build-phd2 ] && cmake -B ../build-phd2 ../phd2 -DCMAKE_BUILD_TYPE=Release || { echo "PHD2 failed"; exit 1; }
cd ../build-phd2 || { echo "PHD2 failed"; exit 1; }
make -j 4 || { echo "PHD2 failed"; exit 1; }
sudo make install
