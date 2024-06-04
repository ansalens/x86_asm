# `ld`, `gcc`, `hexdump`, `objdump` already came with Manjaro
```terminal
$ sudo pacman -S binutils gcc util-linux
```

- I figured out which packages had those binaries with:
```terminal
$ pacman -Qo $(which ld)
/usr/bin/ld is owned by binutils 2.42+r91+g6224493e457-1
```
