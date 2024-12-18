// Copyright (c) 2023-2024 Bluespec, Inc.  All Rights Reserved.
// Author: Rishiyur S. Nikhil

// WARNING: This file is not a standalone package;
// WARNING: it is "included" into other BSV files

// ****************************************************************
// Drum behavior expressed using an FSM

   Stmt exec_one_instr =                                        // \blatex{Drum_exec_one_instr}
   seq
      a_Fetch;
      a_Decode;
      a_Register_Read_and_Dispatch;

      // Execute and Retire
      if (rg_Dispatch.to_Retire.exec_tag == EXEC_TAG_DIRECT)
	 a_Retire_direct;
      else if (rg_Dispatch.to_Retire.exec_tag == EXEC_TAG_CONTROL)
	 seq    // BRANCH, JAL, JALR
	    a_EX_Control;
	    a_Retire_Control;
	 endseq
      else if (rg_Dispatch.to_Retire.exec_tag == EXEC_TAG_INT)
	 seq    // LUI, AUIPC, IALU
	    a_EX_Int;
	    a_Retire_Int;
	 endseq
      else if (rg_Dispatch.to_Retire.exec_tag == EXEC_TAG_DMEM)
	 seq
	    a_EX_DMem;
	    a_Retire_DMem;
	 endseq
      else    // IMPOSSIBLE
	 noAction;

      if (rg_exception)
	 a_exception;
   endseq;                                                      // \elatex{Drum_exec_one_instr}

   mkAutoFSM (seq                                               // \blatex{Drum_FSM}
		 while (True)
		    if (rg_runstate == CPU_HALTREQ)
		       action
			  csrs.save_dpc_dcsr_cause_prv (rg_pc, rg_dcsr_cause, priv_M);
			  rg_runstate <= CPU_HALTED;
		       endaction
		    else if (can_take_intr)
		       a_interrupt (cause);
		    else
		       exec_one_instr;
	      endseq);                                          // \elatex{Drum_FSM}

// ****************************************************************
