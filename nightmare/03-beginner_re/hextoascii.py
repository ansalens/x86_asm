hexstring = input("Enter hex string without '0x' (616263): ")

print(bytearray.fromhex(hexstring).decode())
