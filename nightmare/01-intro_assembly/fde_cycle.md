# Fetch, Decode, Execute cycle

## Fetch

- __PC (Program Counter)__ register is used to store current memory address.
- It first gets set to 0000, this is where it begins to look for instructions.
- __MAR (Memory Address Register)__ is used for storing a memory address from which data is fetched. It will also get set to 0000.
- A signal is sent through __address bus__ to RAM, the __control unit__ sends memory read signal.
- This memory read signal reads the data at the address (that is stored by MAR).
- This data (instruction) is stored in __MDR (Memory Data Register)__ through __data bus__.
- But because this data is an instruction it is also stored in __IR (Instruction Register)__.
- First instruction has been fetched, PC gets incremented by one, ready for another instruction at the start of next cycle.

## Decode

- This data from IR is then sent through data bus to the __CU (Control Unit)__.
- In there, it is split into two parts.
- First part is called __opcode or operation code__ which is actually the instruction that needs to be carried out.
- Second part is called __operand__ which is a memory address that needs to be read from or written to.
- CU translates opcodes into actual instructions.

## Execute

- The operand is copied from IR to MAR.
- The data at the specific address (e.g. 0100) is then pulled from RAM and put into MDR through data bus.
- This data is then passed to __Acc (Accumulator)__.

![executecycle](scrs/execute.gif)


## 2nd cycle

- Second cycle begins at 0001 which was set by PC.
- Instruction opcode and operand are placed into IR, PC gets incremented again.
- Instruction is decoded, data is placed in MAR, instruction is decoded to ADD.
- New data is fetched from RAM and stored into Acc, with the previous result.
- These values from accumulator are transferred to __ALU (Arithmetic Logic Unit)__, this is where calculation is done.
- Result is placed back into Acc.

![2nd](scrs/2ndcycle.gif)

## 3rd cycle

- Third cycle begins at 0010, stores data into IR, decodes the opcode into STORE.
- It takes result of addition in the accumulator and places it into RAM at the address of 0110.

![3rd](scrs/3rdcycle.gif)

---

#### Sources

1. https://web.archive.org/web/20230512174055/https://www.futurelearn.com/info/courses/how-computers-work/0/steps/49284
