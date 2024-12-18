// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package Mem_Req_Rsp;

// ****************************************************************

import Arch        :: *;
import Instr_Bits  :: *;
import Inter_Stage :: *;

// ****************************************************************
// Memory requests

// See Instr_Bits for funct5 codes for LOAD/STORE/AMOs
// (we use original funct5s for AMOs, and add two more codes for LOAD/STORE)
                                                                // \blatex{Mem_Req_Type}
typedef Bit #(5) Mem_Req_Type;
                                                                // \elatex{Mem_Req_Type}

function Fmt fshow_Mem_Req_Type (Mem_Req_Type mrt);
   return case (mrt)
	     funct5_LOAD:    $format ("LOAD");
	     funct5_STORE:   $format ("STORE");
	     funct5_FENCE:   $format ("FENCE");
	     funct5_FENCE_I: $format ("FENCE.I");

	     funct5_LR:      $format ("LR");
	     funct5_SC:      $format ("SC");
	     funct5_AMOSWAP: $format ("AMOSWAP");
	     funct5_AMOADD:  $format ("AMOADD");
	     funct5_AMOXOR:  $format ("AMOXOR");
	     funct5_AMOAND:  $format ("AMOAND");
	     funct5_AMOOR:   $format ("AMOOR");
	     funct5_AMOMIN:  $format ("AMOMIN");
	     funct5_AMOMAX:  $format ("AMOMAX");
	     funct5_AMOMINU: $format ("AMOMINU");
	     funct5_AMOMAXU: $format ("AMOMAXU");
	     default:	     $format ("<unknown Mem_Req_Type %0h", mrt);
	  endcase;
endfunction

typedef enum {MEM_1B, MEM_2B, MEM_4B, MEM_8B} Mem_Req_Size    // \blatex{Mem_Req_Size}
deriving (Bits, FShow, Eq);                                   // \elatex{Mem_Req_Size}

typedef struct {Mem_Req_Type  req_type;                       // \blatex{Mem_Req}
		Mem_Req_Size  size;
		Bit #(64)     addr;
		Bit #(64)     data;     // CPU => mem data
                                                                // \belide{16}
		Epoch         epoch;    // Fife only: for store-buffer matching

		Bit #(64)     inum;     // for debugging only
		Bit #(XLEN)   pc;       // for debugging only
		Bit #(32)     instr;    // for debugging only      \eelide
} Mem_Req
deriving (Bits, FShow);                                       // \elatex{Mem_Req}

// ----------------

function Bool misaligned (Mem_Req  mem_req);
   let addr = mem_req.addr;
   return case (mem_req.size)
	     MEM_1B: False;
	     MEM_2B: addr[0]   != 0;
	     MEM_4B: addr[1:0] != 0;
	     MEM_8B: addr[2:0] != 0;
	  endcase;
endfunction

// ****************************************************************
// Memory responses

typedef enum {MEM_RSP_OK,                                // \blatex{Mem_Rsp_Type}
	      MEM_RSP_MISALIGNED,
	      MEM_RSP_ERR,
                                                         //   \belide{14}
	      MEM_REQ_DEFERRED    // DMem only, for accesses that must be non-speculative
                                                         //   \eelide
} Mem_Rsp_Type
deriving (Bits, FShow, Eq);                              // \elatex{Mem_Rsp_Type}

typedef struct {Mem_Rsp_Type  rsp_type;                        // \blatex{Mem_Rsp}
		Bit #(64)     data;      // mem => CPU data
                                                                 //  \belide{16}
		// Copied from mem_req, for debugging only
		Mem_Req_Type  req_type;
		Mem_Req_Size  size;
		Bit #(64)     addr;

		Bit #(64)     inum;     // for debugging only
		Bit #(XLEN)   pc;       // for debugging only
		Bit #(32)     instr;    // for debugging only    // \eelide
} Mem_Rsp
deriving (Bits, FShow);                                        // \elatex{Mem_Rsp}

// ****************************************************************
// Alternate fshow functions

function Fmt fshow_Mem_Req_Size (Mem_Req_Size x);
   let fmt = case (x)
		MEM_1B: $format ("1B");
		MEM_2B: $format ("2B");
		MEM_4B: $format ("4B");
		MEM_8B: $format ("8B");
	     endcase;
   return fmt;
endfunction

function Fmt fshow_Mem_Req (Mem_Req x);
   let fmt = $format ("    Mem_Req {I_%0d pc:%08h instr:%08h ", x.inum, x.pc, x.instr);
   fmt = fmt + fshow_Mem_Req_Type (x.req_type);
   fmt = fmt + $format (" ");
   fmt = fmt + fshow_Mem_Req_Size (x.size);
   fmt = fmt + $format (" addr:%08h", x.addr);
   if ((x.req_type != funct5_LOAD)
       && (x.req_type != funct5_LR)
       && (x.req_type != funct5_FENCE)
       && (x.req_type != funct5_FENCE_I))
      fmt = fmt + $format (" data:%08h", x.data);
   fmt = fmt + $format (" epoch:%0d}", x.epoch);
   return fmt;
endfunction

function Fmt fshow_Mem_Rsp (Mem_Rsp x, Bool show_data);
   let fmt = $format ("    Mem_Rsp {I_%0d pc:%08h instr:%08h ", x.inum, x.pc, x.instr);
   fmt = fmt + fshow_Mem_Req_Type (x.req_type);
   fmt = fmt + $format (" ");
   fmt = fmt + fshow_Mem_Req_Size (x.size);
   fmt = fmt + $format (" addr:%08h ", x.addr);
   fmt = fmt + fshow (x.rsp_type);
   if (show_data)
      fmt = fmt + $format (" data:%08h", x.data);
   fmt = fmt + $format ("}");
   return fmt;
endfunction

// ****************************************************************

endpackage
