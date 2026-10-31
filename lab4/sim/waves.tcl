# 在testbench行为仿真打开后执行
add_wave /testbench/clk
add_wave /testbench/rst
add_wave -radix hex /testbench/lab4_inst/display
add_wave /testbench/lab4_inst/led_ctrl_unit_inst/scan_index
add_wave /testbench/led_en
add_wave /testbench/led_cx
add_wave /testbench/led_cx1
add_wave /testbench/lab4_inst/led_ctrl_unit_inst/data
add_wave /testbench/button_s3
add_wave /testbench/lab4_inst/button_debounce_s3/button_sync
add_wave /testbench/lab4_inst/s3_clean
add_wave /testbench/lab4_inst/s3_raw_press
add_wave /testbench/lab4_inst/s3_clean_press
add_wave /testbench/lab4_inst/raw_tens
add_wave /testbench/lab4_inst/raw_ones
add_wave /testbench/lab4_inst/clean_tens
add_wave /testbench/lab4_inst/clean_ones
restart
run 6500 ns
