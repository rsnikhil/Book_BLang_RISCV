// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package Inter_Stage;

// ****************************************************************
// Imports from libraries

import Vector :: *;

// ----------------
// Local imports

import Arch       :: *;
import Instr_Bits :: *;
import CSR_Bits   :: *;

// ****************************************************************
// Pipeline forward flow

typedef 2              W_Epoch;
typedef Bit #(W_Epoch) Epoch;

// ================================================================
// Fetch => Decode

typedef struct {                                                // \blatex{Fetch_to_Decode}
   Bit #(XLEN)  pc;
                                                                //     \belide
   Bit #(XLEN)  predicted_pc;    // Fife only: for branch-prediction
   Epoch        epoch;           // Fife only: for branch-prediction
                                                                //     \eelide
   Bit #(64)    inum;            // for debugging only
   // Debugger support
   Bool         halt_sentinel;
} Fetch_to_Decode
deriving (Bits, FShow);                                         // \elatex{Fetch_to_Decode}

// ================================================================
// Decode => Register Read
                                                                // \blatex{OpClass}
typedef enum {OPCLASS_SYSTEM,     // EBREAK, ECALL, CSRRxx
              OPCLASS_CONTROL,    // BRANCH, JAL, JALR
	      OPCLASS_INT,
	      OPCLASS_MEM,        // LOAD, STORE, AMO
	      OPCLASS_FENCE}      // FENCE
OpClass
deriving (Bits, Eq, FShow);                                     // \elatex{OpClass}

typedef struct {Bit #(XLEN)  pc;                                // \blatex{Decode_to_RR}

		Bool         exception;  // Fetch exception/ decode illegal instr
		Bit #(4)     cause;
		Bit #(XLEN)  tval;

		// If not exception
		Bit #(XLEN)  fallthru_pc;
		Bit #(32)    instr;
                OpClass      opclass;
		Bool         has_rs1;
		Bool         has_rs2;
		Bool         has_rd;
		Bool         writes_mem;   // All mem ops other than LOAD
		Bit #(XLEN)  imm;          // Canonical (bit-swizzled)
                                                                        // \belide
		Bit #(XLEN)  predicted_pc; // For branch-prediction only
		Epoch        epoch;        // For branch-prediction only
		Bit #(64)    inum;         // for debugging only           \eelide

		// Debugger support
		Bool         halt_sentinel;
} Decode_to_RR
deriving (Bits, FShow);                                       // \elatex{Decode_to_RR}

// ================================================================
// Register Read => Retire Direct
// Controls Retire's merge of results from execution pipelines

typedef enum {EXEC_TAG_DIRECT,                // \blatex{Exec_Tag}
	      EXEC_TAG_CONTROL,
	      EXEC_TAG_INT,
	      EXEC_TAG_DMEM
} Exec_Tag
deriving (Bits, Eq, FShow);                   // \elatex{Exec_Tag}

                                                                //   \blatex{RR_to_Retire}
typedef struct {Exec_Tag     exec_tag;    // ``flow'' for this instr

		Bit #(XLEN)  pc;
		Bool         has_rd;      // From RR
		Bool         writes_mem;  // From RR

		Bool         exception;   // Fetch exception, decode illegal instr
		Bit #(4)     cause;
		Bit #(XLEN)  tval;

		// If not exception
		Bit #(32)    instr;
		Bit #(XLEN)  fallthru_pc;
		Bit #(XLEN)  rs1_val;     // For CSRRXX instrs

 		Bit #(XLEN)  predicted_pc;  // For branch-prediction only    \belide{16}
		Epoch        epoch;         // for branch-prediction only    \eelide

		Bit #(64)    inum;            // for debugging only

		// Debugger support
		Bool         halt_sentinel;
} RR_to_Retire
deriving (Bits, FShow);                                         //   \elatex{RR_to_Retire}

// ================================================================
// Register Read => EX_Control => Retire

// ---------------- Register Read => EX_Control (BR/JAL/JALR)

typedef struct {Bit #(XLEN)  pc;                             // \blatex{RR_to_EX_Control}
		Bit #(XLEN)  fallthru_pc;
		Bit #(32)    instr;
		Bit #(XLEN)  rs1_val;
		Bit #(XLEN)  rs2_val;
		Bit #(XLEN)  imm;
		Bit #(64)    inum;    // for debugging only
} RR_to_EX_Control
deriving (Bits, FShow);                                      // \elatex{RR_to_EX_Control}

// ---------------- EX_Control => Retire
                                                       // \blatex{EX_Control_to_Retire}
typedef struct {Bool         exception;  // Misaligned BRANCH/JAL/JALR target
		Bit #(4)     cause;
		Bit #(XLEN)  tval;

		Bit #(XLEN)  next_pc;
		Bit #(XLEN)  data;          // Return-PC for JAL/JALR
                                                       // \belide{16}
		// for debugging only
		Bit #(32)    instr;
		Bit #(64)    inum;
		Bit #(XLEN)  pc;                       // \eelide
} EX_Control_to_Retire
deriving (Bits, FShow);                                // \elatex{EX_Control_to_Retire}

// ================================================================
// Register Read => Execute pipes (Int, IMUL, FALU, DMem, ...) => Retire

// ---------------- Register Read => EX

typedef struct {Bit #(32)    instr;               // \blatex{RR_to_EX}
		Bit #(XLEN)  rs1_val;
		Bit #(XLEN)  rs2_val;
		Bit #(XLEN)  imm;
                                                  // \belide{16}
		// for debugging only
		Bit #(64)    inum;
		Bit #(XLEN)  pc;                  // \eelide
} RR_to_EX
deriving (Bits, FShow);                           // \elatex{RR_to_EX}

// ---------------- EX => Retire

typedef struct {Bool         exception;               // \blatex{EX_to_Retire}
		Bit #(4)     cause;
		Bit #(XLEN)  tval;

		Bit #(XLEN)  data;
                                                      // \belide{16}
		// for debugging only
		Bit #(64)    inum;
		Bit #(XLEN)  pc;
		Bit #(32)    instr;                   // \eelide
} EX_to_Retire
deriving (Bits, FShow);                               // \elatex{EX_to_Retire}

// ================================================================
// Retire => DMem commit/discard (store-buffer)

typedef struct {Bit #(64) inum;
		Bool      commit;    // True:commit, False:discard
} Retire_to_DMem_Commit
deriving (Bits, FShow);

// ****************************************************************
// Pipeline backward flows

// ---------------- Fetch <= Retire (redirect)

typedef struct {Bit #(64)   inum;     // for debugging only
		Bit #(XLEN) pc;       // for debugging only
		Bit #(32)   instr;    // for debugging only
		Bool        haltreq;  // for debugger control only

		Bit #(XLEN) next_pc;
		Epoch       next_epoch;
} Fetch_from_Retire
deriving (Bits, FShow);

// ---------------- Register Write <= Retire (writeback)

typedef struct {Bit #(64)   inum;    // for debugging only
		Bit #(XLEN) pc;      // For debugging only
		Bit #(32)   instr;   // for debugging only
		Bit #(5)    rd;
		Bool        commit;    // True: write rd and release scoreboard reservation
		                       // False: just release scoreboard reservation
		Bit #(XLEN) data;
} RW_from_Retire
deriving (Bits, FShow);

// ****************************************************************
// ****************************************************************
// ****************************************************************
// Messages between debugger and CPU

// WARNING! WARNING! WARNING!
//   These packets are exchanged with C code (debugger, debugger stub).
//   There is no type-checking across the BSV-C boundary.
//   Make sure that packets are re-coded correctly across the boundary!

// ================================================================
// Debugger to CPU packets

typedef enum {Dbg_to_CPU_NOOP,
              Dbg_to_CPU_RESUMEREQ,
              Dbg_to_CPU_HALTREQ,
              Dbg_to_CPU_RW,
              Dbg_to_CPU_QUIT}     Dbg_to_CPU_Pkt_type
deriving (Bits, Eq, FShow);

typedef enum {Dbg_RW_GPR, Dbg_RW_FPR, Dbg_RW_CSR, Dbg_RW_MEM} Dbg_RW_Target
   deriving (Bits, Eq, FShow);

typedef enum {Dbg_RW_READ, Dbg_RW_WRITE}                      Dbg_RW_Op
   deriving (Bits, Eq, FShow);

typedef enum {Dbg_MEM_1B, Dbg_MEM_2B, Dbg_MEM_4B, Dbg_MEM_8B} Dbg_RW_Size
   deriving (Bits, Eq, FShow);

typedef struct {
   Dbg_to_CPU_Pkt_type  pkt_type;
   // The remaining fields are only relevant for RW requests
   Dbg_RW_Target        rw_target;
   Dbg_RW_Op            rw_op;
   Dbg_RW_Size          rw_size;
   Bit #(XLEN)          rw_addr;
   Bit #(XLEN)          rw_wdata;
} Dbg_to_CPU_Pkt
deriving (Bits, FShow);

// ================================================================
// Debugger from CPU

typedef enum {Dbg_from_CPU_RESUMEACK,
              Dbg_from_CPU_RUNNING,
              Dbg_from_CPU_HALTED,
              Dbg_from_CPU_RW_OK,
              Dbg_from_CPU_ERR}      Dbg_from_CPU_Pkt_type
deriving (Bits, Eq, FShow);

typedef struct {
   Dbg_from_CPU_Pkt_type  pkt_type;
   Bit #(XLEN)            payload;  // read-data   in RW_OK  resp for RW:RW_READ req
                                    // error-code  in ERR    responses
                                    // unused/don't care otherwise
} Dbg_from_CPU_Pkt
deriving (Bits, FShow);

// ****************************************************************
// ****************************************************************
// ****************************************************************
// Specialized fshow functions

function Fmt fshow_Fetch_to_Decode (Fetch_to_Decode x);
   Fmt f = $format ("    Fetch_to_Decode{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" pred:%08h epoch:%0d", x.predicted_pc, x.epoch);
   f = f + $format (" halt_sentinel:%0d}", x.halt_sentinel);
   return f;
endfunction
                                                                // \blatex{fshow_Decode_to_RR}
function Fmt fshow_Decode_to_RR (Decode_to_RR x);
   Fmt f = $format ("    Decode_to_RR{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h", x.instr);
   f = f + $format (" pred:%08h epoch:%0d\n", x.predicted_pc, x.epoch);
   f = f + $format ("            ");
   f = f + $format ("fallthru:%08h ", x.fallthru_pc);
   if (x.exception) begin
      f = f + fshow_cause (x.cause);
      f = f + $format (" tval:%0h", x.tval);
   end
   else begin
      f = f + fshow (x.opclass);
      f = f + $format (" has_{rs1,rs2,rd}:{%0d,%0d,%0d} writes_mem:%0d, imm:%0h",
		       x.has_rs1, x.has_rs2, x.has_rd, x.writes_mem, x.imm);
   end
   f = f + $format (" halt_sentinel:%0d}", x.halt_sentinel);
   return f;
endfunction
                                                                // \elatex{fshow_Decode_to_RR}
function Fmt fshow_RR_to_Retire (RR_to_Retire x);
   Fmt f = $format ("    RR_to_Retire{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h ", x.instr, fshow (x.exec_tag), "\n");
   f = f + $format ("                 ");
   f = f + $format ("pred:%08h epoch:%0d has_rd:%0d writes_mem:%0d\n",
		    x.predicted_pc, x.epoch, x.has_rd, x.writes_mem);
   f = f + $format ("                 ");
   f = f + $format ("fallthru:%08h", x.fallthru_pc);
   if (x.exception) begin
      f = f + $format (" ", fshow_cause (x.cause));
      f = f + $format (" tval:%0h", x.tval);
   end
   f = f + $format (" halt_sentinel:%0d}", x.halt_sentinel);
   return f;
endfunction

function Fmt fshow_RR_to_EX_Control (RR_to_EX_Control x);
   Fmt f = $format ("    RR_to_EX_Control{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h", x.instr);
   f = f + $format (" fallthru:%08h\n", x.fallthru_pc);
   f = f + $format ("                  ");
   f = f + $format ("rs1_val:%08h ", x.rs1_val);
   f = f + $format (" rs2_val:%08h ", x.rs2_val);
   f = f + $format (" imm:%08h ", x.imm);
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_EX_Control_to_Retire (EX_Control_to_Retire x);
   Fmt f = $format ("    EX_Control_to_Retire{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h\n", x.instr);
   f = f + $format ("                      ");
   if (x.exception) begin
      f = f + $format (" ", fshow_cause (x.cause));
      f = f + $format (" tval:%0h", x.tval);
   end
   f = f + $format (" next_pc:%08h ", x.next_pc);
   f = f + $format (" data:%08h", x.data);
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_RR_to_EX (RR_to_EX x);
   Fmt f = $format ("    RR_to_EX{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h\n", x.instr);
   f = f + $format ("             ");
   f = f + $format ("rs1_val:%08h ", x.rs1_val);
   f = f + $format (" rs2_val:%08h ", x.rs2_val);
   f = f + $format (" imm:%08h ", x.imm);
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_EX_to_Retire (EX_to_Retire x);
   Fmt f = $format ("    EX_to_Retire{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h\n", x.instr);
   f = f + $format ("                 ");
   if (x.exception) begin
      f = f + $format (" ", fshow_cause (x.cause));
      f = f + $format (" tval:%0h", x.tval);
   end
   f = f + $format (" data:%08h", x.data);
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_Fetch_from_Retire (Fetch_from_Retire x);
   Fmt f = $format ("    Fetch_from_Retire{");
   f = f + $format ("I_%0d", x.inum);
   f = f + $format (" pc:%08h", x.pc);
   f = f + $format (" instr:%08h", x.instr);
   f = f + $format (" next_pc:%08h next_epoch %0d haltreq %0d",
		    x.next_pc, x.next_epoch, x.haltreq);
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_RW_from_Retire (RW_from_Retire x);
   Fmt f = $format ("    RW_from_Retire{");
   f = f + $format ("I_%0d pc:%08h instr:%08h", x.inum, x.pc, x.instr);
   f = f + $format (" rd:%0d commit:%0d data:%08x", x.rd, x.commit, x.data);
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_Dbg_to_CPU_Pkt (Dbg_to_CPU_Pkt x);
   Fmt f = $format ("Dbg_to_CPU_Pkt{");
   if (x.pkt_type == Dbg_to_CPU_RESUMEREQ)
      f = f + $format ("RESUMEREQ");
   else if (x.pkt_type == Dbg_to_CPU_HALTREQ)
      f = f + $format ("HALTREQ");
   else if (x.pkt_type == Dbg_to_CPU_RW) begin
      f = f + $format ("RW");
      f = f + ((x.rw_op == Dbg_RW_READ) ? $format (" READ") : $format (" WRITE"));
      f = f + ((x.rw_size == Dbg_MEM_1B) ? $format (" 1B")
	       : ((x.rw_size == Dbg_MEM_2B) ? $format (" 2B")
		  : ((x.rw_size == Dbg_MEM_4B) ? $format (" 4B")
		     : $format (" 8B"))));
      if (x.rw_target == Dbg_RW_GPR)
	 f = f + $format (" GPR x%0d", x.rw_addr);
      else if (x.rw_target == Dbg_RW_FPR)
	 f = f + $format (" FPR x%0d", x.rw_addr);
      else if (x.rw_target == Dbg_RW_CSR)
	 f = f + $format (" CSR 0x%0x", x.rw_addr);
      else
	 f = f + $format (" Mem 0x%0x", x.rw_addr);
      if (x.rw_op == Dbg_RW_WRITE)
	 f = f + $format (" 0x%0x", x.rw_wdata);
   end
   f = f + $format ("}");
   return f;
endfunction

function Fmt fshow_Dbg_from_CPU_Pkt (Dbg_from_CPU_Pkt x);
   Fmt f = $format ("Dbg_from_CPU_Pkt{", fshow (x.pkt_type));
   f = f + $format (" %0h}", x.payload);
   return f;
endfunction

// ****************************************************************

endpackage
