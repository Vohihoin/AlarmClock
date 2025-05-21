module alarm_clock(
    input wire clk,
    input wire reset,
    output wire [3:0] secU,
    output wire [3:0] secT,
    output wire [3:0] minU,
    output wire [3:0] minT,
    output wire [3:0] hrU,
    output wire [3:0] hrT
);

    logic inc;
    logic [25:0] count;
    logic secUHit9;
    logic secTHit5;
    logic minUHit9;
    logic minTHit5;
    logic hrUHit9;
    logic hrUHit3;
    logic hrTHit2;

    logic every_thing_maxed;
    assign every_thing_maxed = inc && hrTHit2 && hrUHit3 && minTHit5 && minUHit9 && secTHit5 && secUHit9;

    sec_counter counter(.clk(clk), .reset_sync(reset), .inc(inc), .count(count));
    sec_reg_T secRegT(.clk(clk), .reset(reset), .set(1'b0), .inc(inc && secUHit9), .new_val(4'b0000), .Q(secT), .hit5(secTHit5));
    sec_reg_U secRegU(.inc(inc), .clk(clk), .reset(reset), .set(1'b0), .new_val(4'b0000), .Q(secU), .hit9(secUHit9));
    min_reg_U minRegU(.inc(inc && secUHit9 && secTHit5), .clk(clk), .reset(reset), .set(1'b0), .new_val(4'b0000), .Q(minU), .hit9(minUHit9));
    min_reg_T minRegT(.clk(clk), .reset(reset), .set(1'b0), .inc(inc && minUHit9 && secTHit5 && secUHit9), .new_val(4'b0000), .Q(minT), .hit5(minTHit5));
    hr_reg_U hrRegU(.inc(inc && minTHit5 && minUHit9 && secTHit5 && secUHit9), .clk(clk), .reset(reset || every_thing_maxed), .set(1'b0), .new_val(4'b0000), .Q(hrU), .hit9(hrUHit9), .hit3(hrUHit3));
    hr_reg_T hrRegT(.clk(clk), .reset(reset || every_thing_maxed), .set(1'b0), .inc(inc && hrUHit9 && minTHit5 && minUHit9 && secTHit5 && secUHit9), .new_val(4'b0000), .Q(hrT), .hit2(hrTHit2));

endmodule