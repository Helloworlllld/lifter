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

    reg [3:0] row_out = 4'b0000;
    reg [2:0] current_state, next_state;
    reg [3:0] key_out;
    reg [1:0] row_temp,col_temp;
    reg [1:0] switch_flag = 0;
    wire clk_20ms;
    wire col_total;

    parameter INIT = 3'b000;
    parameter SCAN_COL = 3'b001;
    parameter SCAN_ROW_0 = 3'b010;
    parameter SCAN_ROW_1 = 3'b011;
    parameter SCAN_ROW_2 = 3'b100;
    parameter SCAN_ROW_3 = 3'b101;
    parameter WAIT_RLF = 3'b110;

    divclk divclk (
        .clk   (clk),
        .btnclk(clk_20ms)
    );

    assign col_total = col[0] | col[1] | col[2] | col[3];
    assign key = key_out;
    assign row[3:0] = row_out;

    always @(*) begin
        next_state = current_state;
        case (current_state)
            INIT: begin
                key_out = 4'b0000;
                row_out = 4'b0000;
                if(switch_flag == 1) begin
                    next_state = SCAN_COL;
                end
            end
            SCAN_COL: begin
                row_out = 4'b0000;
                if(switch_flag == 0) begin
                    next_state = SCAN_ROW_0;
                end
                else if (switch_flag == 2) begin
                    next_state = INIT;
                end
            end
            SCAN_ROW_0: begin
                row_out = 4'b1110;
                if(switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                else if(row_temp == 2'b01) begin
                    next_state = SCAN_ROW_1;
                end
            end
            SCAN_ROW_1: begin
                row_out = 4'b1101;
                if(switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                else if(row_temp == 2'b10) begin
                    next_state = SCAN_ROW_2;
                end
            end
            SCAN_ROW_2: begin
                row_out = 4'b1011;
                if(switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                else if(row_temp == 2'b11) begin
                    next_state = SCAN_ROW_3;
                end
            end
            SCAN_ROW_3: begin
                row_out = 4'b0111;
                if(switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                else if(row_temp == 2'b00) begin
                    next_state = INIT;
                end
            end
            WAIT_RLF: begin
                if(switch_flag == 3) begin
                    next_state = INIT;
                end
            end
            default: begin
                next_state = INIT;
            end
        endcase
    end

    always @(posedge clk_20ms) begin
        current_state <= next_state;
        case (current_state)
            INIT: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end
            end
            SCAN_COL: begin
                if (col[0] == 0) begin
                    col_temp <= 2'b00;
                    switch_flag <= 0;
                end
                else if (col[1] == 0) begin
                    col_temp <= 2'b01;
                    switch_flag <= 0;
                end
                else if (col[2] == 0) begin
                    col_temp <= 2'b10;
                    switch_flag <= 0;
                end
                else if (col[3] == 0) begin
                    col_temp <= 2'b11;
                    switch_flag <= 0;
                end
                else begin
                    switch_flag <= 2;
                end
            end
            SCAN_ROW_0: begin
                if (~col_total) begin
                    row_temp <= 2'b00;
                    switch_flag <= 1;
                end
                else begin
                    row_temp <= 2'b01;
                end
            end
            SCAN_ROW_1: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end
                else begin
                    row_temp <= 2'b10;
                end
            end
            SCAN_ROW_2: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end
                else begin
                    row_temp <= 2'b11;
                end
            end
            SCAN_ROW_3: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end
                else begin
                    row_temp <= 2'b00;
                end
            end
            WAIT_RLF: begin
                if (~col_total) begin
                    key_out[1:0]<=col_temp;
                    key_out[3:2]<=row_temp;
                end
                else begin
                    switch_flag <= 3;
                end
            end
            default: begin

            end
        endcase
    end

endmodule
