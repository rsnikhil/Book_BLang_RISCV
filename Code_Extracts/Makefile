CODE_DIR = ~/Git/Fife

.PHONY: help
help:
	@echo "Targets:"
	@echo "    extract    Extracts code fragments from .bsv code in $(CODE_DIR)"
	@echo "               into local files to be \input into LaTeX"

.PHONY: extract
extract:
	./Extract_latex_from_BSV.py  $(CODE_DIR)  .

# ================================================================

.PHONY: clean
clean:
	rm -r -f *~

.PHONY: full_clean
full_clean: clean
