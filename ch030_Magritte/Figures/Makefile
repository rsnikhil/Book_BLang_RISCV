FIGS += Fig_Magritte_Simple_Instr_Exec.png
FIGS += Fig_Magritte_Is_Legal_BRANCH.png
FIGS += Fig_Magritte_Multiplexer.png
FIGS += Fig_Magritte_Multiplexer_Cascade.png

all: $(FIGS)

%.png: %.svg
	inkscape --export-filename=$@  --export-area-drawing  -d 300 -y 0.0 $<

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean: clean
	rm -r -f  $(FIGS)
