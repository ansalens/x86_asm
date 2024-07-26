# Understanding ELF, the Executable and Linkable Format

- __ELF (Executable and Linkable Format) file__.
- ELF object files contains:
    1. ELF header
    2. Section header and other sections
    3. Program header and other program sections
    4. Object code
    5. Debugging information


## ELF header

- Read ELF header of any file:

```sh
$ readelf -h prog
```

## ELF section header

- These sections are well-known already, `.text, .bss, .data, .debug, .shstrtab...`
- `.shstrtab` contains string constants.
- `.debug` contains debugging information.
- All variable and function names go into `.symtab` (symbol table).

- Show all sections in a program:

```sh
$ readelf -S prog
```

- Show symbol table of a program:

```sh
$ readelf -s prog
```


### Task

> This will dump all the code that is present in our study.c example. Try experimenting with objdump, hd and readelf commands to analyse each section of the ELF file. Modify the program, compile it and see how different information in the section changes. [ ]

# How does all this fit into bigger picture?

- Linker knows how to put all these ELF sections in final ELF file by using __linker descriptor file__.
- This descriptor file contains all information about the memory present on the PC and their size.
- Here's simplified example of linker descriptor file:

```
MEMORY
{
FLASH (rx) : ORIGIN = 0x0, LENGTH = 0x020
 
RAM (rwx) : ORIGIN = 0xA0, LENGTH = 0x00A0000 /* 640K */
}
 
ENTRY(Reset_Handler)
 
SECTIONS
 
{
. = 0x0000;
.text : { *(.text) }
. = 0xA0;
.data : { *(.data) }
.bss : { *(.bss) }
}
```
- It tells that there are two types of memory present, FLASH and RAM.
- It puts all executable code at the address `0x00000`
- It puts all data (`.data` and `.bss`) starting at `0xA0`

## ELF Program header

- The ELF program header tells which segments will be used at run-time.
- See the program header information with:

```sh
$ readelf -l prog
```

- *Show relocation section with `-r` switch, dynamic section with `-d`.*

## Linker

- Is responsible for creating final ELF file.
- It combines all sections from other object files into one final ELF file.
- It uses linker descriptor table, resolves all symbols.

## Program execution

- Ever wondered why `main()` is entry point into all your programs?
    - That's because startup code is always loaded by the linker and linked to your program.
    - This startup code calls your `main()`.

---

Source: https://www.opensourceforu.com/2020/02/understanding-elf-the-executable-and-linkable-format/
