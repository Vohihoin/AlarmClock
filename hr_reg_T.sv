module hr_reg_T(
    input wire clk,
    input wire reset,
    input wire set,
    input wire inc,
    input wire [3:0] new_val,
    output wire [3:0] Q,
    output wire hit2
);

    logic [3:0] reg_input;
    logic load_signal;

    assign reg_input = (reset || (hit2 && inc)) ? 4'b0000 : new_val; 
    assign load_signal = reset || set || (hit2 && inc);
    reg4bit register(.Q(Q), .D(reg_input), .inc(inc), .load(load_signal), .clk(clk));

    assign hit2 = (Q == 4'b0010);

endmodule