FIGS += Fig_AUIPC.png
FIGS += Fig_B_imm.png
FIGS += Fig_BSV_Digital_Circuits.png
FIGS += Fig_BSV_module_interaction.png
FIGS += Fig_BSV_namespace_control.png
FIGS += Fig_BSV_Package.png
FIGS += Fig_BSV_program_structure.png
FIGS += Fig_BSV_Split_Phase_Mem.png
FIGS += Fig_BSV_static_elaboration.png
FIGS += Fig_BSV_Types.png
FIGS += Fig_BSV_whats_in_an_interface_decl.png
FIGS += Fig_BSV_whats_in_an_interface_def.png
FIGS += Fig_BSV_whats_in_a_module_decl.png
FIGS += Fig_BSV_whats_in_a_rule.png
FIGS += Fig_Chapter_Roadmap.png
FIGS += Fig_Clock.png
FIGS += Fig_Combo_Is_Legal_BRANCH.png
FIGS += Fig_Combo_Multiplexer.png
FIGS += Fig_Combo_Multiplexer_Cascade.png
FIGS += Fig_Combo_Multiplexer_Parallel.png
FIGS += Fig_Combo_path_in_mkPipelineFIFOF.png
FIGS += Fig_Combo_path_in_mkBypassFIFOF.png
FIGS += Fig_Composed_FIFO_Producer_Consumer.png
FIGS += Fig_Composed_FIFO_modularity.png
FIGS += Fig_CPU_Simulation.png
FIGS += Fig_CPU_Verif_Complexity.png
FIGS += Fig_Credit_Based_Flow_Control.png
FIGS += Fig_CReg_HW.png
FIGS += Fig_CReg_BSV.png
FIGS += Fig_CSRRxx.png
FIGS += Fig_FIFO.png
FIGS += Fig_FIFO_Producer_Consumer.png
FIGS += Fig_FSM_Bubble_and_Arrow.png
FIGS += Fig_FSMs_Concurrent.png
FIGS += Fig_FSMs_Structured.png
FIGS += Fig_Goals.png
FIGS += Fig_Instr_Exec.png
FIGS += Fig_Instr_Exec_w_structs.png
FIGS += Fig_Instr_Exec_w_FIFOs.png
FIGS += Fig_Interface_Buses.png
FIGS += Fig_ISA_Modularity.png
FIGS += Fig_J_imm.png
FIGS += Fig_JAL_JALR.png
FIGS += Fig_Levels_of_Assurance.png
FIGS += Fig_LUI.png
FIGS += Fig_Mem_Hierarchy.png
FIGS += Fig_Retire_Layers_1.png
FIGS += Fig_Retire_Layers_1_2.png
FIGS += Fig_RISCV_Epochs.png
FIGS += Fig_RISCV_Fuse_Decode_RR.png
FIGS += Fig_RISCV_Retire_Ordering.png
FIGS += Fig_RISCV_Scoreboard.png
FIGS += Fig_RISCV_Store_Buffer.png
FIGS += Fig_Rule_Actions_1.png
FIGS += Fig_Rule_Actions_1_2.png
FIGS += Fig_Rule_Actions_Controlled.png
FIGS += Fig_Rule_Structure.png
FIGS += Fig_RV32I_labeled.png
FIGS += Fig_tandem_verification.png
FIGS += Fig_tandem_verification_II.png
FIGS += Fig_Testbench_DUT.png
FIGS += Fig_Topics.png
FIGS += Fig_Trap_CSRs.png
FIGS += Fig_Trap_Return.png
FIGS += Fig_Two_Microarchitectures.png
FIGS += Fig_What_is_an_ISA.png

.PHONY: help
help:
	@echo "Targets:"
	@echo "  png    Produces .png files for all .svg files"

.PHONY: png
png: $(FIGS)

%.png: %.svg
	inkscape --export-filename=$@  --export-area-drawing  -d 300 -y 0.0 $<

# ----------------------------------------------------------------
# Extracted layered SVG into multiple PNGs

LAYER_1 = 'select-all:layers; object-set-attribute:style, display:none; select-clear; select-by-id:layer1; object-set-attribute:style, display:inline'

LAYERS_1_2 = 'select-all:layers; object-set-attribute:style, display:none; select-clear; select-by-id:layer1,layer2; object-set-attribute:style, display:inline'

LAYERS_1_3 = 'select-all:layers; object-set-attribute:style, display:none; select-clear; select-by-id:layer1,layer3; object-set-attribute:style, display:inline'

Fig_Instr_Exec.png: Fig_Instr_Exec.svg
	inkscape --actions=$(LAYER_1) \
		--export-filename=$@ --export-area-drawing  -d 300 -y 0.0 $<

Fig_Instr_Exec_w_FIFOs.png: Fig_Instr_Exec.svg
	inkscape --actions=$(LAYERS_1_2) \
		--export-filename=$@ --export-area-drawing  -d 300 -y 0.0 $<

Fig_Instr_Exec_w_structs.png: Fig_Instr_Exec.svg
	inkscape --actions=$(LAYERS_1_3) \
		--export-filename=$@ --export-area-drawing  -d 300 -y 0.0 $<

Fig_Rule_Actions_1.png: Fig_Rule_Actions.svg
	inkscape --actions=$(LAYER_1) \
		--export-filename=$@ --export-area-drawing  -d 300 -y 0.0 $<

Fig_Rule_Actions_1_2.png: Fig_Rule_Actions.svg
	inkscape --actions=$(LAYERS_1_2) \
		--export-filename=$@ --export-area-drawing  -d 300 -y 0.0 $<

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean: clean
	rm -r -f  $(FIGS)
