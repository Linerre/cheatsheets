#!/usr/bin/env bash

# Bash script for simulation in Non-Project mode of Vivado
# Note: commands used in this script are binaries shipped
# with Vivado and placed under ~/Xilinx/Vivado/2023.2/bin/
# The script does NOT use a *.prj file for xelab (-prj switch);
# instead, it uses xvlog to parse testbench files

# STEP#0: Setup a directory for the simulation files/output

export XILINX_VIVADO=${HOME}/Xilinx/Vivado/2023.2
SIMDIR=./simulation
[[ ! -d $SIMDIR ]] && mkdir $SIMDIR
echo "Entering $SIMDIR/ ..."
cd $SIMDIR

# STEP#1: Read testbench files to prepare the simulation
# `xvlog`parses verilog files and store the result as a dump into
# an HDL library on disk. Pass `-work` to specify its name
# (defaults to work)
echo "Start parsing verilog source and testbench files ..."
xvlog -log ./xsim_src.log ../src/my_mux.v
xvlog -log ./xsim_tb.log ../test/TB_my_mux.v

# STEP#2: Use `xelab` (shipped with Vivado) to build a snapshot
# Note the top unit should be the one declared in the testbench
# the `work` is the default library generated in STEP#0
# The `debug` flag is mandatory and set its value to the default
# This will create the trace info required by waveform display
# The `-stat` flag prints tool CPU and memory usages
# The -snapshot or -s specifies the output snapshot name, deafults
# to worklib.<topunit> where <topunit> is declared in testbench
echo "Start building simulation snapshot ..."
xelab -debug typical -stat -snapshot behav_sim_my_mux work.TB_my_mux


# STEP#3: Use `xsim` to simulate the snapshot created in above step
# -wdb flag will create the specificed waveform database output file
# -runall or -R will run the simulation; otherwise no waveform in GUI
# It's also possible to save a *.wcfg for reuse in future wave config
# See UG937 Ch.3 Step 6: Saving the Waveform Configuration
echo "Start simulating ..."
xsim -gui -wdb my_mux_xsim.wdb -runall behav_sim_my_mux
