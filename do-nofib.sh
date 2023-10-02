#! /usr/bin/env bash

set -e
set -o pipefail

if [ -z "$1" ]
then
  echo "Usage: $0 <logfilename>"
  exit 1
fi

logfile=$1

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

# cabal new-run -- nofib-run --compiler=$(readlink -f ../inplace/bin/ghc-stage2) --cachegrind --threads=$threads --speed=$mode --times=1 --output=$logfile

# (make NoFibRuns=0) 2>&1 | tee $logfile
(make --keep-going EXTRA_RUNTEST_OPTS='-cachegrind' NoFibRuns=1 HC=$(readlink -f ../_build/stage1/bin/ghc)) 2>&1 | tee $logfile
# (make EXTRA_RUNTEST_OPTS='-cachegrind' EXTRA_HC_OPTS='-fllvm' NoFibRuns=1) 2>&1 | tee $logfile
# fix a problem with nofib logs from cachegrind
sed -i -e 's/,  L2 cache misses/, 0 L2 cache misses/' $logfile
