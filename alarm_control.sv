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
    output logic [3:0] alarm_hrT,
    output logic [3:0] alarm_selected_place

);

    // Logic for being in alarm mode
    logic in_alarm_mode; // flopped in_alarm_mode signal
    
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

    // Logic for controlling the selected digit place
    logic [3:0] selected_place; // signal used to indicate which digit place is selected
    assign alarm_selected_place = selected_place;

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
        end else if (inc_value && in_alarm_mode) begin
            // we only want to increment the register that selected_place corresponds to
            alarm_minU <= ((alarm_minU + |(selected_place & MIN_U_MASK)) > 4'b1001) ? 4'b0000 : (alarm_minU + |(selected_place & MIN_U_MASK));
            alarm_minT <= ((alarm_minT + |(selected_place & MIN_T_MASK)) > 4'b0101) ? 4'b0000 : (alarm_minT + |(selected_place & MIN_T_MASK));
            alarm_hrU <= (alarm_hrT <= 4'b0001) ? ( ((alarm_hrU + |(selected_place & HR_U_MASK)) > 4'b1001) ? 4'b0000 : (alarm_hrU + |(selected_place & HR_U_MASK)) )
                         : ( ( (alarm_hrU + |(selected_place & HR_U_MASK)) <= 3 ) ? (alarm_hrU + |(selected_place & HR_U_MASK)) : 4'b0000);
            alarm_hrT <= ((alarm_hrT + |(selected_place & HR_T_MASK)) > 4'b0010) ? 4'b0000 : (alarm_hrT + |(selected_place & HR_T_MASK));
        end
    end

    // logic for the alarm ringing
    logic set_alarm_ring;
    logic time_achieved;
    logic time_achieved_prev;
    assign time_achieved = !in_alarm_mode && 
                 (alarm_minU == minU_in) &&
                 (alarm_minT == minT_in) &&
                 (alarm_hrU == hrU_in) &&
                 (alarm_hrT == hrT_in);

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            time_achieved_prev <= '0;
        else
            time_achieved_prev <= time_achieved;
    end

    assign set_alarm_ring = time_achieved && !time_achieved_prev;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            alarm_ring <= '0;
        else if (in_alarm_mode) // Case 1: We are in alarm mode, so we don't want to ring the alarm
            alarm_ring <= '0;
        else if (rst_alarm_ring) // Case 2: We are not in alarm mode, but the user has reset the alarm ring signal
            alarm_ring <= '0;
        else if (set_alarm_ring) // Case 3: We are not in alarm mode, and the time has been achieved, so we want to ring the alarm
            alarm_ring <= '1;
    end


endmodule