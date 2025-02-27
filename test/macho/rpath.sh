#!/bin/bash
export LC_ALL=C
set -e
CC="${TEST_CC:-cc}"
CXX="${TEST_CXX:-c++}"
GCC="${TEST_GCC:-gcc}"
GXX="${TEST_GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
t=out/test/macho/$MACHINE/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -c -xc -
int main() {}
EOF

clang --ld-path=./ld64 -o $t/exe $t/a.o -Wl,-rpath,foo -Wl,-rpath,@bar
otool -l $t/exe > $t/log

grep -A3 'cmd LC_RPATH' $t/log | grep -q 'path foo'
grep -A3 'cmd LC_RPATH' $t/log | grep -q 'path @bar'

echo OK
