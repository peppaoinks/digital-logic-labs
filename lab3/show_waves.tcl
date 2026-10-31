# 添加仿真波形
restart
add_wave /testbench/clk
add_wave /testbench/rst
add_wave /testbench/freq_ctrl
add_wave /testbench/dir_ctrl
add_wave /testbench/mode_sel
add_wave -radix unsigned /testbench/u_flowing_water_lights/cnt
add_wave /testbench/u_flowing_water_lights/cnt_end
add_wave /testbench/led
run 880 ns
