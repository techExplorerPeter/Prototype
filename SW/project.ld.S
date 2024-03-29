/*
 * SPDX-License-Identifier:     BSD-3-Clause
 *
 * Copyright 2021-2022 NXP
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

#ifdef CUSTOM_START_ADDR
START_ADDR = CUSTOM_START_ADDR;
#else
START_ADDR = 0x3408E000;
#endif

#define VTOR_ALIGNMENT	128

SECTIONS
{
 . = START_ADDR;
 . = ALIGN(VTOR_ALIGNMENT); /* VTOR must be aligned to 128 bytes */
 .vtable :
 {
  *vector.o (.vtable*)
  *(.vtable*)
 }
.data :
 {
  *(.data*)
 }
 .text :
 {
  *start.o (.text*)
  *(.text*)
 }
  .rodata :
 {
  *(.rodata*)
 }
 .bss :
 {
  *(.bss*)
 }

 _stack_end = .;
 _stack_start = START_ADDR + 0x20000 - VTOR_ALIGNMENT;//0x2000 is total size of M7 core allocate

 /DISCARD/ : { *(.dynsym) }
 /DISCARD/ : { *(.dynstr*) }
 /DISCARD/ : { *(.dynamic*) }
 /DISCARD/ : { *(.plt*) }
 /DISCARD/ : { *(.interp*) }
 /DISCARD/ : { *(.gnu*) }
}
