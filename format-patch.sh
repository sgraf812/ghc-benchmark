set -e

if [ -z "$1" ]
then
  echo "Usage: $0 <ghc-fork>"
  exit 1
fi

forkdir=$1; shift

mkdir -p patches

git -C $forkdir format-patch 922db3dac896b8cf364c9ebaebf1a27c2468c709 --stdout > patches/$(git -C $forkdir rev-parse --abbrev-ref HEAD).patch
