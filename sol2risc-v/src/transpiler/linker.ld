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
    KEEP(*(.text.start))  /* _start */
  } > TEXT
  .text :
  {
    KEEP(*(.text))        /* clear_memory, evm_entry */
    *(.text.*)
  } > TEXT
  . = 0x20000;
  .data :
  {
    KEEP(*(.data .data.*))  /* calldata_size */
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