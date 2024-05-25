`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/25 15:50:20
// Design Name: 
// Module Name: div_1ms
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divclk (
    clk,
    btnclk
);
    input clk;
    output btnclk;
    reg [31:0] btnclk_cnt = 0;  //对50M时钟1M分频的计数器 
    reg        btnclk = 0;  //50Hz信号，周期20ms

    always@(posedge clk) //20ms 50M/50=1000000 50Hz
     begin
        if (btnclk_cnt == 29999) begin
            btnclk = ~btnclk;
            btnclk_cnt = 0;
        end else begin
            btnclk_cnt = btnclk_cnt + 1'b1;
        end
    end

endmodule