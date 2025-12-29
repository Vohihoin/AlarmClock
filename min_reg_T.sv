module min_reg_T(
    input wire clk,
    input wire resetn,
    input wire set,
    input wire inc,
    input wire [3:0] new_val,
    output wire [3:0] Q,
    output wire hit5
);

    logic [3:0] reg_input;
    logic load_signal;

    // if we hit 9 and we're incrementing, we want to reset our counter
    assign load_signal = !resetn || set || (hit5 && inc);
    assign reg_input = (!resetn) ? 4'b0000 : (set) ? new_val : 4'b0000; 
    reg4bit register(.Q(Q), .D(reg_input), .inc(inc), .load(load_signal), .clk(clk));

    assign hit5 = (Q == 4'b0101);

endmodule