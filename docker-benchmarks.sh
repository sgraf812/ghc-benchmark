#!/bin/bash

set -e

sudo docker build -t ghc-bench .

mkdir -p $PWD/logs
mkdir -p $PWD/patches
mkdir -p $PWD/scripts

for p in patches/*
do
  name="$(basename $p .patch)"
  sudo docker run -i --tty --rm -v $PWD/logs:/logs -v $PWD/patches:/patches -v $PWD/scripts:/scripts ghc-bench /scripts/patch-and-run.sh $name
done
