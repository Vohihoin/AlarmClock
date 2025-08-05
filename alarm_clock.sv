module alarm_clock(
    input wire clk,
    input wire resetn,

    output wire [3:0] secU,
    output wire [3:0] secT,
    output wire [3:0] minU,
    output wire [3:0] minT,
    output wire [3:0] hrU,
    output wire [3:0] hrT,

    output wire [6:0] secUSeg,
    output wire [6:0] secTSeg,
    output wire [6:0] minUSeg,
    output wire [6:0] minTSeg,
    output wire [6:0] hrUSeg,
    output wire [6:0] hrTSeg,

    input wire sel_inc_wire,
    input wire sel_next_wire,

    input wire alarm_mode,
    output wire alarm_ring

);

    logic [25:0] count;
    logic secUHit9;
    logic secTHit5;
    logic minUHit9;
    logic minTHit5;
    logic hrUHit9;
    logic hrUHit3;
    logic hrTHit2;
    logic inc;

    
    logic every_thing_maxed;
    assign every_thing_maxed = inc && hrTHit2 && hrUHit3 && minTHit5 && minUHit9 && secTHit5 && secUHit9;

    // These components hold and manage the current time

    logic [3:0] secUclock;
    logic [3:0] secTclock;
    logic [3:0] minUclock;
    logic [3:0] minTclock;
    logic [3:0] hrUclock;
    logic [3:0] hrTclock;


    sec_counter counter(.clk(clk), .resetn_sync(resetn), .inc(inc), .count(count));
    sec_reg_T secRegT(.clk(clk), .resetn(resetn), .set(1'b0), .inc(inc && secUHit9), .new_val(4'b0000), .Q(secTclock), .hit5(secTHit5));
    sec_reg_U secRegU(.inc(inc), .clk(clk), .resetn(resetn), .set(1'b0), .new_val(4'b0000), .Q(secUclock), .hit9(secUHit9));
    min_reg_U minRegU(.inc(inc && secUHit9 && secTHit5), .clk(clk), .resetn(resetn), .set(1'b0), .new_val(4'b0000), .Q(minUclock), .hit9(minUHit9));
    min_reg_T minRegT(.clk(clk), .resetn(resetn), .set(1'b0), .inc(inc && minUHit9 && secTHit5 && secUHit9), .new_val(4'b0000), .Q(minTclock), .hit5(minTHit5));
    hr_reg_U hrRegU(.inc(inc && minTHit5 && minUHit9 && secTHit5 && secUHit9), .clk(clk), .resetn(resetn || every_thing_maxed), .set(1'b0), .new_val(4'b0000), .Q(hrUclock), .hit9(hrUHit9), .hit3(hrUHit3));
    hr_reg_T hrRegT(.clk(clk), .resetn(resetn || every_thing_maxed), .set(1'b0), .inc(inc && hrUHit9 && minTHit5 && minUHit9 && secTHit5 && secUHit9), .new_val(4'b0000), .Q(hrTclock), .hit2(hrTHit2));

    // Button press management

    logic sel_inc;
    logic sel_next;

    logic inc_sustained;
    logic next_sustained;

    press_detector inc_press_detect(.signal(sel_inc_wire), .NC(1'b0), .clk(clk), .resetn(resetn), .press_seen(sel_inc), .sustained(inc_sustained), .sustained_resetn(resetn));
    press_detector next_press_detect(.signal(sel_next_wire), .NC(1'b0), .clk(clk), .resetn(resetn), .press_seen(sel_next), .sustained(next_sustained), .sustained_resetn(resetn));
    

    // Alarm Logic

    logic alm_minU_active;
    logic alm_minT_active;
    logic alm_hrU_active;
    logic alm_hrT_active;

    logic [3:0] alm_minU_out;
    logic [3:0] alm_minT_out;
    logic [3:0] alm_hrU_out;
    logic [3:0] alm_hrT_out;

    logic [2:0] alarm_sel_count_val;
    logic [3:0] rest_of_alarm_sel_out;
    

    pointselector alarm_sel_4point(.inc(sel_next), .count_val(alarm_sel_count_val), .out({rest_of_alarm_sel_out, alm_hrT_active, alm_hrU_active, alm_minT_active, alm_minU_active}), .resetn(resetn), .max(3'b100), .active(alarm_mode), .clk(clk));

    alarm_reg alm_minU(.Q(alm_minU_out), .inc(sel_inc), .resetn(resetn), .active(alm_minU_active), .clk(clk));
    alarm_reg alm_minT(.Q(alm_minT_out), .inc(sel_inc), .resetn(resetn), .active(alm_minT_active), .clk(clk));
    alarm_reg alm_secU(.Q(alm_hrU_out), .inc(sel_inc), .resetn(resetn), .active(alm_hrU_active), .clk(clk));
    alarm_reg alm_secT(.Q(alm_hrT_out), .inc(sel_inc), .resetn(resetn), .active(alm_hrT_active), .clk(clk));

    assign alarm_ring = (alm_minU_out == minUclock) &&
                 (alm_minT_out == minTclock) &&
                 (alm_hrU_out == hrUclock) &&
                 (alm_hrT_out == hrTclock);

    // output signal management

    logic dashed_seg = 4'b1111; // with hex code 1111, our screen ends up getting dashed out.

    always_comb begin

        case (alarm_mode)

            1'b0: begin
                secU = secUclock;
                secT = secTclock;
                minU = minUclock;
                minT = minTclock;
                hrU = hrUclock;
                hrT = hrTclock;
            end 
            1'b1: begin
                secU = dashed_seg;
                secT = dashed_seg;
                minU = alm_minU_out;
                minT = alm_minT_out;
                hrU = alm_hrU_out;
                hrT = alm_hrT_out;
            end

        endcase


    end


    // These convert the register values to 7 segment display inputs
    bcd7seg secUDec(.num(secU), .seg(secUSeg));
    bcd7seg secTDec(.num(secT), .seg(secTSeg));
    bcd7seg minUDec(.num(minU), .seg(minUSeg));
    bcd7seg minTDec(.num(minT), .seg(minTSeg));
    bcd7seg hrUDec(.num(hrU), .seg(hrUSeg));
    bcd7seg hrTDec(.num(hrT), .seg(hrTSeg));



endmodule