//////////////////////////////////////////////////////////////
// mem_controller.sv - Memory controller to interface with memory
//
// Author: Niklas Anderson (niklas2@pdx.edu)
// Date: Feb 26, 2025
//
// Description:
// ------------
// A memory controller to interface with a memory module.
// Supports multiple cycle read and write operations.
//
////////////////////////////////////////////////////////////////

module mem_controller #(
    parameter logic [3:0] PAGE = 4'h2
) (
    // Multiplexed AddrData bus. On a write
    // operation the address, followed by 4 data
    // items are driven onto AddrData by the
    // CPU (your testbench). On a read operation the
    // CPU (your testbench) will drive the
    // address onto AddrData and tristate its
    // AddrData drivers. Your memory controller
    // will drive the data from the memory onto
    // the AddrData bus.
    inout tri [15:0] AddrData,
    // clock to the memory controller and memory
    input logic clk,
    // Asserted high to reset the memory controller
    input logic resetH,
    // Asserted high to indicate that there is a
    // valid address on AddrData. This kicks off
    // a new memory read or write cycle
    input logic AddrValid,
    // Asserted high for a read, low for a write// valid during the cycle(s) where AddrValid
    // is asserted
    input logic rw
);


endmodule
