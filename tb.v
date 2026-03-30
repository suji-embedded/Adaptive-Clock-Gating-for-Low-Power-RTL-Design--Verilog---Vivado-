`timescale 1ns/1ps

// ============================================================
// TESTBENCH MODULE: low_power_rom_tb
// ============================================================
module low_power_rom_tb;

    // --------------------------------------------------------
    // Testbench Signals
    // --------------------------------------------------------
    reg        clk;
    reg        rst;
    reg        en;
    reg  [5:0] addr;
    wire [7:0] data;

    // --------------------------------------------------------
    // Verification Variables
    // --------------------------------------------------------
    integer pass_count, fail_count;
    integer i, rb_pass, rb_fail;
    reg [7:0] ref_rom [0:63];
    reg [7:0] frozen_data;

    // --------------------------------------------------------
    // Device Under Test (DUT) Instantiation
    // --------------------------------------------------------
    low_power_rom dut (
        .clk  (clk),
        .rst  (rst),
        .en   (en),
        .addr (addr),
        .data (data)
    );

    // --------------------------------------------------------
    // Clock Generation (50 MHz / 20ns period to match constraints)
    // --------------------------------------------------------
    initial clk = 0;
    always #10 clk = ~clk;

    // --------------------------------------------------------
    // Task: Initialize Reference Data (Matches DUT)
    // --------------------------------------------------------
    task init_ref_rom;
        begin
            ref_rom[0]=8'hA5;  ref_rom[1]=8'h3C;  ref_rom[2]=8'hF0;  ref_rom[3]=8'h69;
            ref_rom[4]=8'hB4;  ref_rom[5]=8'h1E;  ref_rom[6]=8'hD2;  ref_rom[7]=8'h87;
            ref_rom[8]=8'h4A;  ref_rom[9]=8'hC3;  ref_rom[10]=8'h7B; ref_rom[11]=8'h2F;
            ref_rom[12]=8'hE6; ref_rom[13]=8'h58; ref_rom[14]=8'h91; ref_rom[15]=8'hAD;
            ref_rom[16]=8'h34; ref_rom[17]=8'hFE; ref_rom[18]=8'h0B; ref_rom[19]=8'h76;
            ref_rom[20]=8'hC9; ref_rom[21]=8'h52; ref_rom[22]=8'h1D; ref_rom[23]=8'hEA;
            ref_rom[24]=8'h83; ref_rom[25]=8'h4F; ref_rom[26]=8'hB0; ref_rom[27]=8'h27;
            ref_rom[28]=8'h6E; ref_rom[29]=8'hD5; ref_rom[30]=8'h39; ref_rom[31]=8'hC1;
            ref_rom[32]=8'hAB; ref_rom[33]=8'h5C; ref_rom[34]=8'hF7; ref_rom[35]=8'h08;
            ref_rom[36]=8'h64; ref_rom[37]=8'h9E; ref_rom[38]=8'h31; ref_rom[39]=8'hDA;
            ref_rom[40]=8'h47; ref_rom[41]=8'hBC; ref_rom[42]=8'h72; ref_rom[43]=8'h2A;
            ref_rom[44]=8'hE1; ref_rom[45]=8'h55; ref_rom[46]=8'h98; ref_rom[47]=8'hCD;
            ref_rom[48]=8'h16; ref_rom[49]=8'hF3; ref_rom[50]=8'h8A; ref_rom[51]=8'h45;
            ref_rom[52]=8'hBE; ref_rom[53]=8'h29; ref_rom[54]=8'h71; ref_rom[55]=8'hEC;
            ref_rom[56]=8'h0D; ref_rom[57]=8'h6A; ref_rom[58]=8'hC5; ref_rom[59]=8'h38;
            ref_rom[60]=8'hF9; ref_rom[61]=8'h42; ref_rom[62]=8'h1B; ref_rom[63]=8'hD7;
        end
    endtask

    // --------------------------------------------------------
    // Main Stimulus and Checking Block
    // --------------------------------------------------------
    initial begin
        pass_count = 0; fail_count = 0;
        clk = 0; rst = 0; en = 0; addr = 6'd0;
        init_ref_rom();

        $display("\n======================================================");
        $display(" STARTING LOW POWER ROM SIMULATION");
        $display("======================================================");

        // ----------------------------------------------------
        // TC1: Asynchronous Reset Check
        // ----------------------------------------------------
        $display("\n[TC1] Testing Asynchronous Reset...");
        #12 rst = 1; 
        #25 rst = 0; // Released off-edge to avoid race condition
        
        @(posedge clk); #1;
        if (data === 8'h00) begin
            $display("  PASS | Data correctly cleared to 0x00 after reset.");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | Data is 0x%02X (Expected 0x00)", data);
            fail_count = fail_count + 1;
        end

        // ----------------------------------------------------
        // TC2: Clock Gating (Disabled) Check
        // ----------------------------------------------------
        $display("\n[TC2] Testing Clock Gate OFF (en=0)...");
        en = 0;
        frozen_data = data;
        
        addr = 6'd10; #40;
        addr = 6'd25; #40;
        addr = 6'd63; #40;
        
        if (data === frozen_data) begin
            $display("  PASS | Data remained stable at 0x%02X while en=0.", data);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | Data changed to 0x%02X while en=0 (Gate leak!)", data);
            fail_count = fail_count + 1;
        end

        // ----------------------------------------------------
        // TC3: Single Read Check (Enable ROM)
        // ----------------------------------------------------
        $display("\n[TC3] Enable ROM and Read Addr 42...");
        @(posedge clk); #2; // Assign inputs just after posedge
        en = 1; 
        addr = 6'd42;
        
        @(posedge clk); #1; 
        if (data === ref_rom[42]) begin
            $display("  PASS | Addr 42 read successfully: 0x%02X", data);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | Addr 42 got 0x%02X (Expected 0x%02X)", data, ref_rom[42]);
            fail_count = fail_count + 1;
        end

        // ----------------------------------------------------
        // TC4: Reactive Power Saving Check (Hold Address)
        // ----------------------------------------------------
        $display("\n[TC4] Testing Reactive Clock Gate (Hold Address)...");
        @(posedge clk); #2; 
        addr = 6'd20;
        @(posedge clk); #1; 
        frozen_data = data;
        
        repeat(5) @(posedge clk); #1;
        
        if (data === frozen_data && data === ref_rom[20]) begin
            $display("  PASS | Data stable at 0x%02X across 5 cycles. (Clock gate working)", frozen_data);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | Data corrupted on repeated address!");
            fail_count = fail_count + 1;
        end

        // ----------------------------------------------------
        // TC5: Full ROM Readback Sweep
        // ----------------------------------------------------
        $display("\n[TC5] Full 64-Address Readback Sweep...");
        rb_pass = 0; rb_fail = 0;
        
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk); #2; 
            addr = i[5:0];
            @(posedge clk); #1; 
            
            if (data === ref_rom[i]) begin
                rb_pass = rb_pass + 1;
            end else begin
                $display("  FAIL | Addr: %2d | Expected: 0x%02X | Got: 0x%02X", i, ref_rom[i], data);
                rb_fail = rb_fail + 1;
            end
        end
        
        if (rb_fail == 0) begin
            $display("  PASS | All 64 locations matched successfully! (%0d/64)", rb_pass);
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL | %0d mismatches out of 64.", rb_fail);
            fail_count = fail_count + 1;
        end

        // ----------------------------------------------------
        // Summary
        // ----------------------------------------------------
        $display("\n======================================================");
        $display(" TEST SUMMARY");
        $display("======================================================");
        $display(" Tests Passed : %0d", pass_count);
        $display(" Tests Failed : %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n  >>> SIMULATION PASSED SUCCESSFULLY <<< \n");
        else
            $display("\n  >>> SIMULATION FAILED <<< \n");
            
        $finish; 
    end
endmodule
