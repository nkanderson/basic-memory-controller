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

  // Store the address and next address in buffers
  logic [7:0] addr_buff, next_addr_buff;
  // Determine whether this is a read or write
  // This is registered and updates with the state in order
  // to avoid any race conditions that could result from it being
  // a wire driven with continuous assignment
  logic read, next_read;
  // Flag to indicate whether this page is one our memory
  // controller should respond to
  logic is_page;
  // Wire for memory connections
  wire [15:0] mem_data;

  // States for read / write sequence
  typedef enum logic [2:0] {
    WAIT_STATE,
    DATA1,
    DATA2,
    DATA3,
    DATA4
  } state_t;
  state_t state, next_state;

  // If we're reading, allow the mem module to drive through mem_data
  assign AddrData = (read && state != WAIT_STATE) ? mem_data : 'z;
  // If we're not reading, allow the CPU to drive mem_data
  assign mem_data = (!read && state != WAIT_STATE) ? AddrData : 'z;

  // Page mask
  localparam logic [15:0] PAGE_MASK = 16'hF000;
  assign is_page = AddrValid && ((PAGE_MASK & AddrData) == ({12'b0, PAGE} << 12));

  // Instantiate system memory
  mem system_mem (
      .clk (clk),
      .rdEn(read),
      .wrEn(~read),
      .Addr(addr_buff),
      .Data(mem_data)
  );

  // State update transition
  always_ff @(posedge clk or posedge resetH) begin : update_state
    if (resetH) begin
      state <= WAIT_STATE;
    end
    else begin
      state <= next_state;
      addr_buff <= next_addr_buff;
      read <= next_read;
    end
  end : update_state

  // Next state logic
  always_comb begin : next_state_logic
    // Assume the same read status except for leaving the wait state
    next_read = read;
    unique case (state)
      WAIT_STATE: begin
        if (AddrValid && is_page) begin
          next_state = DATA1;
          next_addr_buff = AddrData[7:0];
          next_read = rw;
        end else begin
          next_state = WAIT_STATE;
        end
      end
      DATA1: begin
        next_state = DATA2;
        next_addr_buff = addr_buff + 1;
      end
      DATA2: begin
        next_state = DATA3;
        next_addr_buff = addr_buff + 1;
      end
      DATA3: begin
        next_state = DATA4;
        next_addr_buff = addr_buff + 1;
      end
      DATA4: begin
        next_state = WAIT_STATE;
        next_addr_buff = 'z;
      end
    endcase
  end : next_state_logic

endmodule
