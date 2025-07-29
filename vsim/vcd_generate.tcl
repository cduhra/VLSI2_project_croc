questa-2019.3 vsim -c -do "source compile_post_pnr_netlist.tcl; source compile_tech.tcl; source compile_tech_chip.tcl; exit"
questa-2019.3 vsim +binary="../sw/bin/helloworld.hex" -gui tb_croc_soc -t 1ns -voptargs=+acc \
     -suppress vsim-3009 -suppress vsim-8683 -suppress vsim-8386 \
     -do "run -all; exit"