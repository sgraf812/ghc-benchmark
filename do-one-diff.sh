#! /usr/bin/env bash

set -e
set -o pipefail

TOP=$(readlink -f "$(dirname $0)")

if [ -z "$1" ]
then
  echo "Usage: $0 <diffbasename>"
  exit 1
fi

if [ ! -e $TOP/diffs/$1.diff ]
then
  echo "No $TOP/diffs/$1.diff"
  exit 1
fi

echo
echo "======================================="
echo "            Prepare clone              "
echo "======================================="
echo

clone=$(mktemp -d /tmp/ghc-benchmark-$1-XXXXXXXX)
clone="$clone/$1" # $1 will be used as the name in the logs
echo "Copying $TOP/ghc to $clone"
cp -r $TOP/ghc/. $clone

cd $clone
echo "Patching using $TOP/diffs/$1.diff"
# git diff makes patch fail sometimes... We'll try to compile nonetheless
patch -p1 < $TOP/diffs/$1.diff

echo
echo "======================================="
echo "             Build GHC                 "
echo "======================================="
echo

test -d nofib || { echo "No nofib found" ; exit 1 ;  }

export mode=norm # export for NoFib
variant="-$mode"
threads=$(($(nproc --all) + 1))

echo variant: $variant

timestamp="$(date +'%Y-%m-%d-%H-%M')"

name="$(basename $PWD)"

echo timestamp: $timestamp

echo ready to go...

echo $(pwd)

perl ./boot
sh ./configure ${CONFIGURE_ARGS} # --disable-large-address-space
/usr/bin/time -o $TOP/logs/buildtime-$name-$timestamp hadrian/build -j$threads --flavour='perf+no_profiled_libs+no_dynamic_ghc' 2>&1 | \
	tee $TOP/logs/buildlog-$name-$timestamp.log

echo
echo "======================================="
echo "              Run nofib                "
echo "======================================="
echo

./do-nofib.sh "$TOP/logs/$name-$timestamp.log"

echo "Removing clone"
rm -rf $clone

echo "Finished!"
