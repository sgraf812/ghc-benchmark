# `ghc-benchmark`

This is a harness I stole from Joachim Breitner (@nomeata) for reproducible, CI-like `NoFib` runs.

# Setup

1. Make sure you have Nix installed
2. Checkout the appropriate base commit in `ghc/`
3. Add your diff to `diffs/` (leave the `base.diff` untouched, unless you don't want to compare to the baseline commit). This may come from Phabricator, which is the result of `arc diff`, or just do `git diff > faster.diff` in your local working copy. The file name must match `$DIFF.diff`, where `$DIFF` is used to identify your patch in generated files and in the eventual output.

# Benchmark

Run `./benchmark.sh`.

This will benchmark **all** `diffs/` anew on every run. It will use cachegrind to count instructions and only run each benchmark once, so measured Runtimes will be garbage (they would be on Windows anyway due to VM overhead). This is also the default behavior for https://perf.haskell.org/ghc.

If you just want to re-run selected diffs because you amended some changes, pass them as arguments: `./docker-benchmark.sh $DIFF1 $DIFF2`.

You can find buildlogs (`buildlog-$DIFF-<timestamp>.log`) and logs from the `NoFib` run (`$DIFF-<timestamp>.log`) in `logs/`. You probably want to feed these to `nofib-analyse`.

# `gen-tables.sh`

To automate the invocation of `nofib-analyse`, try `./gen-tables.sh`. This will (re-)generate select reports by taking the most recent log file of every diff it can find. To generate reports that only mention a subset of diffs, do `gen-tables.sh $DIFF1 $DIFF2`. The `base` diff will always be used as baseline.

You can see how various the `.tex` and `.txt` reports are built by invoking `nofib-analyse` in `gen-tables.sh`. The analysed output is passed to the `fixup.pl` script, which takes care of weeding out insignificant changes for readability. Play around with the threshold parameters to find a setting you like.
