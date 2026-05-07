# AX7035B top-level constraints.
# Clock: 50MHz active crystal on Y18 (GCLK)
# LED1: M13

set_property PACKAGE_PIN Y18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 20.000 [get_ports clk]

set_property PACKAGE_PIN F19 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
