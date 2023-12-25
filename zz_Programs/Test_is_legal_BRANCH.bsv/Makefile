help:
	@echo "Targets:"
	@echo "  b_all        = b_compile  b_link  b_sim"
	@echo "  v_all        = v_compile  v_link  v_sim"
	@echo "  b_compile    Compile for Bluesim"
	@echo "  b_link       Link    for Bluesim"
	@echo "  b_sim        Run         Bluesim"
	@echo "  v_compile    Compile for Icarus Verilog (iverilog)"
	@echo "  v_link       Link    for Icarus Verilog (iverilog)"
	@echo "  v_sim        Run         Icarus Verilog (iverilog)"

b_all:	 b_compile  b_link  b_sim
v_all:	 v_compile  v_link  v_sim

# ----------------------------------------------------------------

TOPFILE   ?= Top.bsv

TOPMODULE ?= mkTop
EXEFILE_BSIM ?= exe_HW_bsim
EXEFILE_VSIM ?= exe_HW_vsim

BSCFLAGS = -keep-fires \
	-aggressive-conditions \
	-no-warn-action-shadowing \
	-show-range-conflict \
        -opt-undetermined-vals \
	-unspecified-to X \
	-show-schedule \

# ----------------------------------------------------------------

BSCPATH = +

# ----------------------------------------------------------------
# FOR BLUESIM

BSCDIRS_BSIM  = -simdir build_bsim -bdir build -info-dir build
BSCPATH_BSIM  = $(BSCPATH)

.PHONY: b_compile
b_compile:
	bsc -u -sim $(TOPFILE)

.PHONY: b_link
b_link:
	bsc  -sim  -e $(TOPMODULE) -o ./$(EXEFILE_BSIM)

.PHONY: b_sim
b_sim:
	./$(EXEFILE_BSIM)

# ----------------------------------------------------------------
# FOR VERILOG

BSCDIRS_V = -vdir verilog  -bdir build_v  -info-dir build_v
BSCPATH_V = +

VSIM ?= iverilog

build_v:
	mkdir -p $@

verilog:
	mkdir -p $@

.PHONY: v_compile
v_compile: build_v verilog
	bsc -u -elab -verilog  $(BSCDIRS_V)  $(BSCFLAGS)  -p $(BSCPATH_V)  $(TOPFILE)

.PHONY: v_link
v_link:
	bsc -verilog  -vsim $(VSIM)  $(BSCDIRS_V) \
		-e $(TOPMODULE) -o ./$(EXEFILE_VSIM) \
		-keep-fires

.PHONY: v_sim
v_sim:
	./$(EXEFILE_VSIM)

# ----------------------------------------------------------------

.PHONY: clean
clean:
	rm -f  *~  *.bo  *.ba  *.cxx  *.h  *.o

.PHONY: full_clean
full_clean: clean
	rm -r -f  exe_*  verilog

# ----------------------------------------------------------------
