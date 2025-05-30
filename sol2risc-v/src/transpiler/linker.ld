ENTRY(_start)
MEMORY
{
  TEXT (rx) : ORIGIN = 0x10000, LENGTH = 0xa710
  DATA (rw) : ORIGIN = 0x1a710, LENGTH = 0x20000  /* Up to 0x3a710 */
}
SECTIONS
{
  . = 0x10000;  /* Force all sections to start at 0x10000 */
  .text :
  {
    KEEP(runtime.o(.text))
    *(.text)
    *(.text.*)
  } > TEXT
  .rodata :
  {
    *(.rodata)
    *(.rodata.*)
  } > TEXT
  .data :
  {
    *(.data)
    *(.data.*)
  } > DATA
  .bss :
  {
    . = ALIGN(32);  /* Align for 256-bit stack slots, if needed */
    evm_stack = .;  /* Define evm_stack symbol */
    . += 4096;      /* Reserve 4096 bytes for stack */
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