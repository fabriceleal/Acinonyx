
# "Compile" all history files into packed binary format
IN=$(wildcard in/*.txt)

OUT=$(patsubst in/%.txt, out/%.phb, $(IN))

PARSER=./parser/poker

.PHONY: all clean

all: $(PARSER) $(OUT)
#	echo $(IN)
#	echo $(OUT)

$(PARSER):
	make -C parser

out/%.phb: in/%.txt
	mkdir -p out
	./parser/poker $< $@

clean:
	rm -rf out/
	make -C parser/ clean
