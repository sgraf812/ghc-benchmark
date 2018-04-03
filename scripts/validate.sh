set -e
set -o pipefail

name="$(date +'%Y-%m-%d-%H-%M')"
clean=yes
patch="$(basename $PWD)"

echo Running the testsuite
echo name: $name

echo ready to go...
#sleep 10

make distclean
./validate 2>&1 | 
    tee /logs/testlog-$patch-$name.log
