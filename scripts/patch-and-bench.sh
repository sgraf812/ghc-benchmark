#!/bin/bash

set -e

if [ -z "$1" ]
then
  echo "Usage: $0 <patchbasename>"
  exit 1
fi

if [ ! -e /patches/$1.patch ]
then
  echo "No /patches/$1.patch"
  exit 1
fi

echo "Copying /ghc to $1"
cp -r /ghc $1
cd $1
echo "Patching using /patches/$1.patch"
patch -p1 < /patches/$1.patch || true
echo "Running nofib"
/scripts/run-nofib.sh

