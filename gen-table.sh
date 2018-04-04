#!/bin/bash

set -e

logs="$(ls logs/base*.log|tail -n 1) \
      $(ls logs/and-or*.log|tail -n 1)"

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

buildlogs="$(ls logs/buildlog-base*|tail -n 1) \
      $(ls logs/buildlog-and-or*|tail -n 1)"
./buildlog.pl $buildlogs > ghc-comp-table.tex
