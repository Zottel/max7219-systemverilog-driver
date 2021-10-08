SOURCES=$(wildcard *.sv)

all: test

test:
	verilator --lint-only -sv $(SOURCES) -top-module max7219 \
	          -Wno-PROCASSWIRE -Wno-UNUSED -Wno-VARHIDDEN
	sby -f max7219_shift.sby
	sby -f max7219_controller.sby
	sby -f max7219.sby
