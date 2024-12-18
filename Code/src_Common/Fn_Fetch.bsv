// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package Fn_Fetch;

// ****************************************************************
// Fetch stage

// ****************************************************************
// Imports from libraries

// None

// ----------------
// Local imports

import Utils       :: *;
import Arch        :: *;
import Instr_Bits  :: *;
import Mem_Req_Rsp :: *;
import Inter_Stage :: *;

// ****************************************************************
// Fetch: Functionality

typedef struct {                                // \blatex{Result_F}
   Fetch_to_Decode  to_D;
   Mem_Req          mem_req;
} Result_F
deriving (Bits, FShow);                         // \elatex{Result_F}

// This is actually a pure function; is ActionValue only to allow
// $display insertion for debugging
function ActionValue #(Result_F)                                     // \blatex{fn_Fetch}
         fn_Fetch (Bit #(XLEN)  pc,
		   Bit #(XLEN)  predicted_pc,    // \belide{19}
		   Epoch        epoch,           // \eelide
		   Bit #(64)    inum,
		   File         flog);           // \belide{19}
                                                 // \eelide
   actionvalue
      Result_F y = ?;
      // Info to next stage
      y.to_D = Fetch_to_Decode {pc:           pc,
				predicted_pc: predicted_pc,                   // \belide{32}
				epoch:        epoch,
				inum:         inum,
				// Debugger support
				halt_sentinel:False };                        // \eelide
      // Request to IMem
      y.mem_req = Mem_Req {req_type: funct5_LOAD,
			   size:     MEM_4B,
			   addr:     zeroExtend (pc),
			   data :    ?,
			   epoch:    epoch,            // Not required for Fetch
			   // Debugging
			   inum:     inum,
			   pc:       pc,                             // \belide{27}
			   instr:    ?};                             // \eelide
      return y;
   endactionvalue
endfunction                                                          //  \elatex{fn_Fetch}

// ****************************************************************
// Logging actions

function Action log_Fetch (File flog, Fetch_to_Decode to_D, Mem_Req mem_req);
   action
      wr_log (flog, $format ("CPU.Fetch:"));
      wr_log_cont (flog, $format ("    ", fshow_Fetch_to_Decode (to_D)));
      wr_log_cont (flog, $format ("    ", fshow_Mem_Req (mem_req)));
      ftrace (flog, to_D.inum, to_D.pc, 0, "F", $format(""));
   endaction
endfunction

function Action log_Redirect (File flog, Fetch_from_Retire x);
   action
      wr_log (flog, $format ("CPU.Redirect:"));
      wr_log_cont (flog, $format ("    ", fshow_Fetch_from_Retire (x)));
      ftrace (flog, x.inum, x.pc, x.instr, "Redir", $format(""));
   endaction
endfunction

// ****************************************************************

endpackage
