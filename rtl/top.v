// Minimal WELOG1 bring-up design.
// Input clock is the confirmed 100 MHz oscillator on pin R4.
// LED should blink at about 1 Hz, indicating the design is running.
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
