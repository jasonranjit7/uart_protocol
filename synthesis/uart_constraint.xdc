#clk
create_clock -period 20.000 -name clk [get_ports clk]
set_property -dict { PACKAGE_PIN N11    IOSTANDARD LVCMOS33 } [get_ports {clk}];

#i/p
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {rst}]; #Button-top
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {ready}]; #Button-bottom

#i/p switches
set_property -dict { PACKAGE_PIN L5    IOSTANDARD LVCMOS33 } [get_ports { data[0] }];#LSB
set_property -dict { PACKAGE_PIN L4    IOSTANDARD LVCMOS33 } [get_ports { data[1] }];
set_property -dict { PACKAGE_PIN M4    IOSTANDARD LVCMOS33 } [get_ports { data[2] }];
set_property -dict { PACKAGE_PIN M2    IOSTANDARD LVCMOS33 } [get_ports { data[3] }];
set_property -dict { PACKAGE_PIN M1    IOSTANDARD LVCMOS33 } [get_ports { data[4] }];
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports { data[5] }];
set_property -dict { PACKAGE_PIN N2    IOSTANDARD LVCMOS33 } [get_ports { data[6] }];
set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 } [get_ports { data[7] }];

#o/p
set_property -dict { PACKAGE_PIN J3    IOSTANDARD LVCMOS33 } [get_ports {rx_data[0]}];
set_property -dict { PACKAGE_PIN H3    IOSTANDARD LVCMOS33 } [get_ports {rx_data[1]}];
set_property -dict { PACKAGE_PIN J1    IOSTANDARD LVCMOS33 } [get_ports {rx_data[2]}];
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports {rx_data[3]}];
set_property -dict { PACKAGE_PIN L3    IOSTANDARD LVCMOS33 } [get_ports {rx_data[4]}];
set_property -dict { PACKAGE_PIN L2    IOSTANDARD LVCMOS33 } [get_ports {rx_data[5]}];
set_property -dict { PACKAGE_PIN K3    IOSTANDARD LVCMOS33 } [get_ports {rx_data[6]}];
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports {rx_data[7]}];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports {done}];#MSB

