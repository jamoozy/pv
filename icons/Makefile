.PHONY : all

svgs := $(shell ls *.svg)
pngs := $(svgs:%.svg=%.png)

all : $(pngs)

%.png : %.svg
	inkscape -C -e $@ $< --export-width=30px

loading.png : loading.svg
	inkscape -C -e $@ $< --export-width=200px

x.png : x.svg
	inkscape -C -e $@ $< --export-width=15px
