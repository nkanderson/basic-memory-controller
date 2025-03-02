//////////////////////////////////////////////////////////////
// tc_mc_top.sv - Top level module for testing memory controller
//
// Author: Niklas Anderson (niklas2@pdx.edu)
// Date: Feb 26, 2025
//
// Description:
// ------------
// Top level module which instantiates the interface, memory
// controller, and the processor. Also generates the clock and
// reset signal in order to start the system.
//
////////////////////////////////////////////////////////////////

module tc_mc_top;

  // Clock and Reset
  logic clk = 0;
  logic resetH = 1;

  // Clock generation
  always #5 clk = ~clk;  // 10ns period (100MHz clock)

  mainbus_if bus(clk, resetH);

  processor proc(bus.primary);
  mem_controller mc(bus.secondary);

  initial begin
    // Reset sequence
    resetH = 1;
    repeat (2) @(posedge clk);
    resetH = 0;
    repeat (2) @(posedge clk);
  end
endmodule
