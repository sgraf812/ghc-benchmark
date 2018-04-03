param([string]$Patch=$(throw "Patch parameter is required."))

docker build -t ghc-bench .

docker run -it --rm -v $PWD/logs:/logs -v $PWD/patches:/patches -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-validate.sh $Patch
