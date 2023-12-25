.PHONY: help
help:
	@echo "Available targets:"
	@echo "    pdf     Single run of pdflatex"
	@echo "    bib     Single run of bibtex"
	@echo "    full    Multiple runs of bibtex and pdflatex"
	@echo "    clean   Remove emacs backups"
	@echo "    clean1  + LaTeX intermediate files"
	@echo "    clean2  + pdf file"

TOPFILE = Book

SOURCES = \
		Makefile \
		blankpage.tex \
		$(TOPFILE).tex \
		bibliography.bib \
		ch000_front/front.tex \
		ch010_intro/ch_intro.tex \
		ch020_ISA/ch_ISA.tex \
		ch030_RISCV_Design_Space/ch_RISCV_Design_Space.tex \
		ch040_Combo_Circuits/ch_Combo_Circuits.tex \
		ch800_apx_resources/apx_resources.tex \
		ch850_apx_BSV/apx_BSV.tex \
		ch900_back/back.tex

.PHONY: pdf
pdf: $(SOURCES)
	pdflatex  $(TOPFILE)

.PHONY: pip
pip: $(SOURCES)
	pdflatex  $(TOPFILE)
	makeindex $(TOPFILE)
	pdflatex  $(TOPFILE)

.PHONY: figs
figs:
	make -C ch010_intro/Figures
	make -C ch030_Magritte/Figures

.PHONY: full
full: $(SOURCES)
	pdflatex  $(TOPFILE)
	bibtex    $(TOPFILE)
	pdflatex  $(TOPFILE)
	pdflatex  $(TOPFILE)

.PHONY: bib
bib:
	bibtex  $(TOPFILE)

.PHONY: index
index:
	makeindex $(TOPFILE)

# ================================================================

.PHONY: clean
clean:
	rm -f  *~  */*~  */*/*~

.PHONY: full_clean
full_clean: clean
	rm -f  *.aux  *.bbl  *.blg  *.idx  *.ilg  *.ind  *.log  *.toc  *.out  *.dvi  */*.aux
	rm -f  $(TOPFILE).pdf
