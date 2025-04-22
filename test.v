module top_module (
    input wire clk,
    input wire rst,
    input wire [3:0] a,   // 4-bit input 'a'
    input wire [3:0] b,   // 4-bit input 'b'
    output wire [3:0] y   // 4-bit output 'y'
);

    // Internal wires for gate outputs
    wire and_out, or_out, xor_out, nand_out, nor_out, inv_out, buf_out, mux_out;

    // Submodule instances
    and_gate u_and (.in1(a[0]), .in2(b[0]), .out(and_out));    // AND gate
    or_gate  u_or  (.in1(a[1]), .in2(b[1]), .out(or_out));      // OR gate
    xor_gate u_xor (.in1(a[2]), .in2(b[2]), .out(xor_out));    // XOR gate
    nand_gate u_nand (.in1(a[3]), .in2(b[3]), .out(nand_out));  // NAND gate
    nor_gate  u_nor  (.in1(a[0]), .in2(b[0]), .out(nor_out));   // NOR gate
    inv_gate  u_inv  (.in(a[1]), .out(inv_out));                // NOT gate (Inverter)
    buf_gate  u_buf  (.in(b[1]), .out(buf_out));                // BUFFER gate
    mux2      u_mux  (.a(a[2]), .b(b[2]), .sel(a[0]), .y(mux_out)); // 2-to-1 MUX

    // Flip-Flop (DFF) instance
    dff u_dff (
        .clk(clk),
        .d(a[3]),
        .q(y[0])
    );

    // Assign other outputs
    assign y[1] = or_out;
    assign y[2] = xor_out;
    assign y[3] = mux_out;

endmodule

// Gate-level modules

// AND Gate
module and_gate(input wire in1, in2, output wire out);
    assign out = in1 & in2;
endmodule

// OR Gate
module or_gate(input wire in1, in2, output wire out);
    assign out = in1 | in2;
endmodule

// XOR Gate
module xor_gate(input wire in1, in2, output wire out);
    assign out = in1 ^ in2;
endmodule

// NAND Gate
module nand_gate(input wire in1, in2, output wire out);
    assign out = ~(in1 & in2);
endmodule

// NOR Gate
module nor_gate(input wire in1, in2, output wire out);
    assign out = ~(in1 | in2);
endmodule

// NOT Gate (Inverter)
module inv_gate(input wire in, output wire out);
    assign out = ~in;
endmodule

// BUFFER Gate
module buf_gate(input wire in, output wire out);
    assign out = in;
endmodule

// 2-to-1 MUX
module mux2(input wire a, b, sel, output wire y);
    assign y = sel ? b : a;
endmodule

// D Flip-Flop (DFF)
module dff(input wire clk, d, output reg q);
    always @(posedge clk or posedge rst)
        if (rst) 
            q <= 0;
        else
            q <= d;
endmodule
