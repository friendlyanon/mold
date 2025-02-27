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
#include <stdio.h>
void hello() {
  printf("Hello world\n");
}
EOF

cat <<EOF | $CC -o $t/b.o -c -xc -
void hello();
int main() {
  hello();
}
EOF

clang --ld-path=./ld64 -o $t/exe $t/a.o $t/b.o -Wl,-map,$t/map

grep -Eq '^\[  0\] .*/a.o$' $t/map
grep -Eq '^\[  1\] .*/b.o$' $t/map
grep -Eq '^0x[0-9A-Fa-f]+     0x[0-9A-Fa-f]+      __TEXT  __text$' $t/map
grep -Eq '^0x[0-9A-Fa-f]+     0x[0-9A-Fa-f]+      \[  0\] _hello$' $t/map
grep -Eq '^0x[0-9A-Fa-f]+     0x[0-9A-Fa-f]+      \[  1\] _main$' $t/map

echo OK
