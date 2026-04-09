# WELOG1 minimal top-level constraints.
# Confirmed clock pin: R4
# Confirmed LED1 pin: V2

set_property PACKAGE_PIN R4 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

set_property PACKAGE_PIN V2 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
