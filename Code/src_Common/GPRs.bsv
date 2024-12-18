// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

package GPRs;

// ****************************************************************
// This is a 2-read-port register file of 32 registers.
// Register 0 ('x0') always reads as 0.
// Polymorphic: register-width ix 'xlen' (instantiated with 32 for RV32, 64 for RV64)

// ****************************************************************
// Imports from libraries

import RegFile :: *;
import Vector  :: *;

// ----------------
// Local imports

import Arch :: *;

// ****************************************************************
// Interface for GPRs

interface GPRs_IFC #(numeric type xlen);                           // \blatex{GPRs_IFC}
   method Bit #(xlen) read_rs1 (Bit #(5) rs1);
   method Bit #(xlen) read_rs2 (Bit #(5) rs2);
   method Action      write_rd (Bit #(5) rd, Bit #(xlen) rd_val);

   // For debugger                                                       // \belide{3}
   method Bit #(xlen) read_dm  (Bit #(5) rs);
   method Action      write_dm (Bit #(5) rd, Bit #(xlen) rd_val);        // \eelide
endinterface                                                       // \elatex{GPRs_IFC}

// ================================================================
// Two implementations of a GPR module

// ----------------------------------------------------------------
// GPRs module; first version
// BSV schedule: register-reads happen "before" register-write
// i.e., in case of concurrent (same-clock) read and write to same index,
// the "read" reads the old value and the "write" writes a new value
// that is available on the subsequent clock.

module mkGPRs (GPRs_IFC #(xlen));                                    // \blatex{mkGPRs}
   RegFile #(Bit #(5), Bit #(xlen)) rf <- mkRegFileFull;

   method Bit #(xlen) read_rs1 (Bit #(5) rs1);
      return ((rs1 == 0) ? 0 : rf.sub (rs1));
   endmethod

   method Bit #(xlen) read_rs2 (Bit #(5) rs2);
      return ((rs2 == 0) ? 0 : rf.sub (rs2));
   endmethod

   method Action write_rd (Bit #(5) rd, Bit #(xlen) rd_val);
      rf.upd (rd, rd_val);
   endmethod

   // For debugger                                                       // \belide{3}
   method Bit #(xlen) read_dm  (Bit #(5) rs);
      return ((rs == 0) ? 0 : rf.sub (rs));
   endmethod

   method Action      write_dm (Bit #(5) rd, Bit #(xlen) rd_val);        // \eelide
      rf.upd (rd, rd_val);
   endmethod
endmodule                                                            // \elatex{mkGPRs}

// ----------------
// A monomorphic version synthesized into Verilog

(* synthesize *)                                         // \blatex{mkGPRs_synth}
module mkGPRs_synth (GPRs_IFC #(XLEN));
   let ifc <- mkGPRs;
   return ifc;
endmodule                                                // \elatex{mkGPRs_synth}

// ****************************************************************
// Interface for Scoreboard

// The scoreboard is a vector of 1-bit values indicating which of the
// 32 registers are "busy". scoreboard[X] is 1 when there is an older
// instruction in the downstream pipes that is expected to write into
// register X.

typedef  Vector #(32, Bit #(1))  Scoreboard;

interface Scoreboard_IFC;
   interface Reg #(Scoreboard) port0;
   interface Reg #(Scoreboard) port1;
endinterface

// ================================================================
// Two implementations of a scoreboard module

// ----------------------------------------------------------------
// Scoreboard module, first version

// Uses an ordinary register.
// Register-read (whether port0 or port1) schedule before
// register-write (whether port0 or port1).

module mkScoreboard (Scoreboard_IFC);
   Reg #(Scoreboard) rg <- mkReg (replicate (0));
   interface port0 = rg;
   interface port1 = rg;
endmodule

// ****************************************************************

endpackage
