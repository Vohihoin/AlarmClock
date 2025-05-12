`default_nettype none

module reg_cell( // this is the generic reg cell to make all the second, minute, hour storage registers
    output wire Lout,
    input wire Rin,
    output wire Q,
    input wire D,
    input wire inc,
    input wire load,
    input wire clk
);


    logic ff_input;
    logic inc_value;
    
    assign ff_input = (load) ? D : (inc) ? inc_value : Q;
    half_adder adder(.A(Q), .B(Rin), .S(inc_value), .Cout(Lout));

    d_ff ff(.clk(clk), .D(ff_input), .Q(Q), .CLRN(1'b1), .PRN(1'b1));

endmodule

`default_nettype wire
