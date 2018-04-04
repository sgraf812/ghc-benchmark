#!/bin/bash

set -e

if [ $# -eq "0" ]; then
  DIFFS=$(find diffs -regex ".*\.diff" | xargs -i basename {} .diff)
else
  DIFFS=$@
fi

LOGS=$(readlink -f $PWD/logs)
DIFFS=$(readlink -f $PWD/diffs)
SCRIPTS=$(readlink -f $PWD/scripts)

mkdir -p $LOGS
mkdir -p $DIFFS
mkdir -p $SCRIPTS

docker build -t ghc-bench .

for diff in $DIFFS
do
  docker run -i --tty --rm -v $LOGS:/logs -v $DIFFS:/diffs -v $SCRIPTS:/scripts ghc-bench /scripts/patch-and-bench.sh $diff
done
