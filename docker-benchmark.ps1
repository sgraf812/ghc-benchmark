param(
    [Parameter(Position=0)]
    [string[]]$diffs=$(gci diffs/*.diff | % { $_.BaseName })
)

docker build -t ghc-bench .

foreach($d in $diffs) {
    docker run -it --rm -v $PWD/logs:/logs -v $PWD/diffs:/diffs -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-bench.sh $d
}
