docker build -t ghc-bench .

foreach($p in gci patches/*) {
    docker run -it --rm -v $PWD/logs:/logs -v $PWD/patches:/patches -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-bench.sh $p.BaseName
}
