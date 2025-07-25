set currentDir [pwd]
set CROC_DIR $currentDir
set report_dir reports
set save_dir save
set netlist $CROC_DIR/yosys/out/croc_chip_yosys.v
set proj_name "mac_enabled_chip"

source scripts/checkpoint.tcl
# helper scripts
source scripts/reports.tcl
source scripts/checkpoint.tcl

# initialize technology data
source scripts/init_tech.tcl
load_checkpoint 07_mac_enabled_chip.final

utl::report "Write output"
write_def                      out/${proj_name}.def
write_verilog -include_pwr_gnd -remove_cells "$stdfill bondpad*" out/${proj_name}_lvs.v
write_verilog                  out/${proj_name}.v
write_db                       out/${proj_name}.odb
write_sdc                      out/${proj_name}.sdc