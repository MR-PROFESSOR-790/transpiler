ENTRY(_start)
MEMORY
{
  TEXT (rx) : ORIGIN = 0x10000, LENGTH = 0x10000
  DATA (rw) : ORIGIN = 0x20000, LENGTH = 0x10000
}
SECTIONS
{
  . = 0x10000;
  .text :
  {
    KEEP(runtime.o(.text.start))
    KEEP(runtime.o(.text))
    *(.text)
    *(.text.*)
  } > TEXT
  . = 0x20000;
  .rodata :
  {
    *(.rodata)
    *(.rodata.*)
  } > DATA
  .data :
  {
    *(.data)
    *(.data.*)
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
    *(.bss)
    *(.bss.*)
  } > DATA
  .tohost :
  {
    *(.tohost)
    tohost = .;
    . += 8;
    fromhost = .;
    . += 8;
  } > DATA
} 