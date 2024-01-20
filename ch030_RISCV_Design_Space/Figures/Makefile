FIGS += Fig_Instr_Exec.png
FIGS += Fig_Instr_Exec_w_FIFOs.png
FIGS += Fig_Instr_Exec_w_structs.png

.PHONY: help
help:
	@echo "Targets:"
	@echo "  copy   Copies Fig_Instr_Exec.svg to ..._w_structs.svg ..._w_FIFOs.svg"
	@echo "                Fig_Instr_Exec_w_structs.svg"
	@echo "                Fig_Instr_Exec_w_FIFOs.svg"
	@echo "             so each can have different layers on/off"
	@echo "  png    Produces .png files for all .svg files"
	@echo ""
	@echo "Protocol:"
	@echo "    In Inkscape, only edit Fig_Instr_Exec.svg, and save."
	@echo "    Then: 'make copy' to make copies."
	@echo "    Then: in each svg copy, DO NOT EDIT, just switch on/off layers and save."

.PHONY: png
png: $(FIGS)

%.png: %.svg
	inkscape --export-filename=$@  --export-area-drawing  -d 300 -y 0.0 $<

# Copy "master" Instr_Exec to versions where we can switch on/off other layers

.PHONY: copy
copy:
	cp -p Fig_Instr_Exec.svg  Fig_Instr_Exec_w_structs.svg
	cp -p Fig_Instr_Exec.svg  Fig_Instr_Exec_w_FIFOs.svg

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean: clean
	rm -r -f  $(FIGS)
