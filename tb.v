`timescale 1ns / 1ps

// ==============================================================================
// TESTBENCH
// ==============================================================================
module tb_rom_lookahead;

    // ── DUT signals ──────────────────────────────────────────────────────
    reg        clk, rst, en;
    reg  [5:0] addr;
    wire [7:0] data;
    wire       gated_clk;

    // ── Instantiate DUT ──────────────────────────────────────────────────
    rom_lookahead DUT (
        .clk      (clk),
        .rst      (rst),
        .en       (en),
        .addr     (addr),
        .data     (data),
        .gated_clk(gated_clk)
    );

    // ── 10 ns clock (50 MHz) ─────────────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Power metrics ─────────────────────────────────────────────────────
    integer clk_count       = 0;
    integer gated_clk_count = 0;

    always @(posedge clk)      clk_count       = clk_count + 1;
    always @(posedge gated_clk) gated_clk_count = gated_clk_count + 1;

    // ── Gray code helper (for $display) ──────────────────────────────────
    function [5:0] to_gray;
        input [5:0] b;
        begin
            to_gray[5] = b[5];
            to_gray[4] = b[5] ^ b[4];
            to_gray[3] = b[4] ^ b[3];
            to_gray[2] = b[3] ^ b[2];
            to_gray[1] = b[2] ^ b[1];
            to_gray[0] = b[1] ^ b[0];
        end
    endfunction

    // ── ROM reference model ───────────────────────────────────────────────
    function [7:0] expected_data;
        input [5:0] bin_addr;
        reg [5:0] g;
        begin
            g = to_gray(bin_addr);
            case (g)
                6'h00: expected_data = 8'hA1; 6'h01: expected_data = 8'hB2;
                6'h03: expected_data = 8'hC3; 6'h02: expected_data = 8'hD4;
                6'h06: expected_data = 8'hE5; 6'h07: expected_data = 8'hF6;
                6'h05: expected_data = 8'h07; 6'h04: expected_data = 8'h18;
                6'h0C: expected_data = 8'h29; 6'h0D: expected_data = 8'h3A;
                6'h0F: expected_data = 8'h4B; 6'h0E: expected_data = 8'h5C;
                6'h0A: expected_data = 8'h6D; 6'h0B: expected_data = 8'h7E;
                6'h09: expected_data = 8'h8F; 6'h08: expected_data = 8'h90;
                6'h18: expected_data = 8'hA2; 6'h19: expected_data = 8'hB3;
                6'h1B: expected_data = 8'hC4; 6'h1A: expected_data = 8'hD5;
                6'h1E: expected_data = 8'hE6; 6'h1F: expected_data = 8'hF7;
                6'h1D: expected_data = 8'h08; 6'h1C: expected_data = 8'h19;
                6'h14: expected_data = 8'h2A; 6'h15: expected_data = 8'h3B;
                6'h17: expected_data = 8'h4C; 6'h16: expected_data = 8'h5D;
                6'h12: expected_data = 8'h6E; 6'h13: expected_data = 8'h7F;
                6'h11: expected_data = 8'h80; 6'h10: expected_data = 8'h91;
                6'h30: expected_data = 8'hA3; 6'h31: expected_data = 8'hB4;
                6'h33: expected_data = 8'hC5; 6'h32: expected_data = 8'hD6;
                6'h36: expected_data = 8'hE7; 6'h37: expected_data = 8'hF8;
                6'h35: expected_data = 8'h09; 6'h34: expected_data = 8'h1A;
                6'h3C: expected_data = 8'h2B; 6'h3D: expected_data = 8'h3C;
                6'h3F: expected_data = 8'h4D; 6'h3E: expected_data = 8'h5E;
                6'h3A: expected_data = 8'h6F; 6'h3B: expected_data = 8'h70;
                6'h39: expected_data = 8'h81; 6'h38: expected_data = 8'h92;
                6'h28: expected_data = 8'hA4; 6'h29: expected_data = 8'hB5;
                6'h2B: expected_data = 8'hC6; 6'h2A: expected_data = 8'hD7;
                6'h2E: expected_data = 8'hE8; 6'h2F: expected_data = 8'hF9;
                6'h2D: expected_data = 8'h0A; 6'h2C: expected_data = 8'h1B;
                6'h24: expected_data = 8'h2C; 6'h25: expected_data = 8'h3D;
                6'h27: expected_data = 8'h4E; 6'h26: expected_data = 8'h5F;
                6'h22: expected_data = 8'h60; 6'h23: expected_data = 8'h71;
                6'h21: expected_data = 8'h82; 6'h20: expected_data = 8'h93;
                default: expected_data = 8'hFF;
            endcase
        end
    endfunction

    // ── Test tracking ─────────────────────────────────────────────────────
    integer pass_count = 0;
    integer fail_count = 0;

    task check_data;
        input [5:0]  test_addr;
        input [7:0]  got;
        input [7:0]  exp;
        input [63:0] test_name; 
        begin
            if (got === exp) begin
                pass_count = pass_count + 1;
                $display("  PASS | addr=%02h gray=%06b | got=%02h exp=%02h | %s",
                    test_addr, to_gray(test_addr), got, exp, test_name);
            end else begin
                fail_count = fail_count + 1;
                $display("  FAIL | addr=%02h gray=%06b | got=%02h exp=%02h | %s  <<<<",
                    test_addr, to_gray(test_addr), got, exp, test_name);
            end
        end
    endtask

    // ── Stimulus ──────────────────────────────────────────────────────────
    integer i;
    integer hold_pulses_before, hold_pulses_after;

    initial begin
        $dumpfile("tb_rom_lookahead.vcd");
        $dumpvars(0, tb_rom_lookahead);

        $display("========================================================");
        $display(" Adaptive Clock Gating ROM - Testbench");
        $display(" clk=50MHz  addr=6b  data=8b  Gray-coded ROM");
        $display("========================================================");

        // ── TEST 1: Reset ─────────────────────────────────────────────────
        $display("\n[TEST 1] Reset behaviour");
        rst = 1; en = 1; addr = 6'd0;
        repeat(3) @(posedge clk); #1;
        if (data === 8'h00)
            $display("  PASS | data=00 during reset as expected");
        else
            $display("  FAIL | data=%02h during reset, expected 00", data);
        rst = 0;
        @(posedge clk); #1;

        // ── TEST 2: Sequential walk addr 0..15 ───────────────────────────
        $display("\n[TEST 2] Sequential walk - addr 0 to 15");
        $display("         gated_clk should fire every cycle");
        for (i = 0; i < 16; i = i + 1) begin
            addr = i;
            @(posedge clk); #1;
            check_data(i, data, expected_data(i), "seq    ");
        end

        // ── TEST 3: Address hold - gated_clk must stop ───────────────────
        $display("\n[TEST 3] Address hold - addr=9 held for 5 cycles");
        $display("         gated_clk must gate OFF (0 pulses during hold)");
        addr = 6'd9;
        @(posedge clk); #1; 
        hold_pulses_before = gated_clk_count;
        repeat(5) @(posedge clk); #1;
        hold_pulses_after = gated_clk_count;
        if ((hold_pulses_after - hold_pulses_before) == 0)
            $display("  PASS | gated_clk suppressed during hold (0 extra pulses)");
        else
            $display("  FAIL | gated_clk fired %0d times during hold - should be 0",
                     hold_pulses_after - hold_pulses_before);

        // ── TEST 4: Non-sequential jump addr 9 → 30 ──────────────────────
        $display("\n[TEST 4] Non-sequential jump addr 9 -> 30");
        $display("         catch-up path must re-enable gated_clk");
        addr = 6'd30;
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_data(30, data, expected_data(30), "jump   ");

        // ── TEST 5: Non-sequential jump addr 30 → 5 ──────────────────────
        $display("\n[TEST 5] Non-sequential jump addr 30 -> 5");
        addr = 6'd5;
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_data(5, data, expected_data(5), "jump   ");

        // ── TEST 6: en=0 - gated_clk must stay low ───────────────────────
        $display("\n[TEST 6] en=0 - gated_clk must be suppressed regardless");
        en = 0;
        addr = 6'd20;
        hold_pulses_before = gated_clk_count;
        @(posedge clk); #1;
        addr = 6'd21;
        @(posedge clk); #1;
        addr = 6'd22;
        @(posedge clk); #1;
        hold_pulses_after = gated_clk_count;
        if ((hold_pulses_after - hold_pulses_before) == 0)
            $display("  PASS | gated_clk suppressed when en=0");
        else
            $display("  FAIL | gated_clk fired %0d times with en=0",
                     hold_pulses_after - hold_pulses_before);
        en = 1;

        // ── TEST 7: Wrap-around addr 63 → 0 ──────────────────────────────
        $display("\n[TEST 7] Wrap-around - addr 63 -> 0");
        addr = 6'd63;
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_data(63, data, expected_data(63), "wrap   ");
        addr = 6'd0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_data(0, data, expected_data(0), "wrap   ");

        // ── TEST 8: Full 0-63 ROM verification ───────────────────────────
        $display("\n[TEST 8] Full ROM walk - all 64 locations");
        rst = 1; @(posedge clk); #1; rst = 0;
        for (i = 0; i < 64; i = i + 1) begin
            addr = i;
            @(posedge clk); #1;
            check_data(i, data, expected_data(i), "full   ");
        end

        // ── POWER REPORT ──────────────────────────────────────────────────
        $display("\n========================================================");
        $display(" Power / Gating Efficiency Report");
        $display("========================================================");
        $display("  Total clk posedges    : %0d", clk_count);
        $display("  Total gated_clk pulses: %0d", gated_clk_count);
        $display("  Clocks gated (saved)  : %0d", clk_count - gated_clk_count);
        if (clk_count > 0)
            $display("  Gating efficiency     : %0d%%",
                     100 * (clk_count - gated_clk_count) / clk_count);

        // ── SUMMARY ───────────────────────────────────────────────────────
        $display("\n========================================================");
        $display(" Test Summary");
        $display("========================================================");
        $display("  PASS: %0d", pass_count);
        $display("  FAIL: %0d", fail_count);
        if (fail_count == 0)
            $display("  Result : ALL TESTS PASSED");
        else
            $display("  Result : %0d TEST(S) FAILED - check FAIL lines above", fail_count);
        $display("========================================================\n");

        $finish;
    end
endmodule