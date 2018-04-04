#!/bin/bash

set -e

if [ $# -eq "0" ]; then
  DIFFS=$(find diffs -regex ".*\.diff" | xargs -i basename {} .diff)
else
  DIFFS=$@
fi

echo "Benchmarking the following diffs:"
echo $DIFFS

PWD=$(readlink -f $PWD)

mkdir -p $PWD/logs
mkdir -p $PWD/diffs
mkdir -p $PWD/scripts

docker build -t ghc-bench .

for diff in $DIFFS
do
  docker run -i --tty --rm -v $PWD/logs:/logs -v $PWD/diffs:/diffs -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-bench.sh $diff
done
