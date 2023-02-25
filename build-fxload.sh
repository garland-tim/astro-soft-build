#!/bin/bash

DIR=$(dirname "$0")

cd $DIR/fxload

cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/usr
cmake --build ./build
sudo cmake --install ./build
