MEMORY
{
    TEXT (rx)  : ORIGIN = 0x10000, LENGTH = 0x8000   /* 32KB for code */
    DATA (rw)  : ORIGIN = 0x18000, LENGTH = 0x8000   /* 32KB for data */
}
SECTIONS
{
    .text :
    {
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