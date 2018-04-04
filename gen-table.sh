#!/bin/bash

set -e

if [ $# -eq "0" ]; then
  diffs=$(find diffs -regex ".*\.diff" | xargs -i basename {} .diff)
else
  diffs=$@
fi

# We always want to include the base diff at the first position
tmp=base
# .. which means we have to filter all further occureces of 'base'.
for diff in $diffs
do
  if [ $diff != "base" ]; then
    # add to the list
    tmp="$tmp $diff"
  fi
done

diffs=$tmp

# There's no way I know of to just map a function over each element
# of a space-separated list inside in a variable. Hooray for sh!
logs=""
buildlogs=""
for diff in $diffs
do
  log=$(ls logs/$diff*.log|tail -n1)
  logs="$logs $log"
  buildlog=$(ls logs/buildlog-$diff*.log|tail -n1)
  buildlogs="$buildlogs $buildlog"
done

pruned=""
for log in $logs;
do
  sed '/==nofib== cacheprof/,/Finished making all in cacheprof/d' $log > $log-pruned
  pruned="$pruned $log-pruned"
done

nofib-analyse --columns=Allocs,Instrs -i 0.1  $pruned > nofib-table-all.txt
nofib-analyse --columns=Allocs,Instrs -l -i 0.1  $pruned | ./fixup.pl -0.3 0.0 1 > nofib-table.tex
nofib-analyse --columns=Allocs -l -i 0.1  $pruned | ./fixup.pl 0.0 0.0 1 > nofib-table-alloc.tex
nofib-analyse --columns=Instrs -l -i 0.1  $pruned | ./fixup.pl -3.0 1.0 0 > nofib-table-instrs.tex
nofib-analyse --columns="Comp. Alloc,Comp. Time" -l -i 0.1  $pruned | ./summary-only.pl $logs | grep 'Geometric' | sed -e 's/Geometric Mean/nofib/'> nofib-comp-table.tex

for log in $logs;
do
  rm -f $log-pruned
done

./buildlog.pl $buildlogs > ghc-comp-table.tex
