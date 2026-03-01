/* Top level alarm clock module
*/
module alarm_clock_top_level(
    input wire clk,
    input wire rst_n,
    input wire set_time,
    input wire set_alarm,
    input wire switch_select,
    input wire increment_in,

    output logic [3:0] secU,
    output logic [3:0] secT,
    output logic [3:0] minU,
    output logic [3:0] minT,
    output logic [3:0] hrU,
    output logic [3:0] hrT,

    output [6:0] secUSeg,
    output [6:0] secTSeg,
    output [6:0] minUSeg,
    output [6:0] minTSeg,
    output [6:0] hrUSeg,
    output [6:0] hrTSeg,

    output logic alarm_ring,
    output logic buzzer_pwm
);
    
    // MAIN CLOCK DEVICE
    logic [3:0] secUclock;
    logic [3:0] secTclock;
    logic [3:0] minUclock;
    logic [3:0] minTclock;
    logic [3:0] hrUclock;
    logic [3:0] hrTclock;

    logic switch_select_deb;
    logic inc_deb;

    alarm_clock mainClock(
        .clk(clk), 
        .resetn(rst_n), 
        .set_time(set_time), 
        .switch_select_in(switch_select),
        .increment_in(increment_in),
        .secU(secUclock),
        .secT(secTclock),
        .minU(minUclock),
        .minT(minTclock),
        .hrU(hrUclock),
        .hrT(hrTclock),

        .switch_select_deb(switch_select_deb),
        .inc_deb(inc_deb)
    ); 

    // MAIN ALARM DEVICE
    logic [3:0] alarm_minU;
    logic [3:0] alarm_minT;
    logic [3:0] alarm_hrU;
    logic [3:0] alarm_hrT;

    alarm_control alarmDevice(
        .clk(clk),
        .rst_n(rst_n),
        .switch_select(switch_select_deb),
        .inc_value(inc_deb),
        .set_alarm(set_alarm),
        .set_time(set_time),
        .minU_in(minUclock),
        .minT_in(minTclock),
        .hrU_in(hrUclock),
        .hrT_in(hrTclock),
        .alarm_ring(alarm_ring),
        .alarm_minU(alarm_minU),
        .alarm_minT(alarm_minT),
        .alarm_hrU(alarm_hrU),
        .alarm_hrT(alarm_hrT)
    );

    // 7 Segment Decoders with Enable - enable is used to enable (get it) ;) blinking
    logic secU_en;
    logic secT_en;
    logic minU_en;
    logic minT_en;
    logic hrU_en;
    logic hrT_en;

    bcd7seg_en secUDec(.en(secU_en), .num(secU), .seg(secUSeg));
    bcd7seg_en secTDec(.en(secT_en), .num(secT), .seg(secTSeg));
    bcd7seg_en minUDec(.en(minU_en), .num(minU), .seg(minUSeg));
    bcd7seg_en minTDec(.en(minT_en), .num(minT), .seg(minTSeg));
    bcd7seg_en hrUDec(.en(hrU_en), .num(hrU), .seg(hrUSeg));
    bcd7seg_en hrTDec(.en(hrT_en), .num(hrT), .seg(hrTSeg));

    // Digits Blinking Logic
    localparam MAX_COUNT = 26'd50_000_000;
    localparam HALF_COUNT = 26'd25_000_000;

    logic [24:0] cnt;
    logic pwm_val;
    always_ff @(posedge clk) begin
        if (!rst_n)
            cnt <= '0;
        else if (cnt == MAX_COUNT-1)
            cnt <= '0;
        else
            cnt <= cnt + 1;
    end

    assign pwm_val = (cnt < HALF_COUNT);

    // Logic for controlling:
    //      - displaying clock or alarm values
    //      - to control the blinking while setting clock or alarm values
    always_comb begin

        // Normally, we're just displaying the clock values
        secU = secUclock;
        secT = secTclock;
        minU = minUclock;
        minT = minTclock;
        hrU = hrUclock;
        hrT = hrTclock;

        secU_en = 1'b1;
        secT_en = 1'b1;
        minU_en = 1'b1;
        minT_en = 1'b1;
        hrU_en = 1'b1;
        hrT_en = 1'b1;

        if (set_time) begin // In set_time mode, we're still displaying clock values but we're blinking them using a 
                            // timer controlled "PWM" signal
            secU_en = pwm_val;
            secT_en = pwm_val;
            minU_en = pwm_val;
            minT_en = pwm_val;
            hrU_en = pwm_val;
            hrT_en = pwm_val;
        end else if (set_alarm) begin // in set_alarm mode, we're displaying the alarm register values and blinking them
                                      // but since we aren't setting the seconds place, we disable those places
            secU_en = 1'b0;
            secT_en = 1'b0;
            minU = alarm_minU;
            minT = alarm_minT;
            hrU = alarm_hrU;
            hrT = alarm_hrT;
        end

    end

    // Want to operate buzzer at 1.5kHz i.e period of 33,333 clock cycles (50MHz/1.5kHz), 50% duty cycle
    // 33,333 ~ 32768 = 2^15. So, let's just do a 15 bit timer to count to 32768 ~ 33,333 

    localparam HALF_BUZZER_COUNT = 16384;

    logic [14:0] buzzer_cnt;
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            buzzer_cnt <= '0;
        else if (alarm_ring)
            buzzer_cnt <= buzzer_cnt + 1; // because we used a power of 2, counter automatically resets 
    end
    assign buzzer_pwm = alarm_ring && (buzzer_cnt < HALF_BUZZER_COUNT);

endmodule