#!/bin/bash

set -e

if [ -z "$1" ]
then
  echo "Usage: $0 <diffbasename>"
  exit 1
fi

if [ ! -e /diffs/$1.diff ]
then
  echo "No /diffs/$1.diff"
  exit 1
fi

echo "Copying /ghc to $1"
cp -r /ghc $1
cd $1
echo "Patching using /diffs/$1.diff"
# git diff makes patch fail sometimes... We'll try to compile nonetheless
patch -p1 < /diffs/$1.diff
echo "Running nofib"
/scripts/run-nofib.sh

