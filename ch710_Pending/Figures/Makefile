FIGS += Fig_Fife_Retire.png

.PHONY: help
help:
	@echo "Targets:"
	@echo "  png    Produces .png files for all .svg files"

.PHONY: png
png: $(FIGS)

%.png: %.svg
	inkscape --export-filename=$@  --export-area-drawing  -d 300 -y 0.0 $<

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean: clean
	rm -r -f  $(FIGS)
