.PHONY : all deploy

all :
	./maker.rb --tmp=.gen/ --yaml=entries.yaml --destination=~/www/pix/

deploy :
	./maker.rb --tmp=.gen/ --yaml=entries.yaml --destination=~/www/pv/
