ENTRY(_start)
MEMORY
{
  TEXT (rx) : ORIGIN = 0x10000, LENGTH = 0xa710
  DATA (rw) : ORIGIN = 0x1a710, LENGTH = 0x6000
}
SECTIONS
{
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