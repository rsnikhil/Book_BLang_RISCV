CODE_DIR = ~/Git/Fife

.PHONY: help
help:
	@echo "Available targets:"
	@echo "    p, i, b, pip    p=pdf, i=index, b=bib"
	@echo "    figs            Create png files from svg files"
	@echo "    bib             Single run of bibtex"
	@echo "    full            Multiple runs of bibtex and pdflatex"
	@echo "    extract         Extracts code fragments from .bsv code in $(CODE_DIR)"
	@echo "                    into local files to be \input into LaTeX"
	@echo ""
	@echo "    clean           Remove emacs backups and minor intermediates"
	@echo "    full_clean      + remove LaTeX intermediate files backups and pdf"

TOPFILE = Book_BLang_RISCV

SOURCES = \
		Makefile \
		blankpage.tex \
		$(TOPFILE).tex \
		bibliography.bib \
		ch000_front/front.tex \
		ch010_intro/ch_intro.tex \
		ch020_ISA/ch_ISA.tex \
		ch030_RISCV_Design_Space/ch_RISCV_Design_Space.tex \
		ch040/ch_Combo_Circuits.tex \
		ch050/ch_struct_mem_req_rsp.tex \
		ch060/ch_Core_Functions.tex \
		ch070/ch_Modules_Interfaces.tex \
		ch080/ch_FSMs_Drum_CPU.tex \
		ch090/ch_Drum_Pending.tex \
		ch100/ch_Fife_Principles.tex \
		ch110/ch_Fife_Code.tex \
		ch120/ch_Fife_Pending.tex \
		ch720_Pending/ch_Pending.tex \
		ch800_apx_resources/apx_resources.tex \
		ch850_apx_Why_BSV/apx_Why_BSV.tex \
		ch900_back/back.tex

.PHONY: p i p pp pip figs bib extract

p: $(SOURCES)
	pdflatex  $(TOPFILE)

i: $(SOURCES)
	makeindex $(TOPFILE)

b: $(SOURCES)
	bibtex  $(TOPFILE)

.PHONY: pp
pp: $(SOURCES)
	pdflatex  $(TOPFILE)
	pdflatex  $(TOPFILE)

.PHONY: pip
pip: $(SOURCES)
	pdflatex  $(TOPFILE)
	makeindex $(TOPFILE)
	pdflatex  $(TOPFILE)

.PHONY: figs
figs:
	make -C ch010_intro/Figures
	make -C ch030_RISCV_Design_Space/Figures
	make -C ch040_Combo_Circuits/Figures

.PHONY: bib
bib:
	bibtex  $(TOPFILE)

.PHONY: extract
extract:
	./Code_Extracts/Extract_latex_from_BSV.py  $(CODE_DIR)  Code_Extracts

# ================================================================

.PHONY: clean
clean:
	rm -f  *~  */*~  */*/*~

.PHONY: full_clean
full_clean: clean
	rm -f  *.aux  *.bbl  *.blg  *.idx  *.ilg  *.ind  *.log  *.toc  *.out  *.dvi  */*.aux
	rm -f  $(TOPFILE).pdf
