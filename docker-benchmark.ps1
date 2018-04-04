param(
    [Parameter(Position=0)]
    [string[]]$diffs=$(Get-ChildItem diffs/*.diff | ForEach-Object { $_.BaseName })
)

Write-Verbose "Benchmarking the following diffs:"
Write-Verbose $diffs

docker build -t ghc-bench .

foreach($d in $diffs) {
    docker run -it --rm -v $PWD/logs:/logs -v $PWD/diffs:/diffs -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-bench.sh $d
}
