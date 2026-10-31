# edge_testbench设为仿真顶层，重新打开行为仿真后执行
add_wave /edge_testbench/clk
add_wave /edge_testbench/rst
add_wave /edge_testbench/signal
add_wave /edge_testbench/edge_detect_inst/sig_r0
add_wave /edge_testbench/edge_detect_inst/sig_r1
add_wave /edge_testbench/pos_edge
restart
run 182 ns
