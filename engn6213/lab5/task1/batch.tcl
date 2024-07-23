# Batch Tcl file for each lab.  Modify the sources as needed.
# Usage: vivado -mode tcl -source batch.tcl
# where X stands for lab number: 1,2,3,etc.

# Tcl commands are separated by newlines or semicolons

# STEP#0: set up project architecture and set part to basys3
set srcdir ./src
if { [file isdirectory $srcdir] > 0 } {
    puts "$srcdir already exists; skipping ... \n"
} else {
    puts "Creating $srcdir ...\n"
    file mkdir $srcdir
}

set logdir ./log
if { [file isdirectory $logdir] > 0 } {
    puts "$logdir already exists; skipping ... \n"
} else {
    puts "Creating $logdir ... \n"
    file mkdir $logdir
}

# Testbench files for simulation
set simdir ./sim
if { [file isdirectory $simdir] > 0 } {
    puts "$simdir already exists; skipping ... \n"
} else {
    puts "Creating $simdir ... \n"
    file mkdir $simdir
}


# STEP#1: define a procedure (function) that read, compile, synth, and implement
# the given design `$top` and write it into bitstreams.

# [expr] returns a value
# read_verilog [ glob -directory ./src/ *.v ]; #

proc deploy { top } {
    puts "Closing the current in-memory design ... \n"
    close_project -quiet

    set srcdir ./src
    set logdir ./log
    set condir ./constraints

    # Assign part (board) to the current in-memory project
    puts "Creating a new in-mem design with part xc7a35tcpg236-1 ... \n"
    link_design -part xc7a35tcpg236-1; # or set_part <part>

    # Read and compile verilog (*.v) or system-verilog (*.sv) files
    puts "Reading verilog source files ... \n"
    read_verilog [glob $srcdir/*.sv]

    # Sythesize. Note the `rebuilt` is the default behavior when using GUI.
    # When compiling verilog files, all the modules instantiated in the `$top`
    # will be first flattened (no hierarchy) for possible optimization; then
    # they will be rebuilt by synthesis tool to create an easy-to-analyze and
    # similar-to-the-original hierarchy. Two other options: `full` and `none`.
    # set_param general.maxThreads 8 (default on Linux).  This default also
    # applied to place_design, route_design
    set_param general.maxThreads 4
    synth_design -top $top -flatten_hierarchy rebuilt

    # Add constraints file (*.xdc) where set_property will define necessary
    # stuff such as voltage and board port-switch connections
    # *.xdc file is basically a tcl script where Vivado Tcl commands are used
    # to config the board to work with the bitstream to be deployed.
    # Constraints can be written here and then `write_xdc` to a file
    # glob return an empty list which is identical to an empty string
    if { [glob -nocomplain $condir/*.xdc] != "" } {
        read_xdc $condir/$top.xdc
    }

    # You will get DRC errors without the next two lines when you generate a bitstream
    set_property CFGBVS VCCO [current_design]
    set_property CONFIG_VOLTAGE 3.3 [current_design]

    # Set necessary properties for generating bitstream
    # set_property CFGBVS VCCO [current_design]
    # set_property CONFIG_VOLTAGE 3.3 [current_design]

    # Could possibly opt_design here
    puts "Placing design ...\n"
    place_design

    puts "Routing design ...\n"
    route_design

    # Checkpoint is the data that records all the necessary detail for restoring
    # the project state exactly back at the recorded point
    puts "Writing checkpoint ...\n"
    write_checkpoint -force $logdir/$top.dcp

    puts "Writing bitstream ... \n"
    write_bitstream -force $top.bit

    puts "All done!"
    close_project -quiet
}

# Check syntax for verilog code
proc flycheck {} {
    check_syntax -fileset [glob ./src/*.v]
}

# Program the device
proc impl { top } {
    open_hw_manager

    # connect to default hardware server on the default port 3121
    connect_hw_server -url localhost:3121 -allow_non_jtag

    open_hw_target

    # At this moment, if run get_hw_targets, you will get
    # localhost:3121/xilinx_tcf/Digilent/210183B9AB45A
    # which is the current hardware target in use
    # If you need to change the default clock frequency (UG908 pp.34, v2023.2)
    # set_property PARAM.FREQUENCY <value> [get_hw_targets]

    # Automatically search for the current target
    open_hw_target
    # or more specific
    # open_hw_target [get_hw_targets */xilinx_tcf/Digilent/210183B9AB45A]

    # Connect to current_hw_device
    # Alternatively, curret_hw_device [lindex [get_hw_devices] 0]
    current_hw_device [get_hw_devices xc7a35t_0]

    # No probe files for now
    set_property PROBES.FILE {} [current_hw_device]
    set_property FULL_PROBES.FILE {} [current_hw_device]
    # Associate *.bit file to current hw device
    # If using `{}`, then conent in `{}` will be treated as literals!
    set_property PROGRAM.FILE ./$top.bit [current_hw_device]

    # Write the bitstream to the board (UG835, pp1186, v2023.2)
    program_hw_device [current_hw_device]


    puts "Programming divice DONE! \n"

    puts "Closing server and hw manager ...\n"
    disconnect_hw_server
    close_hw_manager
}


# Elaborate the design (see gates, registers, etc described in
# verilog). This style of system visualisation is called RTL
# framework. This needs start_gui after running the commands.
proc elab { top } {
    close_project

    read_verilog [glob ./src/$top.v]
    read_verilog -quiet [glob -nocomplain ./src/$top.xdc]; # constraints could be absent
    synth_design -top $top -part xc7a35tcpg236-1 -rtl
    start_gui

    # In the GUI, at the bottom, type in `stop_gui` in the Tcl console to close it
}

proc close_all {} {
    disconnect_hw_server
    close_hw_manager
    close_project
}

# Just compile (synth) the verilog files
proc compile { top } {

    close_project -quiet

    set srcdir ./src
    set logdir ./log
    set condir ./constraints

    # Assign part (board) to the current in-memory project
    puts "Creating a new in-mem design with part xc7a35tcpg236-1 ... \n"
    link_design -part xc7a35tcpg236-1; # or set_part <part>

    # Read and compile verilog (*.v) or system-verilog (*.sv) files
    puts "Reading verilog source files ... \n"
    read_verilog -sv [glob $srcdir/*.sv]

    set_param general.maxThreads 4
    synth_design -top $top -flatten_hierarchy rebuilt

    if { [glob -nocomplain $condir/*.xdc] != "" } {
        read_xdc $condir/top.xdc
    }

    # report timing summary
    report_timing_summary -file $logdir/post_sync_timing_smuuary.rpt
}
