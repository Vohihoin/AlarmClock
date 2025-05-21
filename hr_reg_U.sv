module hr_reg_U(
    input wire inc,
    input wire clk,
    input wire reset,
    input wire set,
    input logic[3:0] new_val,
    output wire[3:0] Q,
    output wire hit9,
    output wire hit3
);

    wire load;
    logic[3:0] reg_input;

    // if we're setting or resetting, we're loading a new value
    // but reset takes precedence over set
    assign load = reset || set || ((hit9) && inc);
    assign reg_input = ((reset) || ((hit9) && inc)) ? 4'b0000 : new_val; // if we hit 9 and we're incrementing, we want to reset our counter

    reg4bit register(.D(reg_input), .Q(Q), .inc(inc), .load(load), .clk(clk)); 

    assign hit9 = (Q == 4'b1001);
    assign hit3 = (Q == 4'b0011);

endmodule

`default_nettype wire