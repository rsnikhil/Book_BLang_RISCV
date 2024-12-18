// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package Top;

// ****************************************************************
// Ad hoc unit tests

// ****************************************************************
// Imports from libraries

import FIFOF        :: *;
import SpecialFIFOs :: *;
import StmtFSM      :: *;

// ----------------
// Imports from 'vendor' libs

import Cur_Cycle  :: *;
import GetPut_Aux :: *;
import Semi_FIFOF :: *;

// ----------------
// Local imports

import Utils       :: *;
import Instr_Bits  :: *;    // for funct5_LOAD/STORE ..
import Mem_Req_Rsp :: *;
import Inter_Stage :: *;    // for Retire_to_DMem_Commit

import Store_Buffer :: *;

// ****************************************************************
// Debugging aids

// Define DELAY as delay (10) to avoid pipelining (no interleaving of outputs)

// `define DELAY  delay (10)
`define DELAY  noAction

// Right-justified bit mask for given request size
function Bit #(64) fn_mask (Mem_Req_Size size);
   return case (size)
	     MEM_1B: 64'h_0000_0000_0000_00FF;
	     MEM_2B: 64'h_0000_0000_0000_FFFF;
	     MEM_4B: 64'h_0000_0000_FFFF_FFFF;
	     MEM_8B: 64'h_FFFF_FFFF_FFFF_FFFF;
	  endcase;
endfunction

// ****************************************************************

(* synthesize *)
module mkTop (Empty);

   FIFOF #(Mem_Req)               f_req_from_CPU    <- mkFIFOF;
   FIFOF #(Mem_Rsp)               f_rsp_to_CPU      <- mkFIFOF;
   FIFOF #(Retire_to_DMem_Commit) f_commit_from_CPU <- mkFIFOF;

   Store_Buffer_IFC #(4) sb <- mkStore_Buffer (to_FIFOF_O (f_req_from_CPU),
					       to_FIFOF_I (f_rsp_to_CPU),
					       to_FIFOF_O (f_commit_from_CPU));

   Reg #(Bit #(32)) rg_inum <- mkReg (0);

   // ================================================================
   // CPU-side stimulus (requests)

   function Stmt fs_req (Mem_Req_Type t, Mem_Req_Size s, Bit #(64) a, Bit #(64) d);
      seq
	 action
	    let req = Mem_Req {req_type: t,
			       size:     s,
			       addr:     a,
			       data:     d,
			       inum:     zeroExtend (rg_inum),
			       pc:       zeroExtend (rg_inum),
			       instr:    0};
	    f_req_from_CPU.enq (req);
	    rg_inum <= rg_inum + 1;
	    $display ("tb_req: ----------------");
	    $display ("tb_     ", fshow_Mem_Req (req));
	 endaction
	 `DELAY;
      endseq;
   endfunction

   function Stmt fs_commit (Bool c);
      seq
	 action
	    f_commit_from_CPU.enq (Retire_to_DMem_Commit {inum: 0, commit: c});
	    $display ("tb_commit: ---------------- ", fshow (c));
	 endaction
	 `DELAY;
      endseq;
   endfunction

   // ----------------------------------------------------------------
   // Simple series of loads

   Stmt test1 =
   seq
      fs_req (funct5_LOAD, MEM_1B, 0, ?);
      fs_req (funct5_LOAD, MEM_1B, 1, ?);
      fs_req (funct5_LOAD, MEM_1B, 2, ?);
      fs_req (funct5_LOAD, MEM_1B, 3, ?);
      fs_req (funct5_LOAD, MEM_1B, 4, ?);
      fs_req (funct5_LOAD, MEM_1B, 5, ?);
      fs_req (funct5_LOAD, MEM_1B, 6, ?);
      fs_req (funct5_LOAD, MEM_1B, 7, ?);
   endseq;

   // ----------------------------------------------------------------
   // Write to mem [0] and mem [2:0] and try a series of loads

   Stmt test2 =
   seq
      fs_req (funct5_STORE, MEM_1B, 0, 'hA0);  
      fs_req (funct5_STORE, MEM_2B, 2, 'hA3A2);

      fs_req (funct5_LOAD, MEM_1B, 0, ?);
      fs_req (funct5_LOAD, MEM_1B, 1, ?);
      fs_req (funct5_LOAD, MEM_1B, 2, ?);
      fs_req (funct5_LOAD, MEM_1B, 3, ?);

      fs_req (funct5_LOAD, MEM_2B, 0, ?);
      fs_req (funct5_LOAD, MEM_2B, 2, ?);

      fs_req (funct5_LOAD, MEM_4B, 0, ?);
      fs_req (funct5_LOAD, MEM_4B, 4, ?);

      fs_req (funct5_LOAD, MEM_8B, 0, ?);
   endseq;

   // ----------------------------------------------------------------
   // This is the most serious test
   // Write to mem [0] then series of loads, with discard and commit

   Stmt test3 =
   seq
      $display ("================ tb_test3: store");
      fs_req (funct5_STORE, MEM_1B, 0, 'hA0);  

      $display ("================ tb_test3: read sb version");
      fs_req (funct5_LOAD,  MEM_1B, 0, ?);    // Should read sb version
      fs_req (funct5_LOAD,  MEM_1B, 1, ?);    // Should read mem version

      // Discard
      $display ("================ tb_test3: discard");
      fs_commit (False);

      $display ("================ tb_test3: read original mem");
      fs_req (funct5_LOAD,  MEM_1B, 0, ?);
      fs_req (funct5_LOAD,  MEM_1B, 1, ?);

      $display ("================ tb_test3: store");
      fs_req (funct5_STORE, MEM_1B, 0, 'hA0);  

      $display ("================ tb_test3: read sb version");
      fs_req (funct5_LOAD,  MEM_1B, 0, ?);
      fs_req (funct5_LOAD,  MEM_1B, 1, ?);

      // Commit
      $display ("================ tb_test3: commit");
      fs_commit (True);

      $display ("================ tb_test3: read updated mem version");
      fs_req (funct5_LOAD,  MEM_1B, 0, ?);
      fs_req (funct5_LOAD,  MEM_1B, 1, ?);
   endseq;

   // ----------------------------------------------------------------
   // Force error: discard/commit on empty store-buffer

   Stmt test4 =
   seq
      $display ("================ tb_test4: non-mem request");
      fs_req (funct5_STORE, MEM_1B, 'h10, 'hA0);

      $display ("================ tb_test4: misaligned");
      fs_req (funct5_STORE, MEM_2B, 'h1, 'hA0);

      $display ("================ tb_test4: commit/discard on empty store buffer/");
      fs_commit (True);
   endseq;

   // ----------------------------------------------------------------
   // The test FSM

   let init_params = Initial_Params {flog:           InvalidFile,
				     pc_reset_value: 'h_8000_0000,
				     addr_base_mem:  'h_0,
				     size_B_mem:     'h_10};
   mkAutoFSM (seq
		 sb.init (init_params);
		 test3;
		 delay (10);
	      endseq);

   // ================================================================
   // CPU-side report and drain responses

   rule rl_cpu_drain_rsp;
      let rsp <- pop_o (to_FIFOF_O (f_rsp_to_CPU));
      $display ("tb_resp: ", fshow_Mem_Rsp (rsp, True));
   endrule

   // ================================================================
   // Memory-side

   Reg #(Bit #(64)) rg_mem <- mkReg ('h_B7_B6_B5_B4_B3_B2_B1_B0);

   rule rl_rd_mem (sb.fo_mem_req.first.req_type == funct5_LOAD);
      let req <- pop_o (sb.fo_mem_req);
      Bit #(6) shamt = { req.addr [2:0], 3'h0 };
      let rsp =  Mem_Rsp {rsp_type: MEM_RSP_OK,
			  data:     (rg_mem >> shamt),
			  req_type: req.req_type,
			  size:     req.size,
			  addr:     req.addr,
			  inum:     req.inum,
			  pc:       req.pc,
			  instr:    req.instr};
      sb.fi_mem_rsp.enq (rsp);

      $display ("tb_rd_mem:  ", fshow_Mem_Req (req));
      $display ("tb_         ", fshow_Mem_Rsp (rsp, True));
   endrule

   rule rl_wr_mem (sb.fo_mem_req.first.req_type == funct5_STORE);
      let req <- pop_o (sb.fo_mem_req);
      Bit #(6) shamt = { req.addr [2:0], 3'h0 };
      let      mask  = fn_mask (req.size) << shamt;

      // Update memory
      let data_old = rg_mem;
      let data_upd = req.data << shamt;
      let data_new = (data_old & (~ mask)) | (data_upd & mask);
      rg_mem <= data_new;

      let rsp =  Mem_Rsp {rsp_type: MEM_RSP_OK,
			  data:     0,
			  req_type: req.req_type,
			  size:     req.size,
			  addr:     req.addr,
			  inum:     req.inum,
			  pc:       req.pc,
			  instr:    req.instr};
      sb.fi_mem_rsp.enq (rsp);

      $display ("tb_wr_mem:  ", fshow_Mem_Req (req));
      $display ("tb_         ", fshow_Mem_Rsp (rsp, True));
      $display ("tb_         data old %016h", data_old);
      $display ("tb_         data new %016h", data_new);
   endrule

   // ================================================================

endmodule

// ****************************************************************

endpackage
