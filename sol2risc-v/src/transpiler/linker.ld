ENTRY(_start)

MEMORY
{
  TEXT (rx) : ORIGIN = 0x10000, LENGTH = 0x10000
  DATA (rw) : ORIGIN = 0x20000, LENGTH = 0x10000
}
SECTIONS
{
  . = 0x10000;
  .text.start :
  {
    KEEP(runtime.o(.text.start))  /* _start */
  } > TEXT
  .text :
  {
    . = ALIGN(4);                 /* Ensure 4-byte alignment */
    KEEP(runtime.o(.text))        /* clear_memory */
    KEEP(output.o(.text.evm_entry))  /* evm_entry */
    *(.text .text.*)              /* Other text sections */
  } > TEXT
  . = 0x20000;
  .data :
  {
    KEEP(*(.data .data.*))
  } > DATA
  .rodata :
  {
    *(.rodata .rodata.*)
  } > DATA
  .evm_memory :
  {
    . = ALIGN(32);
    evm_memory = .;
    . += 0x4000;
  } > DATA
  .bss :
  {
    . = ALIGN(32);
    evm_stack = .;
    . += 4096;
    *(.bss .bss.*)
  } > DATA
  .tohost :
  {
    *(.tohost)
    tohost = .;
    . += 8;
    fromhost = .;
    . += 8;
  } > DATA
  /DISCARD/ :
  {
    *(.comment)
    *(.eh_frame)
    *(.note*)
  }
}