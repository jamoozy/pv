.PHONY : all

svgs := $(shell ls *.svg)
pngs := $(svgs:%.svg=%.png)

all : $(pngs)

%.png : %.svg
	inkscape -C -e $@ $< --export-width=30px
