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
    input            clk,
    input      [3:0] col,
    output reg [3:0] row,
    output reg [3:0] key,
    output reg       press
);

    reg [2:0] current_state, next_state;
    reg [1:0] row_temp, col_temp;
    reg  [1:0] switch_flag = 0;
    wire       col_total;

    parameter INIT = 3'b000;
    parameter SCAN_COL = 3'b001;
    parameter SCAN_ROW_0 = 3'b010;
    parameter SCAN_ROW_1 = 3'b011;
    parameter SCAN_ROW_2 = 3'b100;
    parameter SCAN_ROW_3 = 3'b101;
    parameter WAIT_RLF = 3'b110;


    //reg [31:0] divcnt = 499999;
    reg [31:0] btnclk_cnt = 0;  //对50M时钟1M分频的计数器 
    reg        btnclk = 0;  //50Hz信号，周期20ms
    always@(posedge clk) //20ms 50M/50=1000000 50Hz
    begin
        if (btnclk_cnt == 249999) begin
            btnclk <= ~btnclk;
            btnclk_cnt <= 0;
        end else begin
            btnclk_cnt <= btnclk_cnt + 1'b1;
        end
    end

    assign col_total = col[0] & col[1] & col[2] & col[3];

    always @(*) begin
        next_state = current_state;
        case (current_state)
            INIT: begin
                row = 4'b0000;
                if (switch_flag == 1) begin
                    next_state = SCAN_COL;
                end
            end
            SCAN_COL: begin
                row = 4'b0000;
                if (switch_flag == 0) begin
                    next_state = SCAN_ROW_0;
                end
                if (switch_flag == 2) begin
                    next_state = INIT;
                end
            end
            SCAN_ROW_0: begin
                row = 4'b1110;
                if (switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                if (row_temp == 2'b01) begin
                    next_state = SCAN_ROW_1;
                end
            end
            SCAN_ROW_1: begin
                row = 4'b1101;
                if (switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                if (row_temp == 2'b10) begin
                    next_state = SCAN_ROW_2;
                end
            end
            SCAN_ROW_2: begin
                row = 4'b1011;
                if (switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                if (row_temp == 2'b11) begin
                    next_state = SCAN_ROW_3;
                end
            end
            SCAN_ROW_3: begin
                row = 4'b0111;
                if (switch_flag == 1) begin
                    next_state = WAIT_RLF;
                end
                if (row_temp == 2'b00) begin
                    next_state = SCAN_ROW_0;
                end
            end
            WAIT_RLF: begin
                if (switch_flag == 3) begin
                    next_state = INIT;
                end
            end
            default: begin
                next_state = INIT;
            end
        endcase
    end

    always @(posedge btnclk) begin
        current_state <= next_state;
        case (current_state)
            INIT: begin
                row_temp <= 2'b00;
                if (~col_total) begin
                    switch_flag <= 1;
                end else begin
                    key[3:0] <= 4'b0000;
                end
            end
            SCAN_COL: begin
                if (col[0] == 0) begin
                    col_temp <= 2'b00;
                    switch_flag <= 0;
                end
                if (col[1] == 0) begin
                    col_temp <= 2'b01;
                    switch_flag <= 0;
                end
                if (col[2] == 0) begin
                    col_temp <= 2'b10;
                    switch_flag <= 0;
                end
                if (col[3] == 0) begin
                    col_temp <= 2'b11;
                    switch_flag <= 0;
                end
                if (col_total) begin
                    switch_flag <= 2;
                end
            end
            SCAN_ROW_0: begin
                if (~col_total) begin
                    row_temp <= 2'b00;
                    switch_flag <= 1;
                end else begin
                    row_temp <= 2'b01;
                end
            end
            SCAN_ROW_1: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end else begin
                    row_temp <= 2'b10;
                end
            end
            SCAN_ROW_2: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end else begin
                    row_temp <= 2'b11;
                end
            end
            SCAN_ROW_3: begin
                if (~col_total) begin
                    switch_flag <= 1;
                end else begin
                    row_temp <= 2'b00;
                end
            end
            WAIT_RLF: begin
                if (~col_total) begin
                    key[1:0] <= col_temp;
                    key[3:2] <= row_temp;
                    press <= 1;
                end else begin
                    press <= 0;
                    switch_flag <= 3;
                end
            end
            default: begin
                current_state <= INIT;
            end
        endcase
    end

endmodule
