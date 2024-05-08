A testbench for fn_Fetch
========================

// ----------------------------------------------------------------
(1)

Study and understand the code in Top.bsv.

As in Ex_05_B_Mem_Req_Rsp, the file 'test.memhex32' contains 16
instructions from the 'Hello World!' program starting at address
0x_8000_0000, and when the program is run, the statement:
    mems_devices.init (init_params);
will initialize the memory model and load it with this data.

// ----------------------------------------------------------------
(2)

Compile and run the code using Verilator simulation or Bluesim simulation.
Observe and understand the output.

// ----------------------------------------------------------------
(3)

Add a few more calls to 'a_req()' and 'a_rsp()' to fetch a few more
instructions from successive addresses 'h_8000_0004, ...0008, ...

Recompile and run; observe and understand the behavior.

// ----------------------------------------------------------------
(4)

Add a few more calls to 'a_req()' and 'a_rsp()' to fetch a few more
instructions from:
* An unimplemented address (e.g., 'h_9_0000_0000)
* A misaligned address (e.g., 'h_8000_0002)

Recompile and run; observe and understand the behavior.

// ----------------------------------------------------------------
(5)

In 'Top.bsv', the functions 'a_req()' and 'a_rsp()' are defined inside
module 'mkTop', after the instantiations of FIFOs 'f_req' and 'f_rsp'.

Move the instantiations of FIFOs 'f_req' and 'f_rsp' so that they come
_after_ the two functions.

Recompile and run; observe and understand the behavior.

// ----------------------------------------------------------------
(6) "Function arguments can be interfaces"

Move the two function definitions 'a_req()' and 'a_rsp()' to be
_outside_ and before module 'mkTop's definition, as follows:

* Add an argument to 'a_req':
    function Action a_req (... inum, FIFOF #(Mem_Reqs) f_reqs);
  and move this function out of the module, before the module, at the
  top-level of the package.

* Add an argument to 'a_rsp':
    function Action a_rsp (FIFOF #(Mem_Rsps) f_rsps);
  and move this function out of the module, before the module, at the
  top-level of the package.

In 'mkAutoFSM',
* in each invocation of 'a_req()', add 'f_reqs' as an argument
* in each invocation of 'a_rsp()', add 'f_rsps' as an argument

Recompile and run, and verify that the behavior is the same as before.

// ----------------------------------------------------------------
