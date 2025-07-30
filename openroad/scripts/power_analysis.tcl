source scripts/reports_power.tcl
# initialize technology data
source scripts/init_tech.tcl
set log_id 0
set extRules ./src/IHP_rcx_patterns.rules
read_db ./out/mac_enabled_chip.odb
define_process_corner -ext_model_index 0 tt
extract_parasitics -ext_model_file $extRules

write_spef ./out/mac_enabled_chip.spef



##### Statistical Power Analysis ########
set log_id_str [format "%02d" $log_id]
utl::report "###############################################################################"
utl::report "# Step ${log_id_str}: Statistical Power Analysis"
utl::report "###############################################################################"


utl::report "Statistical Power Analysis"
# Load the gate-level netlist
# read_db ./out/mac_enabled_chip.odb

# Link the design hierarchy using the top module name
# link_design "croc_chip"

# Load timing constraints
read_sdc ./out/mac_enabled_chip.sdc

# Load extracted parasitics
read_spef ./out/mac_enabled_chip.spef

# Set uniform switching activity rate for all input ports, you may also replace <code>-input</code> with -global<code></code> to set activity rate for all pins
set_power_activity -input -activity 0.1
# utl::report "Statistical Power Analysis"
# Set known static inputs (e.g., reset) to zero activity
set_power_activity -input_port rst_ni -activity 0

# Generate the statistical power report for the typical corner
report_power -corner tt
report_power_metrics "statistical"

####### Stimuli-Based Power Analysis ########
# set log_id_str [format "%02d" $log_id]
# utl::report "###############################################################################"
# utl::report "# Step ${log_id_str}: Stimuli-Based Power Analysis"
# utl::report "###############################################################################"


# utl::report "Stimuli-Based Power Analysis"
# # Load design and related files
# # read_verilog ./out/mac_enabled_chip.v
# # link_design "croc_chip"
# read_sdc ./out/mac_enabled_chip.sdc
# read_spef ./out/mac_enabled_chip.spef

# # Load the VCD file and define the simulation scope
# read_vcd -scope tb_croc_soc/i_croc_soc ../vsim/croc.vcd

# # Finally, you can generate the VCD-based power report
# report_power -corner tt
# report_power_metrics "stimuli"

##### IR Drop #####
# read_def ./out/mac_enabled_chip.def
read_sdc ./out/mac_enabled_chip.sdc
## VDD ##
set log_id_str [format "%02d" $log_id]
utl::report "###############################################################################"
utl::report "# Step ${log_id_str}: IR Drop"
utl::report "###############################################################################"


utl::report "VDD"
set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -vsrc src/Vsrc_croc_vdd.loc -net VDD -corner tt
report_power_metrics "irdrop_vdd"

## VSS ##
utl::report "VSS"
set_pdnsim_net_voltage -net VSS -voltage 0
analyze_power_grid -vsrc src/Vsrc_croc_vss.loc -net VSS -corner tt
report_power_metrics "irdrop_vss"