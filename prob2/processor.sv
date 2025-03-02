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

module processor(mainbus_if.primary bus);

  // Internal drive signal for AddrData
  logic [15:0] AddrData_drive;
  assign bus.AddrData = (bus.AddrValid || !bus.rw) ? AddrData_drive : 'z;

  // Task to perform a write operation
  task write(input logic [15:0] base_addr, input logic [15:0] data[4]);
    bus.rw = 0;
    AddrData_drive = base_addr;
    bus.AddrValid = 1;
    @(posedge bus.clk);
    bus.AddrValid = 0;

    // Drive the data over four cycles
    for (int i = 0; i < 4; i++) begin
      AddrData_drive = data[i];
      @(posedge bus.clk);
    end

    // Release the bus
    AddrData_drive = 'z;
  endtask

  // Task to perform a read operation
  task read(input logic [15:0] base_addr, output logic [15:0] data[4]);
    bus.rw = 1;
    AddrData_drive = base_addr;
    AddrValid = 1;
    @(posedge bus.clk);
    bus.AddrValid = 0;
    // Release bus after address phase
    AddrData_drive = 'z;
    @(posedge bus.clk);

    // Capture read data over four cycles
    for (int i = 0; i < 4; i++) begin
      data[i] = bus.AddrData;
      @(posedge bus.clk);
    end
  endtask

  // Test sequence
  initial begin
    logic [15:0] read_data [4];
    logic [15:0] write_data[4] = '{16'hABCD, 16'h1234, 16'h5678, 16'h9ABC};

    // Reset sequence
    bus.AddrValid = 0;
    AddrData_drive = 'z;
    // wait for top's reset to complete
    // TODO: Is there a better way to do this than to hardcode a known wait?
    repeat (4) @(posedge bus.clk);

    // 1. Write to a valid address within PAGE 0x2
    $display("Writing to valid address 0x2000...");
    write(16'h2000, write_data);
    repeat (5) @(posedge bus.clk);

    // 2. Read back from valid address
    $display("Reading from valid address 0x2000...");
    read(16'h2000, read_data);
    for (int i = 0; i < 4; i++) begin
      if (read_data[i] == write_data[i]) $display("PASS: Read correct data 0x%h", read_data[i]);
      else $display("FAIL: Read incorrect data 0x%h", read_data[i]);
    end
    repeat (5) @(posedge bus.clk);

    // 3. Attempt to write to an invalid address (not in PAGE 0x2)
    $display("Writing to invalid address 0x5000...");
    write(16'h5000, write_data);
    repeat (5) @(posedge bus.clk);

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
