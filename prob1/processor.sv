//////////////////////////////////////////////////////////////
// processor.sv - Simulate a processor to test a memory controller
//
// Author: Niklas Anderson (niklas2@pdx.edu)
// Date: Feb 26, 2025
//
// Description:
// ------------
// Serves as a testbench for a memory controller module.
// Does this by simulating a processor.
//
////////////////////////////////////////////////////////////////

module processor;

  // Clock and Reset
  logic clk = 0;
  logic resetH = 1;

  // Bus Signals
  tri [15:0] AddrData;
  logic AddrValid;
  logic rw;

  // Internal drive signal for AddrData
  logic [15:0] AddrData_drive;
  assign AddrData = (AddrValid) ? AddrData_drive : 'z;

  // Memory Controller Instance
  mem_controller #(
      .PAGE(4'h2)
  ) dut (
      .AddrData(AddrData),
      .clk(clk),
      .resetH(resetH),
      .AddrValid(AddrValid),
      .rw(rw)
  );

  // Clock generation
  always #5 clk = ~clk;  // 10ns period (100MHz clock)

  // Task to perform a write operation
  task write(input logic [15:0] base_addr, input logic [15:0] data[4]);
    rw = 0;
    AddrData_drive = base_addr;
    AddrValid = 1;
    @(posedge clk);
    AddrValid = 0;
    @(posedge clk);

    // Drive the data over four cycles
    for (int i = 0; i < 4; i++) begin
      AddrData_drive = data[i];
      @(posedge clk);
    end

    // Release the bus
    AddrData_drive = 'z;
  endtask

  // Task to perform a read operation
  task read(input logic [15:0] base_addr, output logic [15:0] data[4]);
    rw = 1;
    AddrData_drive = base_addr;
    AddrValid = 1;
    @(posedge clk);
    AddrValid = 0;
    // Release bus after address phase
    AddrData_drive = 'z;
    @(posedge clk);

    // Capture read data over four cycles
    for (int i = 0; i < 4; i++) begin
      data[i] = AddrData;
      @(posedge clk);
    end
  endtask

  // Test sequence
  initial begin
    logic [15:0] read_data [4];
    logic [15:0] write_data[4] = '{16'hABCD, 16'h1234, 16'h5678, 16'h9ABC};

    // Reset sequence
    resetH = 1;
    AddrValid = 0;
    AddrData_drive = 'z;
    repeat (2) @(posedge clk);
    resetH = 0;
    repeat (2) @(posedge clk);

    // 1. Write to a valid address within PAGE 0x2
    $display("Writing to valid address 0x2000...");
    write(16'h2000, write_data);
    repeat (5) @(posedge clk);

    // 2. Read back from valid address
    $display("Reading from valid address 0x2000...");
    read(16'h2000, read_data);
    for (int i = 0; i < 4; i++) begin
      if (read_data[i] == write_data[i]) $display("PASS: Read correct data 0x%h", read_data[i]);
      else $display("FAIL: Read incorrect data 0x%h", read_data[i]);
    end
    repeat (5) @(posedge clk);

    // 3. Attempt to write to an invalid address (not in PAGE 0x2)
    $display("Writing to invalid address 0x5000...");
    write(16'h5000, write_data);
    repeat (5) @(posedge clk);

    // 4. Attempt to read from invalid address
    $display("Reading from invalid address 0x5000...");
    read(16'h5000, read_data);
    for (int i = 0; i < 4; i++) begin
      if (read_data[i] == write_data[i]) $display("FAIL: Memory responded to invalid address!");
      else $display("PASS: Memory ignored invalid address.");
    end

    $finish;
  end
endmodule
