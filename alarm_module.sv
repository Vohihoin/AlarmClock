/**
* Module that stores the set alarm values and actually implements the logic for ringing the alarm
*/
module alarm_module(
    input resetn,
    input clk,
    input logic [3:0] minU,
    input logic [3:0] minT,
    input logic [3:0] hrU,
    input logic [3:0] hrT,
    input logic switch_select,
    input logic increment,
    input logic stop_alarm,
    input logic set_time_mode,
    input logic set_alarm_mode,

    output logic [3:0] minUAlarm,
    output logic [3:0] minTAlarm,
    output logic [3:0] hrUAlarm,
    output logic [3:0] hrTAlarm,

    output logic alarm_ring
);

    logic [3:0] minUAlarmIn;
    logic minUinc;
    logic minULoad;
    reg4bit minUAlarm(.D(minUAlarmIn), .Q(minUAlarm), .inc(minUinc), .load(minULoad), .clk(clk)); 

    logic [3:0] minTAlarmIn;
    logic minTinc;
    logic minTLoad;
    reg4bit minTlarm(.D(minTAlarmIn), .Q(minTAlarm), .inc(minTinc), .load(minTLoad), .clk(clk)); 

    logic [3:0] hrUAlarmIn;
    logic hrUinc;
    logic hrULoad;
    reg4bit hrUAlarm(.D(hrUAlarmIn), .Q(hrUAlarm), .inc(hrUinc), .load(hrULoad), .clk(clk)); 

    logic [3:0] hrTAlarmIn;
    logic hrTinc;
    logic hrTLoad;
    reg4bit hrTlarm(.D(hrTAlarmIn), .Q(hrTAlarm), .inc(hrTinc), .load(hrTLoad), .clk(clk));


    logic set_alarm_mode_flopped; // we use this flopped signal to help us detect when we first enter alarm mode

    always_ff @(posedge clk) begin
        if (resetn) begin
            set_alarm_mode_flopped <= 1'b0;
        end else begin
            set_alarm_mode_flopped <= set_alarm_mode;
        end
    end


    // Logic for loading
    
    always_comb begin

        if (!resetn) begin // we're resetting

            minULoad = 1'b1;
            minTLoad = 1'b1;
            hrULoad = 1'b1;
            hrTLoad = 1'b1;

            minUAlarmIn = 3'b0000;
            minTAlarmIn = 3'b0000;
            hrUAlarmIn = 3'b0000;
            hrTAlarmIn = 3'b0000;

        end else if (set_alarm_mode && !set_alarm_mode_flopped) begin // this is to detect when we first enter alarm mode (i.e rising edge)
            
            // when this happens, we set our alarm values to the current time

            minULoad = 1'b1;
            minTLoad = 1'b1;
            hrULoad = 1'b1;
            hrTLoad = 1'b1;

            minUAlarmIn = minU;
            minTAlarmIn = minT;
            hrUAlarmIn = hrU;
            hrTAlarmIn = hrT;

        end else begin // if neither of these cases, we don't load 
            minULoad = 1'b0;
            minTLoad = 1'b0;
            hrULoad = 1'b0;
            hrTLoad = 1'b0;

            // we don't really care what the in values are 

        end


    end


endmodule