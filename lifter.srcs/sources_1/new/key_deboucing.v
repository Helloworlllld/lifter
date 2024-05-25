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
    input  [3:0] col,
    output [3:0] row,
    output [3:0] key
);
    reg[1:0] scan_cnt;  
    reg [3:0] row_out;
    reg [2:0] btn0,btn1,btn2,btn3;
    reg [1:0] current_state, next_state;
    reg [3:0] key_out;
    wire clk_20ms;

    parameter SWP0 = 2'b00;
    parameter SWP1 = 2'b01;
    parameter SWP2 = 2'b10;
    parameter SWP3 = 2'b11;

    divclk divclk (
        .clk   (clk),
        .btnclk(clk_20ms)
    );

    always @(posedge clk_20ms) begin
        btn0[0] <= col[0];
        btn0[1] <= btn0[0];
        btn0[2] <= btn0[1];
    end

    assign key = key_out;
    assign row[3:0] = row_out;
    assign btnout0 = ((~btn02) & (~btn01) & (~btn00)) | (btn02 & (~btn01) & (~btn00));

    always @(*) begin
        next_state = current_state;
        case (current_state)
            SWP0: begin
                if (col[0] == 0) begin
                    row_out = 4'b1110;
                    scan_cnt = 0;
                    next_state = SWP1;
                end
            end
            SWP1: begin
                if (scan_cnt == 3) begin
                    row_out = 4'b1101;
                    scan_cnt = 0;
                    next_state = SWP2;
                end
            end
            SWP2: begin
                if (scan_cnt == 3) begin
                    row_out = 4'b1011;
                    scan_cnt = 0;
                    next_state = SWP3;
                end
            end
            SWP3: begin
                if (scan_cnt == 3) begin
                    row_out = 4'b0111;
                    scan_cnt = 0;
                    next_state = SWP0;
                end
            end
            default: begin
                next_state = SWP0;
            end
        endcase
    end

    always @(posedge clk_20ms) begin
        current_state <= next_state;
        case (current_state)
            SWP0: begin

            end
            SWP1: begin

            end
            default: begin

            end
        endcase
    end

endmodule
