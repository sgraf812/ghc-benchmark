#!/bin/bash

set -e

if [ $# -eq "0" ]; then
  echo "Usage: $0 [diff-to-validate]"
  exit 1
fi

diff=$1; shift

echo "Validating the following diff:"
echo $diff

PWD=$(readlink -f $PWD)

mkdir -p $PWD/logs
mkdir -p $PWD/diffs
mkdir -p $PWD/scripts

docker build -t ghc-bench .

docker run -i --tty --rm -v $PWD/logs:/logs -v $PWD/diffs:/diffs -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-validate.sh $diff
