`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/20 19:56:11
// Design Name: 
// Module Name: TOP
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


module TOP (
    input            clk_50mhz,  //时钟信号
    input      [3:0] col,        //1列 输入
    input      [1:0] sw,         //开关信号
    output     [3:0] row,        //4 row,输出
    output     [7:0] seg,        //segment
    output     [5:0] dig,        //dig
    output reg [3:0] led
);

    reg [3:0] disp_0, disp_1;
    wire [3:0] key;

    parameter INIT = 0;
    parameter START = 1;

    key_deboucing key_deboucing (
        .clk    (clk_50mhz),
        .col    (col),
        .row    (row),
        .key    (key)
    );

    dynamic_led2 dynamic_led2 (
        .disp_data_right0 (key),
        .disp_data_right1 (key),
        .clk             (clk_50mhz),
        .seg             (seg),
        .dig             (dig)
    );
    // always @(*) begin
    //     next_state = current_state;  // 默认保持当前状态
    //     case (current_state)
    //         INIT: begin
    //             if (sw[0] == 1) begin
    //                 next_state = START;
    //             end
    //         end
    //         START: begin
    //             if (sw[0] == 0) begin
    //                 next_state = INIT;
    //             end
    //         end
    //         default: begin
    //             next_state = INIT;
    //         end
    //     endcase
    // end

    // always @(posedge clk_100) begin
    //     current_state <= next_state;  // 更新状态
    //     // 根据当前状态设置动作输出
    //     case (current_state)
    //         INIT: begin
    //             led <= 4'b0000;
    //         end
    //         START: begin
    //             led <= 4'b1111;
    //         end
    //         default: begin
    //             led <= 4'b0000;
    //         end
    //     endcase
    // end
endmodule
