proc usage {} {
	puts "\
usage: vivado -mode batch -source <script> -tclargs <ds-2018>
  <ds-2018>: absolute path of ds-2018 repository clone"
}

if { $argc == 1 } {
	set ds2018 [lindex $argv 0]
} else {
	usage
	exit -1
}

set ip sha256_ctrl_axi
set lib DS2018
set vendor martina_fogliato
set part "xc7z010clg400-1"
set board "digilentinc.com:zybo:part0:1.0"
set freq 120
set period [expr 1000.0 / $freq]

#############
# Create IP #
#############
create_project -part xc7z010clg400-1 -force $ip $ip
add_files $ds2018/vhdl/axi_pkg.vhd $ds2018/sha256/vhdl/fa.vhd \
$ds2018/sha256/vhdl/sha256_pkg.vhd \
$ds2018/sha256/vhdl/csa.vhd $ds2018/sha256/vhdl/sha256_exp_unit.vhd \
$ds2018/sha256/vhdl/sha256_core.vhd $ds2018/sha256/vhdl/sha256_cu.vhd \
$ds2018/sha256/vhdl/sha256.vhd $ds2018/sha256/vhdl/sha256_ctrl_axi.vhd
import_files -force -norecurse
ipx::package_project -root_dir $ip -vendor $vendor -library $lib -force $ip
close_project

############################
## Create top level design #
############################
set top top
set project [create_project -part $part -force $top .]
set fileset [current_fileset]
set_property board_part $board $project
set_property ip_repo_paths ./$ip $fileset
update_ip_catalog
create_bd_design "$top"
set ip [create_bd_cell -type ip -vlnv [get_ipdefs *$vendor:$lib:$ip:*] $ip]
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $freq] $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps7
set_property -dict [list CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {1}] $ps7

# Interconnections
# Primary IOs
# ps7 - ip
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins /$ip/s0_axi]

# Addresses ranges
set_property offset 0x40000000 [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]
set_property range 4K [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]

# Synthesis flow
validate_bd_design
set files [get_files *$top.bd]
generate_target all $files
add_files -norecurse -force [make_wrapper -files $files -top]
save_bd_design
set run [get_runs synth*]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none $run
launch_runs $run
wait_on_run $run
open_run $run

foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

# Timing constraints
set clock [get_clocks]

# Implementation
save_constraints
set run [get_runs impl*]
reset_run $run
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true $run
launch_runs -to_step write_bitstream $run
wait_on_run $run

# Messages
set rundir [pwd]/$top.runs/$run
puts ""
puts "\[VIVADO\]: done"
puts "  bitstream in $rundir/${top}_wrapper.bit"
puts "  resource utilization report in $rundir/${top}_wrapper_utilization_placed.rpt"
puts "  timing report in $rundir/${top}_wrapper_timing_summary_routed.rpt"
