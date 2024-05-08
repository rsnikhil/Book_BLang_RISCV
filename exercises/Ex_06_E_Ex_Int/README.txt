A testbench for fn_EX_Int
=========================

// ----------------------------------------------------------------
(1)

Study and understand the code in Top.bsv.
It will be useful to 'diff':
    Ex_06_C_Dispatch/src_BSV/Top.bsv
    Ex_06_E_Ex_Int/src_BSV/Top.bsv
to see what has changed from the previous exercise.

// ----------------------------------------------------------------
(2)

Compile and run the code using Verilator simulation or Bluesim simulation.
Observe and understand the output.

The program fetches one 32-bit instruction from from address 0x_8000_0000.
(the particular instruction can be seen in file 'test.memhex32'.)

Locate this instruction in the "objdump" file:
    Code/Tools/Hello_World_Example_Code/hello.RV32.bare.objdump
which shows the assembly language code for the instruction.

For the instruction, we invoke 'a_rsp (0,0)'.
The two arguments represent the rs1 and rs2 values (which may or may
not be relevant for different int opcodes).

Verify that the 'fn_EX_Int()' outputs of the test program Top.bsv
agrees with your understanding of these instructions.

// ----------------------------------------------------------------
(3)

Create a test.memhex32 with just 4 bytes of data at 0x_8000_0000.
Edit the program to fetch just this one instruction.

Repeat:
* Edit the 4 bytes to represent a different integer instruction
    (try various Int opcodes, with different rs1 and rs2 values).
* Recompile and run, and verify that the fn_EX_Control output is as expected.

// ----------------------------------------------------------------
