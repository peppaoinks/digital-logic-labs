# vivado -mode gui -source scripts/create_project.tcl -tclargs lab4
set repo_dir [file normalize [file join [file dirname [info script]] ..]]
if {[llength $argv] != 1} { error "Select lab1, dff, reg8file, lab3 or lab4" }
set design [lindex $argv 0]
switch -- $design {
    lab1 {
        set source_dir lab1
        set top mux
        set rtl {mux.v}
        set testbench mux_sim
        set sim {mux_sim.v}
    }
    dff - reg8file {
        set source_dir lab2/$design
        set top $design
        set rtl [list $design.v]
        set testbench testbench
        set sim {testbench.v}
    }
    lab3 {
        set source_dir lab3
        set top flowing_water_lights
        set rtl {flowing_water_lights.v counter.v}
        set testbench testbench
        set sim {testbench.v}
    }
    lab4 {
        set source_dir lab4
        set top lab4
        set rtl {lab4.v led_ctrl_unit.v edge_detect.v button_debounce.v}
        set testbench testbench
        set sim {testbench.v edge_testbench.v}
    }
    default { error "Unknown design: $design" }
}
set project_dir [file join $repo_dir build vivado $top]
set project_file [file join $project_dir $top.xpr]
if {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project $top $project_dir -part xc7a35tcsg324-1
    set_property target_language Verilog [current_project]
    foreach name $rtl { add_files -norecurse [file join $repo_dir $source_dir $name] }
    foreach name $sim { add_files -fileset sim_1 -norecurse [file join $repo_dir $source_dir $name] }
    add_files -fileset constrs_1 -norecurse [file join $repo_dir $source_dir pin.xdc]
}
set_property top $top [get_filesets sources_1]
set_property top $testbench [get_filesets sim_1]
set_property xsim.simulate.runtime 0ns [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
