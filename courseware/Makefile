SLIDES += Slides_01_Intro.pdf
SLIDES += Slides_02_ISA.pdf
SLIDES += Slides_03_BSV_Program_Structure.pdf
SLIDES += Slides_04_BSV_Comb_Circuits.pdf
SLIDES += Slides_05_BSV_Structs.pdf
SLIDES += Slides_06_RISCV_Core_Functions.pdf

.PHONY: pdf
pdf: $(SLIDES)

%.pdf: %.tex  Preamble.tex  Reminders.tex  Postamble.tex
	mkdir -p tmp_latex
	pdflatex  -output-directory=tmp_latex  -file-line-error  $<
	pdflatex  -output-directory=tmp_latex  $<
	mv tmp_latex/$@  .

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean: clean
	rm -r -f  tmp_latex  Slides_*.pdf
