.PHONY: sim
sim:
	ghdl -a -fsynopsys -fexplicit ncd98010_master.vhdl ncd98010_tb.vhdl
	ghdl -r -fsynopsys -fexplicit ncd98010_tb --wave=ncd98010_tb.ghw 
	gtkwave -A ncd98010_tb.ghw &

# Testbench target
ncd98010_tb: ncd98010_tb.o ncd98010_master.o 
	ghdl -e $@

# automatic ghdl analyze
%.o:	%.vhdl
	ghdl -a $<

# Dependencies
ncd98010_tb.o: ncd98010_master.o



