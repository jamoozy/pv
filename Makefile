.PHONY : all deploy icons

all : icons
	./maker.rb --tmp=.gen/ --yaml=entries.yaml --destination=~/www/pix/

deploy : icons
	./maker.rb --tmp=.gen/ --yaml=entries.yaml --destination=~/www/pv/

icons :
	$(MAKE) -C icons || exit 1
