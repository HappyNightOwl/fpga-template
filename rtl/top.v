// Minimal AX7035B bring-up design.
// Input clock is the 50 MHz oscillator on pin Y18.
// LED should blink at about 1.5 Hz, indicating the design is running.
module top (
    input  wire clk,
    output reg  led
);

    reg [25:0] counter = 26'd0;

    always @(posedge clk) begin
        counter <= counter + 26'd1;
        led <= counter[25];
    end

endmodule
