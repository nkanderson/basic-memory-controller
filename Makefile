# Paths
PROB1_DIR = prob1
SIM_DIR = sim
WORK_DIR = work

# QuestaSim Commands
VLOG = vlog -sv
VSIM = vsim -c -do

# Problem 1 Files
PROB1_FILES = $(PROB1_DIR)/mem.sv \
            $(PROB1_DIR)/mem_controller.sv \
            $(PROB1_DIR)/processor.sv

# Default target
all: compile simulate

# Create working directory
init:
	@vlib $(WORK_DIR)
	@vmap work $(WORK_DIR)

# Compile
compile: init
	$(VLOG) $(PROB1_FILES)

# Run simulation
simulate:
	$(VSIM) $(SIM_DIR)/run_questa.tcl

# Clean up generated files
clean:
	rm -rf $(WORK_DIR) transcript vsim.wlf

.PHONY: all init compile simulate clean
