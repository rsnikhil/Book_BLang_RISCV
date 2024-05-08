A testbench for fn_Dispatch
===========================

// ----------------------------------------------------------------
(1)

Study and understand the code in Top.bsv.
It will be useful to 'diff':
    Ex_06_B_Decode/src_BSV/Top.bsv
    Ex_06_C_Dispatch/src_BSV/Top.bsv
to see what has changed from the previous exercise.

// ----------------------------------------------------------------
(2)

Compile and run the code using Verilator simulation or Bluesim simulation.
Observe and understand the output.

The program fetches a 32-bit instruction from address 0x_8000_0000
(the particular instruction can be seen in file 'test.memhex32').

Locate this instruction in the "objdump" file:
    Code/Tools/Hello_World_Example_Code/hello.RV32.bare.objdump
which shows the assembly language code for the instruction.

Verify that the 'fn_Dispatch()' output of the test program Top.bsv
agrees with your understanding of the assembly language.

// ----------------------------------------------------------------
(3)

The output of 'fn_Dispatch' (type Result_Dispatch) has four sub-structs:
   RR_to_Retire      to_Retire;
   RR_to_EX_Control  to_EX_Control;
   RR_to_EX          to_EX;
   Mem_Req           to_EX_DMem;

The to_Retire substruct has a field 'exec_tag' of type Exec_Tag.
The to_EX_Control sub-struct is only valid when exec_tag == EXEC_TAG_CONTROL.
The to_EX         sub-struct is only valid when exec_tag == EXEC_TAG_INT.
The to_EX_DMem    sub-struct is only valid when exec_tag == EXEC_TAG_DMEM.

The code $display's all the sub-structs.  Replace this code with
if-then-else's so that sub-structs are only $display'ed when they are
valid.

Recompile and run to verify the code is running correctly.

// ----------------------------------------------------------------
(4)

Repeat (2) for a few more instructions at addresses 'h_8000_0004, ...0008, ...

// ----------------------------------------------------------------
(5)

Repeat (2) for a few more instructions at:
* An unimplemented address (e.g., 'h_9_0000_0000)
* A misaligned address (e.g., 'h_8000_0002)

// ----------------------------------------------------------------
(6)

Create a test.memhex32 with just 4 bytes of data at 0x_8000_0000.
Edit the program to fetch just this one instruction.

Repeat:
* Edit the 4 bytes to represent an instruction that will take the test
      program into a different branch of the if-then-else's in fn_Dispatch.
* Recompile and run, and verify that the fn_Decode output is as expected.

// ----------------------------------------------------------------
