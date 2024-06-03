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
    input      [2:0] sw,         //开关信号
    output     [3:0] row,        //4 row,输出
    output     [7:0] seg,        //segment
    output     [1:0] dig,        //dig
    output reg [3:0] led,
    output reg [4:0] state_led
);

    wire          clk_10hz;
    wire    [3:0] key;
    wire          press;
    reg     [3:0] key_buf;
    integer       delay_counter;
    integer       delay_limit;
    integer       callback;
    reg     [3:0] disp_floor = 4'b0000;
    reg     [3:0] disp_state = 4'b0000;
    reg     [7:0] current_state = 8'b00000000;
    reg     [7:0] next_state = 8'b00000000;

    parameter INIT = 0;
    parameter AT_1 = 1;
    parameter AT_2 = 2;
    parameter GOING_UP = 3;
    parameter GOING_DOWN = 4;
    parameter RST_WHILE_GOING_UP = 5;
    parameter CNT_CLR = 6;

    clk_10hz clk_10hz (
        .clk_in (clk_50mhz),
        .clk_out(clk_10hz)
    );

    key_deboucing key_deboucing (
        .clk  (clk_50mhz),
        .col  (col),
        .row  (row),
        .key  (key),
        .press(press)
    );

    always @(*) begin
        if (sw[1] & press) begin
            key_buf = key;
        end else begin
            key_buf = 4'b1111;
        end
    end

    // A:ready B:up C:down
    dynamic_led2 dynamic_led2 (
        .disp_data_right0(disp_floor),
        .disp_data_right1(disp_state),
        .clk             (clk_50mhz),
        .seg             (seg),
        .dig             (dig)
    );

    always @(*) begin
        next_state = current_state;
        case (current_state)
            INIT: begin
                next_state = AT_1;
            end
            AT_1: begin
                if (sw[0] == 0) begin
                    next_state = AT_1;
                end
                else if((key_buf == 4)||(key_buf == 7)||(led[1] == 1)||(led[3] == 1)) begin
                    next_state = CNT_CLR;
                end else begin
                    next_state = AT_1;
                end
            end
            AT_2: begin
                if (sw[0] == 0) begin
                    next_state = CNT_CLR;
                end
                else if((key_buf == 0)||(key_buf == 3)||(led[0] == 1)||(led[2] == 1)) begin
                    next_state = CNT_CLR;
                end else begin
                    next_state = AT_2;
                end
            end
            GOING_UP: begin
                if (sw[0] == 0) begin
                    next_state = RST_WHILE_GOING_UP;
                end else begin
                    if (delay_counter == 299) begin
                        next_state = AT_2;
                    end else begin
                        next_state = GOING_UP;
                    end
                end
            end
            GOING_DOWN: begin
                if (delay_counter == 299) begin
                    next_state = AT_1;
                end
            end
            RST_WHILE_GOING_UP: begin
                if (delay_counter == 0) begin
                    next_state = AT_1;
                end
            end
            CNT_CLR: begin
                if (delay_counter == 0) begin
                    next_state = callback;
                end
            end
            default: begin
                next_state = INIT;
            end
        endcase
    end

    always @(posedge clk_10hz) begin
        current_state <= next_state;
        case (current_state)
            INIT: begin
                disp_floor <= 1;
                disp_state <= 4'hA;
            end
            AT_1: begin
                disp_floor <= 1;
                disp_state <= 4'hA;
                led[2] <= 0;
                led[0] <= 0;
                state_led <= 5'b00000;
                callback <= GOING_UP;
                if (sw[0] == 0) begin
                    led <= 4'b0000;
                end
                else if (key_buf == 7) begin
                    led[3] <= 1;
                end
                else if (key_buf == 4) begin
                    led[1] <= 1;
                end
            end
            AT_2: begin
                disp_floor <= 2;
                disp_state <= 4'hA;
                led[3] <= 0;
                led[1] <= 0;
                state_led <= 5'b00000;
                callback <= GOING_DOWN;
                if (sw[0] == 0) begin
                    led <= 4'b0000;
                end
                else if (key_buf == 3) begin
                    led[2] <= 1;
                end
                else if (key_buf == 0) begin
                    led[0] <= 1;
                end
            end
            GOING_UP: begin
                disp_state <= 4'hB;
                delay_counter <= delay_counter + 1;
                if (delay_counter >= 200) begin
                    disp_floor <= 2;
                end else begin
                    disp_floor <= 1;
                end
                if (sw[0] == 0) begin
                    led <= 4'b0000;
                end
                else if (key_buf == 0) begin
                    led[0] <= 1;
                end
                else if (key_buf == 3) begin
                    led[2] <= 1;
                end
                if (delay_counter <= 60) begin
                    state_led <= 5'b10000;
                end else if (delay_counter <= 120) begin
                    state_led <= 5'b01000;
                end else if (delay_counter <= 180) begin
                    state_led <= 5'b00100;
                end else if (delay_counter <= 240) begin
                    state_led <= 5'b00010;
                end else if (delay_counter <= 300) begin
                    state_led <= 5'b00001;
                end
            end
            GOING_DOWN: begin
                disp_floor <= 2;
                disp_state <= 4'hC;
                delay_counter <= delay_counter + 1;
                if (delay_counter >= 200) begin
                    disp_floor <= 1;
                end else begin
                    disp_floor <= 2;
                end
                if (key_buf == 4) begin
                    led[1] <= 1;
                end
                else if (key_buf == 7) begin
                    led[3] <= 1;
                end
                if (delay_counter <= 60) begin
                    state_led <= 5'b00001;
                end else if (delay_counter <= 120) begin
                    state_led <= 5'b00010;
                end else if (delay_counter <= 180) begin
                    state_led <= 5'b00100;
                end else if (delay_counter <= 240) begin
                    state_led <= 5'b01000;
                end else if (delay_counter <= 300) begin
                    state_led <= 5'b10000;
                end
            end
            RST_WHILE_GOING_UP: begin
                disp_state <= 4'hC;
                delay_counter <= delay_counter - 1;
                if (delay_counter <= 60) begin
                    state_led <= 5'b10000;
                end else if (delay_counter <= 120) begin
                    state_led <= 5'b01000;
                end else if (delay_counter <= 180) begin
                    state_led <= 5'b00100;
                end else if (delay_counter <= 240) begin
                    state_led <= 5'b00010;
                end else if (delay_counter <= 300) begin
                    state_led <= 5'b00001;
                end
            end
            CNT_CLR: begin
                delay_counter <= 0;
            end
            default: begin

            end
        endcase
    end
endmodule
