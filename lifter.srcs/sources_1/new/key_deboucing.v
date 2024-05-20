`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/20 19:56:11
// Design Name: 
// Module Name: key_deboucing
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



module key_deboucing (
    input        clk,
    input  [1:0] col,
    output [3:0] row,
    output          btnout0  //输出
    output          btnout1,
    output          btnout2,
    output          btnout3
);

    parameter SWP0 = 1'b0;
    parameter SWP1 = 1'b1;
    wire clk_20ms;  //20ms clk

    divclk divclk (
        .clk   (clk),
        .btnclk(clk_20ms)
    );
    reg btn00, btn01, btn20;
    reg btn10, btn11, btn10;
    row[3:0] = 1110;
    always @(posedge clk_20ms) begin
        btn00 <= col[0];
        btn01 <= btn00;
        btn02 <= btn01;
    end
    always @(posedge clk_20ms) begin
        btn10 <= col[1];
        btn11 <= btn10;
        btn12 <= btn11;
    end
    assign btnout0 = ((~btn02) & (~btn01) & (~btn00)) | (btn02 & (~btn01) & (~btn00));

    always @(*) begin
        next_state = current_state;  // 默认保持当前状态
        case (current_state)
            SWP0: begin
                if (btnout0 == 1) begin
                    next_state = SWP1;
                end
            end
            SWP1: begin
                if (btnout0 == 0) begin
                    next_state = SWP0;
                end
            end
            default: begin
                next_state = SWP0;
            end
        endcase
    end

    always @(posedge clk_20ms) begin
        current_state <= next_state;  // 更新状态
        // 根据当前状态设置动作输出
        case (current_state)
            SWP0: begin
                led <= 4'b0000;
            end
            SWP1: begin
                led <= 4'b1111;
            end
            default: begin
                led <= 4'b0000;
            end
        endcase
    end

endmodule
