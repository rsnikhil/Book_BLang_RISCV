// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package Top;

// ****************************************************************
// Imports from libraries

import FIFOF        :: *;
import BRAM         :: *;

// ----------------
// Imports from 'vendor' libs

import Cur_Cycle :: *;
import Semi_FIFOF :: *;

// ----------------
// Local imports

import Utils       :: *;
import Mem_Req_Rsp :: *;
import CPU_IFC     :: *;
import CPU         :: *;

import Mems_Devices :: *;
import Dbg_Stub     :: *;

// ****************************************************************

(* synthesize *)                                                // \blatex{mkTop}
module mkTop (Empty);
   Reg #(File) rg_logfile <- mkReg (InvalidFile);                   // \belide{3}
                                                                    // \eelide
   // Instantiate the CPU
   CPU_IFC cpu <- mkCPU;

   // Instantiate the memory model
   Mems_Devices_IFC mems_devices <- mkMems_Devices (cpu.fo_IMem_req,
						    cpu.fi_IMem_rsp,
						    cpu.fo_DMem_S_req,         // \belide{52}
						    cpu.fi_DMem_S_rsp,
						    cpu.fo_DMem_S_commit,      // \eelide
						    cpu.fo_DMem_req,
						    cpu.fi_DMem_rsp,
						    cpu.fo_dbg_to_mem_req,     // \belide{52}
						    cpu.fi_dbg_from_mem_rsp);  // \eelide
                                                                // \elatex{mkTop}
   Dbg_Stub_IFC dbg_stub <- mkDbg_Stub (cpu.fi_dbg_to_CPU_pkt,
					cpu.fo_dbg_from_CPU_pkt);

   Reg #(int) rg_top_step <- mkReg (0);    // Sequences startup steps

   // ****************************************************************
   // BEHAVIOR

   // ================================================================
   // Startup sequence

   // Show banner and open logfile
   rule rl_step0 (rg_top_step == 0);
      $display ("================================================================");
      $display ("Simulation top-level.  Command-line options:");
      $display ("  +debug    Start under control of remote debugger (EDB/GDB/... over TCP)");
      $display ("  +log      Generate log (trace) file (can become large!)");

      let log <- $test$plusargs ("log");
      File f = InvalidFile;
      if (log) begin
	 $display ("INFO: Logfile is: log.txt");
	 f <- $fopen ("log.txt", "w");
      end
      else
	 $display ("INFO: No logfile");
      rg_logfile  <= f;


      rg_top_step <= 1;
   endrule

                                                                // \blatex{Top_init}
   // Initialize modules
   rule rl_step1 (rg_top_step == 1);
      let with_debugger <- $test$plusargs ("debug");


      let init_params = Initial_Params {flog:              rg_logfile,
					pc_reset_value:    'h_8000_0000,
					addr_base_mem:     'h_8000_0000,
					size_B_mem:        'h_1000_0000,
					dbg_listen_socket: (with_debugger ? 30000 : 0)};
      cpu.init (init_params);
      mems_devices.init (init_params);
      dbg_stub.init (init_params);
                                                                    // \belide{6}
      rg_top_step <= 2;
   endrule                                                          // \eelide
                                                                // \elatex{Top_init}
   // Get ready to run
   rule rl_step2 (rg_top_step == 2);
      $display ("================================================================");
      rg_top_step <= 3;
   endrule

   // ... system running

   Integer cycle_limit = 0;    // Use 0 for no-limit

   rule rg_step3 (rg_top_step == 3);
      // Quit if reached cycle-limit
      let x <- cur_cycle;
      if ((cycle_limit > 0) && (x > fromInteger (cycle_limit))) begin
	 $display ("================================================================");
         $display ("Quit (reached cycle_limit %0d)", cycle_limit);
	 rg_top_step <= 4;
      end
   endrule

   rule rl_step4 (rg_top_step == 4);
      $finish (0);
   endrule

   // ================================================================
   // Relay MTIME to CPU's CSRs module
                                                                // \blatex{Top_relay_time}
   (* fire_when_enabled, no_implicit_conditions *)
   rule rl_relay_MTIME;
      let t <- mems_devices.rd_MTIME;
      cpu.set_TIME (t);
   endrule
                                                                // \elatex{Top_relay_time}
   // ================================================================
   // Relay MTIP to CPU's CSRs module

   (* fire_when_enabled, no_implicit_conditions *)
   rule rl_relay_MTIP;
      let t = mems_devices.mv_MTIP;
      cpu.set_MIP_MTIP (t);
   endrule

   // ================================================================
   // INTERFACE

   // Empty
endmodule

// ****************************************************************

endpackage
