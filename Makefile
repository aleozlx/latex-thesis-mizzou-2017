.PHONY: all check todo clean
SHELL=/bin/bash
GREP=grep --color=auto -En
PDFLATEX=pdflatex -synctex=1 -interaction=nonstopmode

ifeq (, $(shell which evince 2>/dev/null))
# Skip PDFVIEW if evince is not installed
PDFVIEW=@echo 'Done:'
else
PDFVIEW=evince
endif

all: main.pdf
	$(PDFVIEW) $< &

main.pdf: main.tex TitlePage.tex Approval.tex Acknowledge.tex Abstract.tex Introduction.tex Chapter_02.tex Chapter_03.tex Chapter_04.tex Chapter_05.tex Chapter_06.tex Chapter_07.tex Contents.tex
	$(PDFLATEX) $<
	biber $(basename $<)
	$(PDFLATEX) $<
	$(PDFLATEX) $<

todo:
	$(GREP) TODO *.tex || true

check: check_floating_citations check_long_lines check_references

check_floating_citations:
	$(GREP) '[^a-zA-Z\}\)] \\cite{' *.tex || true

check_references: main.aux bibtex_entries.bib
	diff <(sed -n 's/.*@cite{\(.*\)}.*/\1/p' main.aux | sort | uniq) <(sed -n 's/^@.*{\(.*\),/\1/p' bibtex_entries.bib | sort | uniq) || true

check_long_lines:
	$(GREP) '.{160}' *.tex || true

clean:
	rm -f main.aux main.bbl main.bcf main.blg main.lof main.lot main.run.xml main.synctex.gz main.toc main.pdf
	rm -f *.log
