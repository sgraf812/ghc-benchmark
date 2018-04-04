param([string]$diff=$(throw "diff parameter is required."))

docker build -t ghc-bench .

docker run -it --rm -v $PWD/logs:/logs -v $PWD/diffs:/diffs -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-validate.sh $diff
