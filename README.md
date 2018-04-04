# `ghc-benchmark`

This is a harness I stole from Joachim Breitner (@nomeata) for reproducible, CI-like `NoFib` runs and `./validate`s based on Docker.
I use this on both Windows (`docker-*.ps1`) and Linux machines (`docker-*.sh`)

# Setup

1. Make sure you have Docker installed. The following commands need a sudo prefix unless you are in the [`docker` group](https://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo) (Doesn't apply to PowerShell scripts, obviously). You also need GNU `coreutils` for `readlink` on Linux, as well as [`nofib-analyse`](https://hackage.haskell.org/package/nofib-analyse).
2. Edit the the `$BASE` definition in `Dockerfile` to match your baseline GHC commit
3. Add your diff to `diffs/` (leave the `base.diff` untouched, unless you don't want to compare to the baseline commit). This may come from Phabricator, which is the result of `arc diff`, or just do `git diff > faster.diff` in your local working copy. The file name must match `$DIFF.diff`, where `$DIFF` is used to identify your patch in generated files and in the eventual output.

# Validate

Windows (well, PowerShell) only. I don't think this is necessary on a Linux box where `./validate` works as expected.

This will `./validate` the diff named `$DIFF.diff` in `diffs/`. Just run `.\docker-validate.ps1 $DIFF`.

# Benchmark

Run `./docker-benchmark.{sh,ps1}`.

This will benchmark **all** `diffs/` anew on every run. It will use cachegrind to count instructions and only run each benchmark once, so measured Runtimes will be garbage (they would be on Windows anyway due to VM overhead). This is also the default behavior for https://perf.haskell.org/ghc.

If you just want to re-run selected diffs because you amended some changes, pass them as arguments: `./docker-benchmark.{sh,ps1} $DIFF1 $DIFF2` (PS users will need to separate with commas).

You can see how various `.tex` and `.txt` are built by invoking `nofib-analyse` in `gen-tables.sh`. The analysed output is passed to the `fixup.pl` script, which takes care of weeding out insignificant changes for readability. Play around with the threshold parameters to find a setting you like.
