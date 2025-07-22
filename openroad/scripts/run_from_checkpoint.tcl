set currentDir [pwd]
set CROC_DIR $currentDir
set report_dir $CROC_DIR/openroad/reports
set save_dir $CROC_DIR/openroad/save
set netlist $CROC_DIR/yosys/out/croc_chip_yosys.v
set proj_name "mac_enabled_chip"

source $CROC_DIR/openroad/scripts/checkpoint.tcl
# helper scripts
source $CROC_DIR/openroad/scripts/reports.tcl
source $CROC_DIR/openroad/scripts/checkpoint.tcl

# initialize technology data
source $CROC_DIR/openroad/scripts/init_tech.tcl
load_checkpoint 07_mac_enabled_chip.final

utl::report "Write output"
write_def                      $CROC_DIR/openroad/out/${proj_name}.def
write_verilog -include_pwr_gnd -remove_cells "$stdfill bondpad*" $CROC_DIR/openroad/out/${proj_name}_lvs.v
write_verilog                  $CROC_DIR/openroad/out/${proj_name}.v
write_db                       $CROC_DIR/openroad/out/${proj_name}.odb
write_sdc                      $CROC_DIR/openroad/out/${proj_name}.sdc