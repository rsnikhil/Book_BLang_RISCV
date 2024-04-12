SLIDES += Slides_010_Intro.pdf
SLIDES += Slides_020_ISA.pdf
SLIDES += Slides_040_BSV_Program_Structure.pdf

.PHONY: pdf
pdf: $(SLIDES)

%.pdf: %.tex
	mkdir -p tmp_latex
	pdflatex -output-directory=tmp_latex $<
	pdflatex -output-directory=tmp_latex $<
	mv tmp_latex/$@  .

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean: clean
	rm -r -f  tmp_latex  Slides_*.pdf
