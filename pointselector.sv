module pointselector(
    output wire [2:0] count_val,
    output logic [7:0] out,
    input wire inc,
    input wire resetn,
    input wire [2:0] max,
    input wire active,
    input wire clk
);

    logic load_input;
    logic [2:0] reg_input; 
    logic about_to_be_max;

    assign about_to_be_max = (count_val == max - 3'b001); 
    assign load_input = !resetn || (about_to_be_max && active);
    assign reg_input = 3'b000;

    reg3bit counter_reg(.D(reg_input), .Q(count_val), .load(load_input), .inc(inc && active), .clk(clk));

    always_comb begin
        
        case (count_val)

            3'b000: out = 8'b00000001;
            3'b001: out = 8'b00000010;
            3'b010: out = 8'b00000100;
            3'b011: out = 8'b00001000;
            3'b100: out = 8'b00010000;
            3'b101: out = 8'b00100000;
            3'b110: out = 8'b01000000;
            3'b111: out = 8'b10000000;
            default: out = 8'b00000000;

        endcase

        if (!active) begin
            out = 8'b00000000;
        end

    end

endmodule