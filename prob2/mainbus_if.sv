//////////////////////////////////////////////////////////////
// mainbus_if.sv - Main bus inferface for memory system
//
// Author: Niklas Anderson (niklas2@pdx.edu)
// Date: Feb 26, 2025
//
// Description:
// ------------
// Memory system bus interface. Includes clock and reset signals,
// along with the addrData, addrValid, and rw signals.
// Implements a primary modport for the processor, and secondary
// modport for the memory controller.
//
////////////////////////////////////////////////////////////////

interface mainbus_if (
    input logic clk,
    resetH
);
  wire [15:0] AddrData;
  logic AddrValid, rw;

  // Processor-side
  modport primary(inout AddrData, input clk, resetH, output AddrValid, rw);

  // Memory controller-side
  modport secondary(inout AddrData, input clk, resetH, AddrValid, rw);

endinterface
