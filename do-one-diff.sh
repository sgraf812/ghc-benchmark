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

cd nofib/

git checkout master

cat << EOF | patch -p1 --ignore-whitespace
diff --git a/imaginary/Makefile b/imaginary/Makefile
index a38ff2a..d42cdbf 100644
--- a/imaginary/Makefile
+++ b/imaginary/Makefile
@@ -1,7 +1,7 @@
 TOP = ..
 include \$(TOP)/mk/boilerplate.mk

-SUBDIRS = bernouilli digits-of-e1 digits-of-e2 exp3_8 gen_regexps integrate \\
+SUBDIRS = bernouilli digits-of-e1 digits-of-e2 exp3_8 gen_regexps \\
 	  paraffins primes queens rfib tak wheel-sieve1 wheel-sieve2 x2n1 kahan

 include $(TOP)/mk/target.mk
diff --git a/real/Makefile b/real/Makefile
index 88b84e6..64a9e8e 100644
--- a/real/Makefile
+++ b/real/Makefile
@@ -3,7 +3,7 @@ include \$(TOP)/mk/boilerplate.mk

 SUBDIRS = anna bspt cacheprof compress compress2 fem fluid fulsom gamteb gg \\
           grep hidden hpg infer lift linear maillist mkhprog parser pic prolog \\
-          reptile rsa scs symalg veritas eff smallpt ben-raytrace
+          reptile rsa scs symalg veritas eff

 \#cacheprof causes very nondeterministic allocation
 OTHER_SUBDIRS = cacheprof
EOF

make boot

# cabal new-run -- nofib-run --compiler=$(readlink -f ../inplace/bin/ghc-stage2) --cachegrind --threads=$threads --speed=$mode --times=1 --output=$TOP/logs/$name-$timestamp

# (make NoFibRuns=0) 2>&1 | tee $TOP/logs/$name-$timestamp.log
(make --keep-going EXTRA_RUNTEST_OPTS='-cachegrind' NoFibRuns=1 HC=$(readlink -f ../_build/stage1/bin/ghc)) 2>&1 | tee $TOP/logs/$name-$timestamp.log
# (make EXTRA_RUNTEST_OPTS='-cachegrind' EXTRA_HC_OPTS='-fllvm' NoFibRuns=1) 2>&1 | tee $TOP/logs/$name-$timestamp.log
# fix a problem with nofib logs from cachegrind
sed -i -e 's/,  L2 cache misses/, 0 L2 cache misses/' $TOP/logs/$name-$timestamp.log

echo "Removing clone"
rm -rf $clone

echo "Finished!"
