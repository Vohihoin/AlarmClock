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

    output [6:0] secUSeg,
    output [6:0] secTSeg,
    output [6:0] minUSeg,
    output [6:0] minTSeg,
    output [6:0] hrUSeg,
    output [6:0] hrTSeg

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

    logic increment;
    debouncer increment_debouncer(.pb_1(increment_in), .clk(clk), .pb_out(increment));

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

    // These convert the register values to 7 segment display inputs
    bcd7seg secUDec(.num(secUclock), .seg(secUSeg));
    bcd7seg secTDec(.num(secTclock), .seg(secTSeg));
    bcd7seg minUDec(.num(minUclock), .seg(minUSeg));
    bcd7seg minTDec(.num(minTclock), .seg(minTSeg));
    bcd7seg hrUDec(.num(hrUclock), .seg(hrUSeg));
    bcd7seg hrTDec(.num(hrTclock), .seg(hrTSeg));

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