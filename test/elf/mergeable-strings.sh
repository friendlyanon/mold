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
t=out/test/elf/$MACHINE/$testname
mkdir -p $t

# Skip if target is not x86-64
[ $MACHINE = x86_64 ] || { echo skipped; exit; }

cat <<'EOF' | $CC -o $t/a.o -c -x assembler -
  .text
  .globl main
main:
  sub $8, %rsp
  mov $.L.str+3, %rdi
  xor %rax, %rax
  call printf
  mov $.rodata.str1.1+16, %rdi
  xor %rax, %rax
  call printf
  xor %rax, %rax
  add $8, %rsp
  ret

  .section .rodata.str1.1, "aMS", @progbits, 1
  .string "bar"
.L.str:
  .string "xyzHello"
  .string "foo world\n"
EOF

$CC -B. -static -o $t/exe $t/a.o
$QEMU $t/exe | grep -q 'Hello world'

echo OK
