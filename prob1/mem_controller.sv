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
  // Should be set to 1 if this is a read, 0 if a write
  logic is_read;
  // Flag to indicate whether this page is one our memory
  // controller should respond to
  logic is_page;
  // Flag to indicate whether to drive the bus or relinquish to CPU
  logic drive_bus;
  // TODO? Maybe only need one data_reg? Or none?
  // Store data that comes from the CPU (data_write) and data to be
  // read by the CPU (data_read)
  logic [15:0] data_write, data_read;
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

  // FIXME: This appears to work, along with the next state logic that ensures
  // the next address after the last write is 'z. But it seems possible it will
  // be vulnerable to race conditions.
  // Tri-state buffer control for AddrData and mem_data
  assign drive_bus = is_read && state != WAIT_STATE;
  assign AddrData  = drive_bus ? data_read : 'z;
  // mem_data (the mem module's Data inout) can be written to or allow the
  // mem module to drive it
  assign mem_data  = (!is_read && state != WAIT_STATE) ? data_write : 'z;
  // If we're reading, allow the mem module to drive
  assign data_read = is_read ? mem_data : 'z;
  // If we're not reading, allow the CPU to drive data_write
  assign data_write = !is_read ? AddrData : 'z;
  // TODO: Can maybe simplify to the following:
  // assign AddrData = (is_read && state != WAIT_STATE) ? mem_data : 'z;
  // assign mem_data = (!is_read && state != WAIT_STATE) ? AddrData : 'z;
  // then remove drive_bus, data_read, and data_write

  // Page mask
  localparam logic [15:0] PAGE_MASK = 16'hF000;
  assign is_page = AddrValid && ((PAGE_MASK & AddrData) == ({12'b0, PAGE} << 12));

  // Instantiate system memory
  mem system_mem (
      .clk (clk),
      .rdEn(is_read),
      .wrEn(~is_read),
      .Addr(addr_buff),
      .Data(mem_data)
  );

  // FIXME: This lags behind one cycle, but is maybe less prone
  // to the data races that could arise with continuous assign
  // Capture data from the memory for reads
  // otherwise write memory data to AddrData
  // always_ff @(posedge clk) begin : read_data
  //   if (state != WAIT_STATE) begin
  //     if (is_read) data_read <= mem_data;
  //     else data_write <= AddrData;
  //   end
  // end : read_data

  // State update transition
  always_ff @(posedge clk or posedge resetH) begin : update_state
    if (resetH) begin
      state <= WAIT_STATE;
    end
    else begin
      state <= next_state;
      addr_buff <= next_addr_buff;
    end
  end : update_state

  // Next state logic
  always_comb begin : next_state_logic
    unique case (state)
      WAIT_STATE: begin
        if (AddrValid && is_page) begin
          next_state = DATA1;
          next_addr_buff = AddrData[7:0];
          // TODO? Is it possible for a write to occur before the correct address
          // has been written to addr_buff? Like if the prior addr is maintained
          // I think this might need to be registered
          is_read = rw;
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
