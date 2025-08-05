//`default_nettype none


module sec_reg_T(
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

    assign reg_input = (!resetn || (hit5 && inc)) ? 4'b0000 : new_val; 
    assign load_signal = !resetn || set || (hit5 && inc);
    reg4bit register(.Q(Q), .D(reg_input), .inc(inc), .load(load_signal), .clk(clk));

    assign hit5 = (Q == 4'b0101);

endmodule