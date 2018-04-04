set -e
set -o pipefail

name="$(date +'%Y-%m-%d-%H-%M')"
clean=yes
diff="$(basename $PWD)"

echo Running the testsuite
echo name: $name

echo ready to go...
#sleep 10

make distclean
./validate 2>&1 |
    tee /logs/testlog-$diff-$name.log
