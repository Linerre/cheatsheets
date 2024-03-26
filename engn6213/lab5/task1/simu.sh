#!/usr/bin/env bash

# Bash script for simulation in Non-Project mode of Vivado
# Note: commands used in this script are binaries shipped
# with Vivado and placed under ~/Xilinx/Vivado/2023.2/bin/

# STEP#0: Setup a directory for the simulation files/output
export XILINX_VIVADO=${HOME}/Xilinx/Vivado/2023.2
SIMDIR=./simulation
[[ ! -d $SIMDIR ]] && mkdir $SIMDIR
echo "Entering $SIMDIR/ ..."
cd $SIMDIR

# See UG937 Ch.4
# STEP#1: Read testbench files to prepare the simulation
# Use a <file_name>.prj file. For this task, see tb_softcore_proc.prj
# under the root dir

# STEP#2: Use `xelab` (shipped with Vivado) to build a snapshot
# Note the top unit should be the one declared in the testbench
# the `work` is the default library generated in STEP#1
# The `debug` flag is mandatory and set its value to the default
# This will create the trace info required by waveform display
# The `-stat` flag prints tool CPU and memory usages
# The -snapshot or -s specifies the output snapshot name, deafults
# xil_defaultlib is specificed in the prj file by default
echo "Start building simulation snapshot ..."
xelab -stat --relax -prj ../tb_softcore_proc.prj -debug typical \
      -snapshot tb_softcore_proc_behav xil_defaultlib.tb_softcore_proc


# STEP#3: Use `xsim` to simulate the snapshot created in above step
# -wdb flag will create the specificed waveform database output file
# -runall or -R will run the simulation; otherwise no waveform in GUI
# It's also possible to save a *.wcfg for reuse in future wave config
# See UG937 Ch.3 Step 6: Saving the Waveform Configuration
echo "Start simulating ..."
xsim tb_softcore_proc_behav -runall -log elaborate.log

# STEP#4 (Optional): Once in GUI, in the Tcl console, `run -all` to run the simulation
# xsim tb_softcore_proc_behav -gui -wdb softcore_proc.wdb -log elaborate.log
# -runall tb_softcore_proc_behav

# from Vivado guid
# xelab --incr --debug typical --relax --mt 8 -L xil_defaultlib -L uvm -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_softcore_proc_behav xil_defaultlib.tb_softcore_proc xil_defaultlib.glbl -log elaborate.log
