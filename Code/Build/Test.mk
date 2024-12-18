# Copyright (c) 2024 Bluespec, Inc.  All Rights Reserved.
# Author: Rishiyur S. Nikhil

# ================================================================
# Makefile to:
# * Run Fife/Drum on one or more memhex32 => console log, detailed trace
# * Extract, from detailed trace, an instruction-trace suitable for TV diffing

# ================================================================

.PHONY: help
help:
	@echo "Available targets: (edit TESTS in Makefile as needed)"
	@echo "    help          Print this help text"
	@echo ""
	@echo "    run1          Run SIM_EXE on TEST producing"
	@echo "                    console log    in TRACES_DIR/TEST.log.txt"
	@echo "                    detailed trace in TRACES_DIR/TEST.trace.txt"
	@echo "    run_all       Make all run1 targets (see below)"
	@echo ""
	@echo "    clean         Remove Emacs backups, etc."
	@echo "    full_clean    Remove dirs  $(TRACES_DIR)/"
	@echo ""
	@echo "    tc.txt        Extract TEST's trace for Cissr   => tc.txt  tc_aux.txt"
	@echo "    tf.txt        Extract TEST's trace for SIM_EXE => tf.txt  tf_aux.txt"
	@echo ""
	@echo "Current settings for simulation run"
	@echo "    ISA_MEMHEX32_DIR    = $(ISA_MEMHEX32_DIR)/"
	@echo "    SIM_EXE             = $(SIM_EXE)"
	@echo "    CPU                 = $(CPU)"
	@echo "    TRACES_DIR          = $(TRACES_DIR)/"
	@echo "Current settings for trace TV diff"
	@echo "    TEST                = $(TEST)"
	@echo "    CISSR_TRACE_XFORMER = $(CISSR_TRACE_XFORMER)"
	@echo "    CISSR_TRACES_DIR    = $(CISSR_TRACES_DIR)"
	@echo "    FIFE_TRACE_XFORMER  = $(FIFE_TRACE_XFORMER)"
	@echo ""
	@echo "Individual run1 targets:"
	@for x in $(TESTS); do echo "   " $$x ; done
	@echo "END-OF_HELP ----------------"

TEST ?= rv32ui-p-add

# ================================================================

ISA_MEMHEX32_DIR ?= $(HOME)/Lab/RISCV_Tests/Catamaran/Tests_ISA/memhex32

CPU     ?= Drum
SIM_EXE ?= $(HOME)/Git/Fife/Build/$(CPU)/exe_$(CPU)_RV32_verilator
LOG     ?= +log

TRACES_DIR = traces

# ================================================================
# Run individual test

$(TRACES_DIR):
	mkdir -p  $(TRACES_DIR)

run_%: $(ISA_MEMHEX32_DIR)/%.memhex32  $(TRACES_DIR)
	ln -s -f  $<  test.memhex32
	-$(SIM_EXE)  $(LOG)  > $(TRACES_DIR)/$*.log.txt
	mv log*.txt $(TRACES_DIR)/$*.trace.txt

.PHONY: run1
run1: run_$(TEST)

# ----------------
# Run all tests

.PHONY: run_all
run_all:
	@for x in $(TESTS); do \
		make -f Test.mk run_$$x; \
	done

# ================================================================
# Extract simple instruction traces for TV diffing

CISSR_TRACES_DIR    = $(HOME)/Lab/RISCV_Tests/Catamaran/Tests_ISA/traces
CISSR_TRACE_XFORMER = $(HOME)/Git/CissrV2_dev/Tools/xform_trace.py

tc.txt: $(CISSR_TRACES_DIR)/$(TEST).trace.txt
	$(CISSR_TRACE_XFORMER)  $(CISSR_TRACES_DIR)/$(TEST).trace.txt  tc

FIFE_TRACE_XFORMER = $(HOME)/Git/Fife/Tools/xform_trace.py

tf.txt: tc.txt $(TRACES_DIR)/$(TEST).trace.txt
	$(FIFE_TRACE_XFORMER)  $(TRACES_DIR)/$(TEST).trace.txt  tf
	wc  tc.txt  tf.txt  tc_aux.txt  tf_aux.txt

diff_trace: tc.txt tf.txt
	diff  $^

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~  test.memhex32

.PHONY: full_clean
full_clean: clean
	rm -r -f  $(TRACES_DIR)  tc*.txt tf*.txt

# ================================================================
# List of tests

TESTS += rv32ui-p-add
TESTS += rv32ui-p-addi
TESTS += rv32ui-p-and
TESTS += rv32ui-p-andi
TESTS += rv32ui-p-auipc
TESTS += rv32ui-p-beq
TESTS += rv32ui-p-bge
TESTS += rv32ui-p-bgeu
TESTS += rv32ui-p-blt
TESTS += rv32ui-p-bltu
TESTS += rv32ui-p-bne
TESTS += rv32ui-p-fence_i
TESTS += rv32ui-p-jal
TESTS += rv32ui-p-jalr
TESTS += rv32ui-p-lb
TESTS += rv32ui-p-lbu
TESTS += rv32ui-p-lh
TESTS += rv32ui-p-lhu
TESTS += rv32ui-p-lui
TESTS += rv32ui-p-lw
TESTS += rv32ui-p-or
TESTS += rv32ui-p-ori
TESTS += rv32ui-p-sb
TESTS += rv32ui-p-sh
TESTS += rv32ui-p-simple
TESTS += rv32ui-p-sll
TESTS += rv32ui-p-slli
TESTS += rv32ui-p-slt
TESTS += rv32ui-p-slti
TESTS += rv32ui-p-sltiu
TESTS += rv32ui-p-sltu
TESTS += rv32ui-p-sra
TESTS += rv32ui-p-srai
TESTS += rv32ui-p-srl
TESTS += rv32ui-p-srli
TESTS += rv32ui-p-sub
TESTS += rv32ui-p-sw
TESTS += rv32ui-p-xor
TESTS += rv32ui-p-xori
TESTS += rv32mi-p-breakpoint
TESTS += rv32mi-p-csr
TESTS += rv32mi-p-illegal
TESTS += rv32mi-p-lh-misaligned
TESTS += rv32mi-p-lw-misaligned
TESTS += rv32mi-p-ma_addr
TESTS += rv32mi-p-ma_fetch
TESTS += rv32mi-p-mcsr
TESTS += rv32mi-p-sh-misaligned
TESTS += rv32mi-p-shamt
TESTS += rv32mi-p-sw-misaligned

# ================================================================
