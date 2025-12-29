
/* This is a two state FSM used to capture a button press*/
module press_detector(
    input logic signal, // note that the input signal should be double flopped
    output logic press_seen, 
    input logic NC, // should be 1 if pushbottin is normally closed.
    input wire clk,
    input wire resetn,
    output logic sustained,
    input logic sustained_resetn
);

    typedef enum reg { PRESS = 1'b0, RELEASE = 1'b1  } state_t;
    state_t state_curr;
    state_t state_nxt;
    logic signal_t;

    reg1bit state_reg(.D(state_nxt), .Q(state_curr), .clk(clk), .resetn(resetn));

    always_comb begin

        press_seen = 1'b0;
        signal_t = signal;
        state_nxt = state_curr;


        if (NC) begin // this helps account for the fact that if we're NC, then our signal is normally 1 and then 
                 // when pressed, we go 0, and then back to 1.
            signal_t = !signal;
        end

        case (state_curr)

            PRESS: begin // in this state, we're waiting for a press
                if (signal_t) begin
                    state_nxt = RELEASE;
                end
            end

            RELEASE: begin
                if (!signal_t) begin
                    state_nxt = PRESS;
                    press_seen = 1'b1;
                end
            end

        endcase

    end

    always_latch begin
        if (!sustained_resetn || press_seen) begin
            if (!sustained_resetn) begin
                sustained <= 0;
            end
            if (press_seen) begin
                sustained <= 1;
            end
        end
    end
    

endmodule


/**
    State diagram
     -------                     ---------
    |       |   signal_t = 0    |         |
    | PRESS | <---------------- | RELEASE |
    |       | ----------------> |         |
     -------    signal_t = 1     ---------
      |   |                        |   |
       <--                          -->
    signal_t = 0                 signal_t = 1
*/
