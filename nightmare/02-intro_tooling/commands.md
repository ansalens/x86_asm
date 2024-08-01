# Terminal commands for static analysis of programs

## `ldd`

- Usage:

```sh
$ ldd /bin/grep
        linux-vdso.so.1 (0x00007fffacdf3000)
        libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0x00007fc158040000)
        libc.so.6 => /usr/lib/libc.so.6 (0x00007fc157e54000)
        /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007fc158145000)
```

- This command when ran on executable prints __tree of shared libraries__ that are needed for the following program to run.
- It also prints hex address at which these dependencies are loaded.
- Never run `ldd` on unknown binaries as it may try executing malicious code in order to find dependency information.
- It's always safer to do instead:

```sh
$ objdump -p /bin/id | grep NEEDED
  NEEDED               libc.so.6
```

## `file`

- Usage:

```sh
$ file license_1.c
license_1.c: C source, ASCII text
$ file tools.md
tools.md: Unicode text, UTF-8 text
$ file /dev/null
/dev/null: character special (1/3)
```

- This command identifies file type through 3 different tests.
- Whenever a test succeeds, a file type is printed out.
- First test dabbles with `stat` syscall, second with magic bytes, third with text files.
- Interesting option is `-L` which follows symlinks.

## `strings`

- Usage:

```sh
$ strings -a license_1
/lib64/ld-linux-x86-64.so.2
libc.so.6
puts
printf
strcmp
__libc_start_main
__gmon_start__
GLIBC_2.2.5
UH-P
UH-P
[]A\A]A^A_
Checking License: %s
AAAA-Z10N-42-OK
```

- `strings` prints sequence of printable characters in a file.
- `-a` prints all data it can find in a file, all sections whether initialized or loaded doesn't matter.
- `-d` prints all strings from initialized, loaded data sections. Opposite of `-a` flag.
- The output with `-d` is shorter and contains less junk.
