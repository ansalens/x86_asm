# Registers

- Registers are the __fastest__ way of passing around data, __faster than the CPU cache memory.__
- x86 has 8 registers, x86_64 has 16 registers.
- Here are most notable ones:

1. EAX - multipurpose, often used for returning data
2. EBX - multipurpose, first argument in calling functions
3. ECX - often used as a counter
4. EDX - often used as a I/O pointer
5. ESI - source index
6. EDI - destination index
7. EBP - base pointer
8. ESP - stack pointer
9. EIP - instruction pointer

- More about ![registers](../../tasks/registers/x86general.md)

## Program Counter & Instruction Pointer & Instruction Counter

- All these are the same thing.
- *It's a special purpose register that holds the memory address that is currently being executed.*
- Processors fetch instructions from memory sequentially, but control flow and functions change that.


## Different classes of registers

1. Accumulator
    - Stores data that is fetched from memory.
2. MAR (Memory Address Register)
    - Stores the address of a location ready to be accessed.
3. MDR (Memory Data Register)
    - Stores data that will be used to write into or read from particular memory location.
4. GPR (General Purpose Registers)
    - Used for many purposes, including saving temporary data.
5. PC (Program Counter)
    - Contains the memory address of an instruction that is currently executed.
    - In x86 gets incremented by 4 at the end of *fetch stage*.
6. IR (Instruction Register)
    - Instruction is fetched from PC and stored into IR.
    - Contains an instruction that will be executed by the CPU.
7. ESP (Stack Pointer)
    - Points to the top of the stack.
8. ![EFLAG](../../tasks/flags/control_flow.md) (Flag Register)
    - Used for defining states of the CPU after executing some instruction.

- Notice that today modern computers use 64-bit or 32-bit registers.
- That's why we call them 64 bit or 32 bit processors.
- There are special CPUs that can have 128-bit or 256 bit registers.
- These are mainly used for cryptography.

---

#### Sources

1. https://github.com/hoppersroppers/nightmare/blob/master/modules/01-intro_assembly/assembly/registers.md
2. https://www.geeksforgeeks.org/different-classes-of-cpu-registers/
