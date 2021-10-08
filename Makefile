SOURCES=$(wildcard *.sv)
SOURCES=$(wildcard *.sv)

all: test

test:
	verilator --lint-only -sv $(SOURCES) \
	          -Wno-PROCASSWIRE -Wno-UNUSED -Wno-VARHIDDEN
	sby -f max7219_shift.sby
	sby -f max7219_controller.sby
	sby -f max7219.sby
