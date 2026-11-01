#!/bin/sh
set -e
cd "$(dirname "$0")"
BIN=toolchain/xpack-riscv-none-elf-gcc-15.2.0-1/bin/riscv-none-elf-
FLAGS="-march=rv32im -mabi=ilp32 -std=c99 -ffreestanding -fno-builtin -nostdlib -Wall -Wextra"
SRC=${1:-src/main.c}
NAME=$(basename "$SRC" .c)
mkdir -p build
for O in O0 O1; do
    ${BIN}gcc $FLAGS -$O -S -fverbose-asm -o build/${NAME}_$O.s "$SRC"
    ${BIN}gcc $FLAGS -$O -g -Wl,-Ttext=0x10000,--no-relax-gp,--no-warn-rwx-segments -o build/${NAME}_$O.elf src/start.s "$SRC"
    ${BIN}objdump -d -M no-aliases,numeric build/${NAME}_$O.elf > build/${NAME}_${O}_objdump.txt
    ${BIN}objdump -d -S build/${NAME}_$O.elf > build/${NAME}_${O}_source.txt
    ${BIN}objdump -h build/${NAME}_$O.elf > build/${NAME}_${O}_sections.txt
    ${BIN}nm -n build/${NAME}_$O.elf > build/${NAME}_${O}_symbols.txt
done
echo "built: $(ls build | tr '\n' ' ')"
