# Set up the simulation environment
set PROB1_DIR [file normalize "$env(PWD)/prob1"]

quit -sim
vlib work
vmap work work

# Compile problem 1 files
vlog -sv "$PROB1_DIR/mem.sv"
vlog -sv "$PROB1_DIR/mem_controller.sv"
vlog -sv "$PROB1_DIR/processor.sv"

# Run simulation
vsim -voptargs=+acc work.processor
do wave.do
run -all
