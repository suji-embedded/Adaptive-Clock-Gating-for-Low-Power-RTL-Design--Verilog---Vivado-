`timescale 1ns / 1ps

// ==============================================================================
// TOP MODULE: Lookahead ROM (Reactive Clock Gating)
// ==============================================================================
module rom_lookahead (
    input            clk,
    input            rst,
    input            en,
    input      [5:0] addr,       // 6-bit binary address
    output reg [7:0] data,
    output           gated_clk
);

    // ── Stage 1: Binary → Gray (current address) ─────────────────────────
    wire [5:0] gray_addr;
    assign gray_addr[5] = addr[5];
    assign gray_addr[4] = addr[5] ^ addr[4];
    assign gray_addr[3] = addr[4] ^ addr[3];
    assign gray_addr[2] = addr[3] ^ addr[2];
    assign gray_addr[1] = addr[2] ^ addr[1];
    assign gray_addr[0] = addr[1] ^ addr[0];

    // ── Stage 2: Reactive clock gate (Artix-7 BUFGCE) ────────────────────
    lookahead_clock_gate_64 LCG (
        .clk      (clk),
        .rst      (rst),
        .curr_addr(gray_addr),
        .en       (en),
        .gated_clk(gated_clk)
    );

    // ── Stage 3: 64×8 ROM - clocked ONLY by gated_clk ───────────────────
    always @(posedge gated_clk or posedge rst) begin
        if (rst) begin
            data <= 8'h00;
        end else begin
            case (gray_addr)
                6'h00: data <= 8'hA1; 6'h01: data <= 8'hB2;
                6'h03: data <= 8'hC3; 6'h02: data <= 8'hD4;
                6'h06: data <= 8'hE5; 6'h07: data <= 8'hF6;
                6'h05: data <= 8'h07; 6'h04: data <= 8'h18;
                6'h0C: data <= 8'h29; 6'h0D: data <= 8'h3A;
                6'h0F: data <= 8'h4B; 6'h0E: data <= 8'h5C;
                6'h0A: data <= 8'h6D; 6'h0B: data <= 8'h7E;
                6'h09: data <= 8'h8F; 6'h08: data <= 8'h90;
                6'h18: data <= 8'hA2; 6'h19: data <= 8'hB3;
                6'h1B: data <= 8'hC4; 6'h1A: data <= 8'hD5;
                6'h1E: data <= 8'hE6; 6'h1F: data <= 8'hF7;
                6'h1D: data <= 8'h08; 6'h1C: data <= 8'h19;
                6'h14: data <= 8'h2A; 6'h15: data <= 8'h3B;
                6'h17: data <= 8'h4C; 6'h16: data <= 8'h5D;
                6'h12: data <= 8'h6E; 6'h13: data <= 8'h7F;
                6'h11: data <= 8'h80; 6'h10: data <= 8'h91;
                6'h30: data <= 8'hA3; 6'h31: data <= 8'hB4;
                6'h33: data <= 8'hC5; 6'h32: data <= 8'hD6;
                6'h36: data <= 8'hE7; 6'h37: data <= 8'hF8;
                6'h35: data <= 8'h09; 6'h34: data <= 8'h1A;
                6'h3C: data <= 8'h2B; 6'h3D: data <= 8'h3C;
                6'h3F: data <= 8'h4D; 6'h3E: data <= 8'h5E;
                6'h3A: data <= 8'h6F; 6'h3B: data <= 8'h70;
                6'h39: data <= 8'h81; 6'h38: data <= 8'h92;
                6'h28: data <= 8'hA4; 6'h29: data <= 8'hB5;
                6'h2B: data <= 8'hC6; 6'h2A: data <= 8'hD7;
                6'h2E: data <= 8'hE8; 6'h2F: data <= 8'hF9;
                6'h2D: data <= 8'h0A; 6'h2C: data <= 8'h1B;
                6'h24: data <= 8'h2C; 6'h25: data <= 8'h3D;
                6'h27: data <= 8'h4E; 6'h26: data <= 8'h5F;
                6'h22: data <= 8'h60; 6'h23: data <= 8'h71;
                6'h21: data <= 8'h82; 6'h20: data <= 8'h93;
                default: data <= 8'hFF;
            endcase
        end
    end

endmodule

// ==============================================================================
// SUB-MODULE: Clock Gating Logic (Nexys Video / Artix-7 Specific)
// ==============================================================================
module lookahead_clock_gate_64 (
    input       clk,
    input       rst,
    input [5:0] curr_addr,   // Gray-coded current address
    input       en,          
    output      gated_clk
);
    reg [5:0] prev_addr_latch;  
    reg       just_reset; 

    // Gate opens if address changes OR if we just came out of reset
    wire lookahead_en = en & ((curr_addr != prev_addr_latch) | just_reset);

    // Track the address state synchronously on the NEGATIVE edge.
    // This ensures lookahead_en (CE pin) is stable well before the rising edge.
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            prev_addr_latch <= curr_addr; 
            just_reset      <= 1'b1; // Trigger a wake-up fetch
        end else begin
            prev_addr_latch <= curr_addr; 
            if (lookahead_en) begin
                just_reset <= 1'b0; // Deassert once we've successfully fetched
            end
        end
    end

    // Xilinx 7-Series Hardware Clock Gate Primitive
    BUFGCE BUFGCE_inst (
        .O(gated_clk),    // 1-bit output: Gated clock output
        .CE(lookahead_en), // 1-bit input: Clock enable input
        .I(clk)           // 1-bit input: Main clock input
    );

endmodule