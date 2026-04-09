# Vivado batch build script.
# The script assumes it is launched from the project root directory and
# uses environment variables exported by scripts/build.sh when available.

set project_root [file normalize [pwd]]
set rtl_dir      [file join $project_root rtl]
set constr_dir   [file join $project_root constr]
set build_dir    [file join $project_root build]
set top_module   [expr {[info exists ::env(TOP_MODULE)] ? $::env(TOP_MODULE) : "top"}]
set fpga_part    [expr {[info exists ::env(FPGA_PART)] ? $::env(FPGA_PART) : "xc7a35tfgg484-2"}]
set bit_name     [expr {[info exists ::env(BITSTREAM_NAME)] ? $::env(BITSTREAM_NAME) : "${top_module}.bit"}]

file mkdir $build_dir

set verilog_files [glob -nocomplain [file join $rtl_dir *.v]]
set xdc_files     [glob -nocomplain [file join $constr_dir *.xdc]]

if {[llength $verilog_files] == 0} {
    puts stderr "No Verilog files found under $rtl_dir"
    exit 1
}

if {[llength $xdc_files] == 0} {
    puts stderr "No XDC files found under $constr_dir"
    exit 1
}

foreach src $verilog_files {
    read_verilog $src
}

foreach xdc $xdc_files {
    read_xdc $xdc
}

synth_design -top $top_module -part $fpga_part
opt_design
place_design
route_design

report_timing_summary -file [file join $build_dir timing_summary.rpt]
report_utilization    -file [file join $build_dir utilization.rpt]

write_bitstream -force [file join $build_dir $bit_name]

exit 0
