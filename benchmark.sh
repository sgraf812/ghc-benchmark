#! /usr/bin/env bash

set -e

TOP=$(readlink -f $PWD)

if [ $# -eq "0" ]; then
  diffs=$(find $TOP/diffs -regex ".*\.diff" | xargs -i basename {} .diff)
else
  diffs=$@
fi

echo "Benchmarking the following diffs:"
echo $diffs

if ! git -C ghc/ rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo
  echo "======================================="
  echo "             Cloning GHC               "
  echo "======================================="
  echo
  echo "Will only be done once. Abort and change checked out base commit after this!"
  git clone --recurse-submodules -j8 git@gitlab.haskell.org:ghc/ghc.git ghc
fi

mkdir -p $TOP/logs
mkdir -p $TOP/diffs

for diff in $diffs
do
  nix develop ../nix -c $TOP/do-one-diff.sh $diff
done
