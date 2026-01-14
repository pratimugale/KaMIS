#!/bin/bash

NCORES=4
unamestr=`uname`
if [[ "$unamestr" == "Linux" ]]; then
        NCORES=`grep -c ^processor /proc/cpuinfo`
fi

if [[ "$unamestr" == "Darwin" ]]; then
        NCORES=`sysctl -n hw.ncpu`
fi

rm -rf deploy
rm -rf build
mkdir build
cd build

# Use Homebrew g++ on macOS, system g++ on Linux
if [[ "$unamestr" == "Darwin" ]]; then
    # Try to find Homebrew g++ (g++-15, g++-14, g++-13, etc.)
    GPP=""
    GCC=""
    BREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/usr/local")
    for version in 15 14 13 12 11; do
        if [ -f "$BREW_PREFIX/bin/g++-$version" ]; then
            GPP="$BREW_PREFIX/bin/g++-$version"
            GCC="$BREW_PREFIX/bin/gcc-$version"
            echo "Using compiler: $GPP"
            break
        fi
    done
    if [ -z "$GPP" ]; then
        echo "Warning: Homebrew g++ not found, using system compiler (may fail)"
        GPP=$(which g++)
        GCC=$(which gcc)
    fi
    cmake ../ -DCMAKE_C_COMPILER="$GCC" -DCMAKE_CXX_COMPILER="$GPP"
else
    cmake ../
fi

make -j $NCORES
cd ..


# compile mmwis:
cd mmwis
./compile.sh
cd ..

mkdir deploy
cp ./mmwis/deploy/mmwis deploy/
if [ -f ./mmwis/deploy/struction ]; then
        cp ./mmwis/deploy/struction deploy/
fi
cp ./build/redumis deploy/
cp ./build/graphchecker deploy/
cp ./build/sort_adjacencies deploy/
cp ./build/online_mis deploy/
cp ./build/wmis/branch_reduce  deploy/weighted_branch_reduce
#cp ./build/wmis/merge_graph_weights deploy/
cp ./build/wmis/weighted_ls deploy/weighted_local_search

rm -rf build
