import sys

offsets = [ 
  0x0000000000000001, 0x0000000000000009, 0x0000000000000011,
  0x0000000000000027, 0x0000000000000002, 0x0000000000000000,
  0x0000000000000012, 0x0000000000000003, 0x0000000000000008,
  0x0000000000000012, 0x0000000000000009, 0x0000000000000012,
  0x0000000000000011, 0x0000000000000001, 0x0000000000000003,
  0x0000000000000013, 0x0000000000000004, 0x0000000000000003,
  0x0000000000000005, 0x0000000000000015, 0x000000000000002e,
  0x000000000000000a, 0x0000000000000003, 0x000000000000000a,
  0x0000000000000012, 0x0000000000000003, 0x0000000000000001,
  0x000000000000002e, 0x0000000000000016, 0x000000000000002e,
  0x000000000000000a, 0x0000000000000012, 0x0000000000000006
]
desired_output = [
  0x00000077, 0x00000066, 0x0000007b, 0x0000005f, 0x0000006e,
  0x00000079, 0x0000007d, 0xffffffff, 0x00000062, 0x0000006c,
  0x00000072, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
  0xffffffff, 0xffffffff, 0x00000061, 0x00000065, 0x00000069,
  0xffffffff, 0x0000006f, 0x00000074, 0xffffffff, 0xffffffff,
  0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
  0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
  0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000067,
  0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
  0xffffffff, 0x00000075
  ]

# create a character set of flag string
def create_charset():
    charset = ''
    for c in desired_output:
        try:
            c = chr(c)
            if c not in charset:
                charset += c
        except OverflowError:
            continue

    return charset


# set and return variable i to an offset
def validate_char(c):
    i = 0
    while (c != desired_output[i]):
        if (c <= desired_output[i]):
            i = (i * 2) + 1
        else:
            i = (i + 1) * 2
    return i


charset = create_charset()
i = 0
while (i < 33):
    for c in charset:
        a = validate_char(ord(c))
        if a == offsets[i]:
            print(c, end='')
            break
    i += 1

