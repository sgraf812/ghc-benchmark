FROM haskell:8.8.3
MAINTAINER Sebastian Graf <sgraf1337@gmail.com>

ENV PATH /root/.cabal/bin:$PATH
ARG DEBIAN_FRONTEND=noninteractive

RUN cabal update
RUN cabal install html regex-compat alex-3.2.5 happy

RUN apt-get update
RUN apt-get install --yes apt-transport-https ca-certificates wget
RUN apt-get --yes upgrade

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
RUN echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-10 main" >> /etc/apt/sources.list
RUN echo "deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-10 main" >> /etc/apt/sources.list

RUN apt-get update
RUN apt-get install --yes autoconf
RUN apt-get install --yes automake
RUN apt-get install --yes libtool
RUN apt-get install --yes make
RUN apt-get install --yes gcc
RUN apt-get install --yes g++
RUN apt-get install --yes libgmp-dev
RUN apt-get install --yes libncurses5-dev
RUN apt-get install --yes libffi-dev
RUN apt-get install --yes libtinfo-dev
RUN apt-get install --yes python3
RUN apt-get install --yes python-sphinx
RUN apt-get install --yes xz-utils
RUN apt-get install --yes valgrind
RUN apt-get install --yes time
RUN apt-get install --yes build-essential
RUN apt-key update
RUN apt-get install --yes --allow-unauthenticated llvm-10-dev

ARG M=0
RUN git clone https://gitlab.haskell.org/ghc/ghc.git
# master from 18 Feb 21
ARG BASE=f78f001c91736e31cdfb23959647226f9bd9fe6b
RUN git -C ghc/ fetch --all
RUN git -C ghc/ checkout $BASE
RUN git -C ghc/ submodule update --init --recursive
