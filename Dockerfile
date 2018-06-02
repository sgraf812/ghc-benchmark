FROM haskell:8.2.1
MAINTAINER Sebastian Graf <sgraf1337@gmail.com>

ENV PATH /root/.cabal/bin:$PATH

RUN cabal update
RUN cabal install html regex-compat

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

ENV BASE 5748c79e5a7a6bd1b0bfffc514d8f4f4da92e815
RUN git clone --recursive git://git.haskell.org/ghc.git
RUN git -C ghc/ checkout $BASE
RUN git -C ghc/ submodule update --init
