# EGO1 开发板，芯片型号 xc7a35tcsg324-1
# 引脚对应关系参考 EGO1 硬件手册 V2 第 7-8 页
# 小拨码 SW0 控制使能，SW1 选择加法或减法
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {en}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {mux_sel}]

# input_a 接大拨码 SW3-SW0
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {input_a[0]}]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {input_a[1]}]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports {input_a[2]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {input_a[3]}]

# input_b 接大拨码 SW7-SW4
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {input_b[0]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {input_b[1]}]
set_property -dict {PACKAGE_PIN P4 IOSTANDARD LVCMOS33} [get_ports {input_b[2]}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {input_b[3]}]

# output_c 接 LD2_3-LD2_0，输出为 1 时灯亮
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {output_c[0]}]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {output_c[1]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {output_c[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {output_c[3]}]
