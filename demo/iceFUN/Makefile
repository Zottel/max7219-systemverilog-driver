SOURCES=$(wildcard ../../*.sv)

demo.bin: demo.sv icefun.pcf Makefile $(SOURCES)
	yosys -q -p "synth_ice40; write_json demo.json" \
		demo.sv $(SOURCES)
	nextpnr-ice40 --hx8k --package cb132 --json demo.json --asc demo.asc \
		           --pcf icefun.pcf \
	             --placed-svg demo.placement.svg --routed-svg demo.routing.svg
	icebox_explain demo.asc > demo.ex
	icetime -d hx8k demo.asc > demo.time.txt
	icepack demo.asc demo.bin

.PHONY: program
program: demo.bin Makefile
	iceFUNprog demo.bin

clean:
	rm -f demo.asc demo.ex demo.bin demo.json demo.time.txt \
	     demo.placement.svg demo.routing.svg
