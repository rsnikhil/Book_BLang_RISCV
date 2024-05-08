A testbench for fn_EX_Control
=============================

// ----------------------------------------------------------------
(1)

Study and understand the code in Top.bsv.
It will be useful to 'diff':
    Ex_06_C_Dispatch/src_BSV/Top.bsv
    Ex_06_D_Ex_Control/src_BSV/Top.bsv
to see what has changed from the previous exercise.

// ----------------------------------------------------------------
(2)

Compile and run the code using Verilator simulation or Bluesim simulation.
Observe and understand the output.

The program fetches three 32-bit instructions, one from from address
0x_8000_0000 and two from 0x_8000_003c.
(the particular instructions can be seen in file 'test.memhex32'.)

Locate these instructions in the "objdump" file:
    Code/Tools/Hello_World_Example_Code/hello.RV32.bare.objdump
which shows the assembly language code for the instructions.
Observe that the first of the two instructions is not a control
instruction, and the second is a control instruction (BNE).

For the two BNE instructions, we invoke 'a_rsp (0,0)' and 'a_rsp (0,1)'.
The two arguments represent the rs1 and rs2 values.
BNE should be False for the first one, True for the second.
The next PC will be different for the two cases.

Verify that the 'fn_EX_Control()' outputs of the test program Top.bsv
agrees with your understanding of these instructions.

// ----------------------------------------------------------------
(3)

Create a test.memhex32 with just 4 bytes of data at 0x_8000_0000.
Edit the program to fetch just this one instruction.

Repeat:
* Edit the 4 bytes to represent a different control instruction.
    (try BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, and JALR)
* Recompile and run, and verify that the fn_EX_Control output is as expected.

// ----------------------------------------------------------------
