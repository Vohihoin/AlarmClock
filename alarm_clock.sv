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

/**
Main alarm clock module with the running clock
*/
module alarm_clock(
    input wire clk,
    input wire resetn,
    input wire set_time,
    input wire switch_select_in,
    input wire increment_in,

    output wire [3:0] secU,
    output wire [3:0] secT,
    output wire [3:0] minU,
    output wire [3:0] minT,
    output wire [3:0] hrU,
    output wire [3:0] hrT,

    // debounced signals
    output switch_select_deb, 
    output inc_deb

);

    // This is just used if we ever want to see how many clock cycles sec_counter has counted
    logic [25:0] count;

    // These are the main indicators transferred between different registers to signify
    // when a register hits its max value
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

    // Outputs from the registers showing the current time
    logic [3:0] secUclock;
    logic [3:0] secTclock;
    logic [3:0] minUclock;
    logic [3:0] minTclock;
    logic [3:0] hrUclock;
    logic [3:0] hrTclock;

    //
    logic secUset;
    logic secTset;
    logic minUset;
    logic minTset;
    logic hrUset;
    logic hrTset;

    logic [3:0] secUnewVal;
    logic [3:0] secTnewVal;
    logic [3:0] minUnewVal;
    logic [3:0] minTnewVal;
    logic [3:0] hrUnewVal;
    logic [3:0] hrTnewVal;


    // logic for debouncing input signals and a register for holding the state of the digit selector 

    logic [5:0] selections_next;
    logic [5:0] selections;

    reg6bit iREG1(.clk(clk), .resetn(resetn), .D(selections_next), .Q(selections));
    logic switch_select;
    debouncer switch_select_debouncer(.pb_1(switch_select_in), .clk(clk), .pb_out(switch_select));
    assign switch_select_deb = switch_select;

    logic increment;
    debouncer increment_debouncer(.pb_1(increment_in), .clk(clk), .pb_out(increment));
    assign inc_deb = increment;

    // external resetn used for counter to reset it after setting time
    logic counter_external_resetn;

    // We initialize and connect our registers and counter
    sec_counter counter(.clk(clk), .resetn_sync(resetn && counter_external_resetn), .inc(inc), .count(count));
    sec_reg_U secRegU(.inc(inc), .clk(clk), .resetn(resetn), .set(secUset), .new_val(secUnewVal), .Q(secUclock), .hit9(secUHit9));
    sec_reg_T secRegT(.clk(clk), .resetn(resetn), .set(secTset), .inc(inc && secUHit9), .new_val(secTnewVal), .Q(secTclock), .hit5(secTHit5));
    min_reg_U minRegU(.inc(inc && secUHit9 && secTHit5), .clk(clk), .resetn(resetn), .set(minUset), .new_val(minUnewVal), .Q(minUclock), .hit9(minUHit9));
    min_reg_T minRegT(.clk(clk), .resetn(resetn), .set(minTset), .inc(inc && minUHit9 && secTHit5 && secUHit9), .new_val(minTnewVal), .Q(minTclock), .hit5(minTHit5));
    hr_reg_U hrRegU(.inc(inc && minTHit5 && minUHit9 && secTHit5 && secUHit9), .clk(clk), .resetn(resetn && !every_thing_maxed), .set(hrUset), .new_val(hrUnewVal), .Q(hrUclock), .hit9(hrUHit9), .hit3(hrUHit3));
    hr_reg_T hrRegT(.clk(clk), .resetn(resetn && !every_thing_maxed), .set(hrTset), .inc(inc && hrUHit9 && minTHit5 && minUHit9 && secTHit5 && secUHit9), .new_val(hrTnewVal), .Q(hrTclock), .hit2(hrTHit2));


    // Assign our outward facing outputs to the clock values
    assign secU = secUclock;
    assign secT = secTclock;
    assign minU = minUclock;
    assign minT = minTclock;
    assign hrU = hrUclock;
    assign hrT = hrTclock;

    // Set time state machine
    typedef enum reg {WAIT=1'b0, MAIN=1'b1} set_time_state_t;

    set_time_state_t set_time_nxt_state;
    reg set_time_state;
    reg1bit setTimeReg(.clk(clk), .resetn(resetn), .D(set_time_nxt_state), .Q(set_time_state));

    always_comb begin

        secUset = 1'b0;
        secTset = 1'b0;
        minUset = 1'b0;
        minTset = 1'b0;
        hrUset = 1'b0;
        hrTset = 1'b0;

        // naturally, we aren't resetting the counter..
        counter_external_resetn = 1'b1;

        // default new value for the digit registers should be the current value stored within them
        secUnewVal = secUclock;
        secTnewVal = secTclock;
        minUnewVal = minUclock;
        minTnewVal = minTclock;
        hrUnewVal = hrUclock;
        hrTnewVal = hrTclock;

        set_time_nxt_state = set_time_state_t'(set_time_state);
        selections_next = selections;
        
        case (set_time_state)

            WAIT: begin

                if (set_time) begin

                    set_time_nxt_state = MAIN;
                    selections_next = 6'b000001;

                end

            end

            MAIN: begin

                secUset = 1'b1;
                secTset = 1'b1;
                minUset = 1'b1;
                minTset = 1'b1;
                hrUset = 1'b1;
                hrTset = 1'b1;  

                if (switch_select) begin
                    // we left rotate selections once
                    selections_next = {selections[4:0], selections[5]};
                end

                if (increment) begin
                    case (selections) 
                        
                        6'b000001 : begin // sec U is selected
                            secUnewVal = secUclock + 1'b1;
                        end
                        6'b000010 : begin // sec T is selected
                            secTnewVal = secTclock + 1'b1;
                        end
                        6'b000100 : begin // min U is selected
                            minUnewVal = minUclock + 1'b1;
                        end
                        6'b001000 : begin // min T is selected
                            minTnewVal = minTclock + 1'b1;
                        end
                        6'b010000 : begin // hr U is selected
                            hrUnewVal = hrUclock + 1'b1;
                        end
                        6'b100000 : begin // hr T is selected
                            hrTnewVal = hrTclock + 1'b1;
                        end

                    endcase

                    if (secUnewVal > 4'b1001) begin
                        secUnewVal = 4'b0000;
                    end

                    if (secTnewVal > 4'b0101) begin
                        secTnewVal = 4'b0000;
                    end

                    if (minUnewVal > 4'b1001) begin
                        minUnewVal = 4'b0000;
                    end

                    if (minTnewVal > 4'b0101) begin
                        minTnewVal = 4'b0000;
                    end

                    if (hrTnewVal > 4'b0010) begin
                        hrTnewVal = 4'b0000;
                    end

                    if (hrTnewVal > 4'b0001) begin
                        if (hrUnewVal > 4'b0011) begin
                            hrUnewVal = 4'b0000;
                        end
                    end else begin
                        if (hrUnewVal > 4'b1001) begin
                            hrUnewVal = 4'b0000;
                        end
                    end

                end

                if (!set_time) begin
                    set_time_nxt_state = WAIT;
                    // ... but if we're going back to the waiting for set_time state, we start the second counter again
                    counter_external_resetn = 1'b0;
                end

            end
        
        endcase

    end

// This block will eventually be used to make the selected register / display blink
/*     always_comb begin

    end
 */


endmodule


/**
* Module for setting the alarm time and all that
*/
module alarm_control(
    input clk,
    input rst_n,
    input switch_select,
    input inc_value,
    input set_alarm,
    input set_time,

    input [3:0] minU_in,
    input [3:0] minT_in,
    input [3:0] hrU_in,
    input [3:0] hrT_in,
    input rst_alarm_ring,

    output logic alarm_ring,
    output logic [3:0] alarm_minU,
    output logic [3:0] alarm_minT,
    output logic [3:0] alarm_hrU,
    output logic [3:0] alarm_hrT

);

    // Logic for being in alarm mode
    logic in_alarm_mode; // flopped in_alarm_mode signal
    logic load_in; // signal that tells the registers to load in a new value once we enter the alarm_mode state

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            in_alarm_mode <= '0;
        else
            in_alarm_mode <= set_alarm && !set_time;
    end

    // sub-logic so that we can load in only when we enter alarm mode
    logic in_alarm_mode_prev;
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            in_alarm_mode_prev <= '0;
        else
            in_alarm_mode_prev <= in_alarm_mode;
    end

    // we load in when we go from not being in alarm mode to being in alarm mode
    assign load_in = in_alarm_mode && !in_alarm_mode_prev; 



    // Logic for controlling the selected digit place
    logic [3:0] selected_place; // signal used to indicate which digit place is selected

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            selected_place <= 4'b0001;
        else if (switch_select && in_alarm_mode)
            selected_place <= {selected_place[2:0], selected_place[3]}; // rotate the place that we have selected
    end

    // Logic + Registers for storing the alarm values and incrementing them

    localparam MIN_U_MASK = 6'b0001;
    localparam MIN_T_MASK = 6'b0010;
    localparam HR_U_MASK = 6'b0100;
    localparam HR_T_MASK = 6'b1000;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            alarm_minU <= '0;
            alarm_minT <= '0;
            alarm_hrU <= '0;
            alarm_hrT <= '0;
        end else if (load_in) begin
            alarm_minU <= minU_in;
            alarm_minT <= minT_in;
            alarm_hrU <= hrU_in;
            alarm_hrT <= hrT_in;
        end else if (inc_value && in_alarm_mode) begin
            // we only want to increment the register that selected_place corresponds to
            alarm_minU <= alarm_minU + |(selected_place & MIN_U_MASK);
            alarm_minT <= alarm_minT + |(selected_place & MIN_T_MASK);
            alarm_hrU <= alarm_hrU + |(selected_place & HR_U_MASK);
            alarm_hrT <= alarm_hrT + |(selected_place & HR_T_MASK);
        end
    end

    // logic for the alarm ringing
    logic set_alarm_ring;
    logic time_achieved;
    logic time_achieved_prev;
    assign time_achieved = !in_alarm_mode && 
                 (minU == minU_in) &&
                 (minT == minT_in) &&
                 (hrU == hrU_in) &&
                 (hrT == hrT_in);

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            alarm_ring <= '0;
        else if (rst_alarm_ring)
            alarm_ring <= '0;
        else if (set_alarm_ring)
            alarm_ring <= '1;
    end


endmodule