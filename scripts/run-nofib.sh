#! /usr/bin/env bash
test -d nofib || { echo "No nofib found" ; exit 1 ;  }

set -e
set -o pipefail

mode=norm
variant="-$mode"
clean=yes
threads=$(($(nproc --all) + 1))
cachegrindconf=--disable-large-address-space

echo variant: $variant

name="$(date +'%Y-%m-%d-%H-%M')"

diff="$(basename $PWD)"

echo name: $name

echo ready to go...

if [ "$clean" = yes ]
then
	make distclean
	echo "BuildFlavour = bench" | cat - mk/build.mk.sample > mk/build.mk
	perl boot
	./configure $cachegrindconf
	/usr/bin/time -o buildtime-$name make -j$threads 2>&1 |
		tee /logs/buildlog-$diff-$name.log
else
	make -C ghc 2 -j$threads
fi
cd nofib/
make clean
make boot
(make EXTRA_RUNTEST_OPTS='-cachegrind +RTS -V0 -RTS' EXTRA_HC_OPTS='-fllvm -optlo -Os' mode=$mode -j$threads NoFibRuns=1) 2>&1 | tee /logs/$diff-$name.log
# fix a problem with nofib logs from cachegrind
sed -i -e 's/,  L2 cache misses/, 0 L2 cache misses/' /logs/$diff-$name.log
