FIGS += Fig_Combo_Is_Legal_BRANCH.png
FIGS += Fig_Combo_Multiplexer.png
FIGS += Fig_Combo_Multiplexer_Cascade.png

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
