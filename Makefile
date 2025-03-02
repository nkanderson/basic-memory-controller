# Paths
PROB1_DIR = prob1
PROB1_DIR = prob2
SIM_DIR = sim
WORK_DIR = work

# QuestaSim Commands
VLOG = vlog -sv
VSIM = vsim -c -do

# Problem 1 Files
PROB1_FILES = $(PROB1_DIR)/mem.sv \
            $(PROB1_DIR)/mem_controller.sv \
            $(PROB1_DIR)/processor.sv

# Problem 2 Files
PROB2_FILES = $(PROB2_DIR)/mainbus_if.sv \
						$(PROB2_DIR)/mem.sv \
            $(PROB2_DIR)/mem_controller.sv \
            $(PROB2_DIR)/processor.sv \
						$(PROB2_DIR)/tc_mc_top.sv

# TODO: Decide if it's worthwhile to add prob2 files, which will
# likely require setting up separate work directories since there
# are duplicate module names between prob1 and prob2

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
