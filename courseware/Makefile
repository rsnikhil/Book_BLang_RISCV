SLIDES += Slides_01_Intro.pdf
SLIDES += Slides_02_ISA.pdf
SLIDES += Slides_03_BSV_Program_Structure.pdf
SLIDES += Slides_04_BSV_Comb_Circuits.pdf
SLIDES += Slides_05_BSV_Structs.pdf
SLIDES += Slides_06_RISCV_Core_Functions.pdf
SLIDES += Slides_07_BSV_Modules_Interfaces.pdf
SLIDES += Slides_08_RISCV_GPRs_CSRs.pdf
SLIDES += Slides_09_BSV_StmtFSM.pdf
SLIDES += Slides_10_RISCV_Drum_CPU.pdf
SLIDES += Slides_11_BSV_Verification.pdf
SLIDES += Slides_13_BSV_Rules_I.pdf
SLIDES += Slides_15_RISCV_Fife_Principles.pdf
SLIDES += Slides_16_RISCV_Fife_CPU.pdf
SLIDES += Slides_17_BSV_CRegs.pdf

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
