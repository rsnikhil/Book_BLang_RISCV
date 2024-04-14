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
	@echo "    figs            Regen .png from .svg in Figures/"
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
		ch010/ch_intro.tex \
		ch020/ch_ISA.tex \
		ch030/ch_Top_Packages.tex \
		ch040/ch_Combo_Circuits.tex \
		ch050/ch_struct_mem_req_rsp.tex \
		ch060/ch_Core_Functions.tex \
		ch070/ch_Modules_Interfaces.tex \
		ch080/ch_GPRs_CSRs.tex \
		ch090/ch_FSMs.tex \
		ch100/ch_Drum_CPU.tex \
		ch110/ch_BSV_Verification.tex \
		ch120/ch_RISCV_Verification.tex \
		ch130/ch_Rules_I.tex \
		ch140/ch_Drum_Rules.tex \
		ch150/ch_Fife_Principles.tex \
		ch160/ch_Fife_Code.tex \
		ch170/ch_Rules_II.tex \
		ch180/ch_Optimization.tex \
		ch190/ch_BSV_Further_Study.tex \
		ch200/ch_RISCV_Further_Study.tex \
		ch800_apx_resources/apx_resources.tex \
		ch850_apx_Why_BSV/apx_Why_BSV.tex \
		ch850_apx_Why_BSV/apx_Why_BSV.tex \
		ch860_apx_Glossary/apx_Glossary.tex \
		ch870/apx_BSV_importing_C.tex \
		ch900_back/back.tex

.PHONY: p i p pp pip figs bib extract

p: $(SOURCES)
	pdflatex  $(TOPFILE)

i: $(SOURCES)
	makeindex $(TOPFILE)
	makeindex $(TOPFILE).bdx -o $(TOPFILE).bnd
	makeindex $(TOPFILE).rdx -o $(TOPFILE).rnd

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
	makeindex $(TOPFILE).bdx -o $(TOPFILE).bnd
	makeindex $(TOPFILE).rdx -o $(TOPFILE).rnd
	pdflatex  $(TOPFILE)

.PHONY: figs
figs:
	make -C Figures png

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
	rm -f  *.aux  *.bbl  *.blg  *.*dx  *.*lg  *.*nd  *.log  *.toc  *.lof  *.lot  *.out  *.dvi  */*.aux
	rm -f  $(TOPFILE).pdf
