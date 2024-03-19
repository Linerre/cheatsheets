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
set testdir ./test
if { [file isdirectory $testdir] > 0 } {
    puts "$testdir already exists; skipping ... \n"
} else {
    puts "Creating $testdir ... \n"
    file mkdir $testdir
}


# STEP#1: define a procedure (function) that read, compile, synth, and implement
# the given design `$top` and write it into bitstreams.

# [expr] returns a value
# read_verilog [ glob -directory ./src/ *.v ]; #

proc compile { top } {
    puts "Closing the current in-memory design ... \n"
    close_project -quiet

    # Assign part (board) to the current in-memory project
    puts "Creating a new in-mem design with part xc7a35tcpg236-1 ... \n"
    link_design -part xc7a35tcpg236-1; # or set_part <part>

    # Read and compile verilog (*.v) or system-verilog (*.sv) files
    puts "Reading verilog source files ... \n"
    read_verilog [glob $srcdir/*.v]

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
    if { [glob -nocomplain $srcdir/*.xdc] != "" } {
        read_xdc $srcdir/$top.xdc
    }

    # Set necessary properties for generating bitstream
    # set_property CFGBVS VCCO [current_design]
    # set_property CONFIG_VOLTAGE 3.3 [current_design]

    # Could possibly opt_design here
    puts "Placing design ...\n"
    place_desing

    puts "Routing design ...\n"
    route_design

    # Checkpoint is the data that records all the necessary detail for restoring
    # the project state exactly back at the recorded point
    puts "Writing checkpoint ...\n"
    write_checkpoint -force $logdir/$top.dcp

    puts "Writing bitstream ... \n"
    write_bitstream -force $top.bit

    puts "All done!"
}

# Check syntax for verilog code
proc flycheck {} {
    check_syntax -fileset [glob ./src/*.v]
}

# Elaborate the design (see gates, registers, etc described in
# verilog). This style of system visualisation is called RTL
# framework. This needs start_gui after running the commands.
proc rtl { top } {
    close_project

    read_verilog [glob ./src/$top.v]
    read_verilog -quiet [glob -nocomplain ./src/$top.xdc]; # constraints could be absent
    synth_design -top $top -part xc7a35tcpg236-1 -rtl
    start_gui

    # In the GUI, at the bottom, type in `stop_gui` in the Tcl console to close it
}


# Simulate with given testbenches (behavioral simulation only)
proc simu {} {
    close_project -quiet

    set simdir ./sim_output
    if { [file isdirectory $simdir] == 0 } {
        puts "Creating sim output dir ... \n"
        file mkdir $simdir
    }


    # Set target simulator (default Vivado simulator) for current in-mem project
    set_property TARGET_SIMULATOR XSim [current_project]
}
