#!/bin/bash
if (( $# != 1 )); then
    >&2 echo "Usage: $0 <buildtype:Release/Debug> "
    buildtype=Release
fi

buildtype=$1 # Release or Debug 

NCORES=4
unamestr=`uname`
if [[ "$unamestr" == "Linux" ]]; then
        NCORES=`grep -c ^processor /proc/cpuinfo`
fi

if [[ "$unamestr" == "Darwin" ]]; then
        NCORES=`sysctl -n hw.ncpu`
fi

# compile mmwis and hils

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
    cmake ../ -DCMAKE_C_COMPILER="$GCC" -DCMAKE_CXX_COMPILER="$GPP" -DCMAKE_BUILD_TYPE=${buildtype}
else
    cmake ../ -DCMAKE_C_COMPILER=$(which gcc) -DCMAKE_CXX_COMPILER=$(which g++) -DCMAKE_BUILD_TYPE=${buildtype}
fi

make -j $NCORES
cd ..

mkdir deploy
cp ./build/mmwis                                                         deploy/mmwis
if [ -f ./build/extern/struction/branch_reduce_convergence ]; then
        cp ./build/extern/struction/branch_reduce_convergence                    deploy/struction
fi
rm -rf build


