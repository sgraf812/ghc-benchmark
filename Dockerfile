FROM haskell:8.4.3
MAINTAINER Sebastian Graf <sgraf1337@gmail.com>

ENV PATH /root/.cabal/bin:$PATH
ARG DEBIAN_FRONTEND=noninteractive

RUN cabal update
RUN cabal install html regex-compat alex happy

RUN echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-5.0 main" >> /etc/apt/sources.list
RUN echo "deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-5.0 main" >> /etc/apt/sources.list
RUN echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-6.0 main" >> /etc/apt/sources.list
RUN echo "deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-6.0 main" >> /etc/apt/sources.list

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
RUN apt-get install --yes --allow-unauthenticated llvm-5.0-dev
RUN apt-get install --yes --allow-unauthenticated llvm-6.0-dev

ARG BASE=0d2cdec78471728a0f2c487581d36acda68bb941
RUN git clone --recursive git://git.haskell.org/ghc.git
RUN git -C ghc/ checkout $BASE
RUN git -C ghc/ submodule update --init
