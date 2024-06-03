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
    input      [2:0] page_sel,
    output     [3:0] row,        //4 row,输出
    output     [7:0] seg,        //segment
    output     [5:0] dig,        //dig
    output reg [3:0] led,
    output reg [4:0] state_led,
    output reg [4:0] page_led
);

    wire          clk_10hz;
    wire    [3:0] key;
    wire          press;
    reg     [3:0] key_buf;
    integer       delay_counter;
    integer       callback;
    reg     [3:0] disp_floor = 4'b0000;
    reg     [3:0] disp_state = 4'b0000;
    reg     [3:0] disp_right0 = 4'b0000;
    reg     [3:0] disp_right1 = 4'b0000;
    reg     [3:0] disp_right2 = 4'b0000;
    reg     [3:0] disp_right3 = 4'b0000;
    reg     [3:0] disp_right4 = 4'b0000;
    reg     [3:0] disp_right5 = 4'b0000;
    reg     [3:0] current_state = 3'b000;
    reg     [3:0] next_state = 3'b000;
    reg     [3:0] norm_up_cnt0 = 4'b0000;
    reg     [3:0] norm_up_cnt1 = 4'b0000;
    reg     [3:0] norm_down_cnt0 = 4'b0000;
    reg     [3:0] norm_down_cnt1 = 4'b0000;
    reg     [3:0] tim_disp0 = 4'b0000;
    reg     [3:0] tim_disp1 = 4'b0000;
    reg     [3:0] tim_disp2 = 4'b0000;
    reg     [7:0] seg_reg;
    reg     [5:0] dig_reg;
    wire    [7:0] seg_wire;
    wire    [5:0] dig_wire;
    reg     [3:0] ontime_cnt0 = 4'b0000;
    reg     [3:0] ontime_cnt1 = 4'b0000;
    reg     [3:0] ontime_cnt2 = 4'b0000;
    reg     [3:0] ontime_cnt3 = 4'b0000;
    reg     [3:0] ontime_cnt4 = 4'b0000;
    reg     [3:0] ontime_cnt5 = 4'b0000;
    integer       ontime_cnt;
    integer       ontime_div;
    reg     [3:0] onday0 = 4'b0000;
    reg     [3:0] onday1 = 4'b1111;
    reg     [3:0] onday2 = 4'b1111;
    reg     [3:0] onday3 = 4'b1111;
    reg     [3:0] onday4 = 4'b1111;
    reg     [3:0] onday5 = 4'b1111;

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


    assign seg = seg_reg;
    assign dig = dig_reg;
    always @(*) begin
        seg_reg <= seg_wire;
        dig_reg <= dig_wire;
        if ((dig == 6'b011111) && (page_sel == 2)) begin
            seg_reg <= seg_wire | 8'h80;
        end else if (((dig == 6'b111011) || (dig == 6'b101111)) && (page_sel == 3)) begin
            seg_reg <= seg_wire | 8'h80;
        end
    end

    // A:ready B:up C:down
    dynamic_led2 dynamic_led2 (
        .disp_data_right0(disp_right0),
        .disp_data_right1(disp_right1),
        .disp_data_right2(disp_right2),
        .disp_data_right3(disp_right3),
        .disp_data_right4(disp_right4),
        .disp_data_right5(disp_right5),
        .clk             (clk_50mhz),
        .seg             (seg_wire),
        .dig             (dig_wire)
    );

    always @(*) begin
        tim_disp0 = delay_counter - (10 * (delay_counter / 10));
        tim_disp1 = delay_counter / 10 - (10 * (delay_counter / 100));
        tim_disp2 = delay_counter / 100;
        if (tim_disp0 >= 10) begin
            tim_disp0 = 0;
        end
    end

    always @(posedge clk_10hz) begin
        ontime_div = ontime_div + 1;
        if (ontime_div == 100) begin
            ontime_div  = 0;
            ontime_cnt0 = ontime_cnt0 + 1;
            if (ontime_cnt0 == 10) begin
                ontime_cnt0 = 0;
                ontime_cnt1 = ontime_cnt1 + 1;
            end
            if (ontime_cnt1 == 6) begin
                ontime_cnt1 = 0;
                ontime_cnt2 = ontime_cnt2 + 1;
            end
            if (ontime_cnt2 == 10) begin
                ontime_cnt2 = 0;
                ontime_cnt3 = ontime_cnt3 + 1;
            end
            if (ontime_cnt3 == 6) begin
                ontime_cnt3 = 0;
                ontime_cnt4 = ontime_cnt4 + 1;
            end
            if (ontime_cnt4 == 10) begin
                ontime_cnt4 = 0;
                ontime_cnt5 = ontime_cnt5 + 1;
            end
            if ((ontime_cnt5 == 2) && (ontime_cnt4 == 4)) begin
                ontime_cnt5 = 0;
                ontime_cnt4 = 0;
                onday0 = onday0 + 1;
            end
            if (onday0 == 10) begin
                onday0 = 0;
                onday1 = onday1 + 1;
            end
            if (onday1 == 10) begin
                onday1 = 0;
                onday2 = onday2 + 1;
            end
            if (onday2 == 10) begin
                onday2 = 0;
                onday3 = onday3 + 1;
            end
            if (onday3 == 10) begin
                onday3 = 0;
                onday4 = onday4 + 1;
            end
            if (onday4 == 10) begin
                onday4 = 0;
                onday5 = onday5 + 1;
            end
        end
    end

    always @(*) begin
        case (page_sel)
            0: begin
                disp_right0 = disp_floor;
                disp_right1 = disp_state;
                disp_right2 = 4'b1111;
                disp_right3 = 4'b1111;
                disp_right4 = 4'b1111;
                disp_right5 = 4'b1111;
                page_led = 5'b00001;
            end
            1: begin
                disp_right0 = norm_up_cnt0;
                disp_right1 = norm_up_cnt1;
                disp_right2 = 4'hB;
                disp_right3 = norm_down_cnt0;
                disp_right4 = norm_down_cnt1;
                disp_right5 = 4'hC;
                page_led = 5'b00010;
            end
            2: begin
                disp_right0 = disp_floor;
                disp_right1 = disp_state;
                disp_right2 = 4'b1111;
                disp_right3 = tim_disp0;
                disp_right4 = tim_disp1;
                disp_right5 = tim_disp2;
                page_led = 5'b00100;
            end
            3: begin
                disp_right0 = ontime_cnt0;
                disp_right1 = ontime_cnt1;
                disp_right2 = ontime_cnt2;
                disp_right3 = ontime_cnt3;
                disp_right4 = ontime_cnt4;
                disp_right5 = ontime_cnt5;
                page_led = 5'b01000;
            end
            4: begin
                disp_right0 = onday0;
                disp_right1 = onday1;
                disp_right2 = onday2;
                disp_right3 = onday3;
                disp_right4 = onday4;
                disp_right5 = onday5;
                page_led = 5'b10000;
            end
            default: begin
                disp_right0 = disp_floor;
                disp_right1 = disp_state;
                disp_right2 = 4'b1111;
                disp_right3 = 4'b1111;
                disp_right4 = 4'b1111;
                disp_right5 = 4'b1111;
                page_led = 5'b00001;
            end
        endcase
    end


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
                    norm_down_cnt0 <= 4'b0000;
                    norm_down_cnt1 <= 4'b0000;
                    norm_up_cnt0 <= 4'b0000;
                    norm_up_cnt1 <= 4'b0000;
                end else if (key_buf == 7) begin
                    led[3] <= 1;
                end else if (key_buf == 4) begin
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
                end else if (key_buf == 3) begin
                    led[2] <= 1;
                end else if (key_buf == 0) begin
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
                end else if (key_buf == 4) begin
                    led[1] <= 1;
                end else if (key_buf == 7) begin
                    led[3] <= 1;
                end else if (key_buf == 0) begin
                    led[0] <= 1;
                end else if (key_buf == 3) begin
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
                if (delay_counter == 299) begin
                    norm_up_cnt0 = norm_up_cnt0 + 1;
                    if (norm_up_cnt0 >= 10) begin
                        norm_up_cnt0 <= 0;
                        norm_up_cnt1 <= norm_up_cnt1 + 1;
                        if (norm_up_cnt1 >= 10) begin
                            norm_up_cnt1 <= 0;
                        end
                    end
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
                end else if (key_buf == 7) begin
                    led[3] <= 1;
                end else if (key_buf == 0) begin
                    led[0] <= 1;
                end else if (key_buf == 3) begin
                    led[2] <= 1;
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
                if (delay_counter == 299) begin
                    norm_down_cnt0 = norm_down_cnt0 + 1;
                    if (norm_down_cnt0 >= 10) begin
                        norm_down_cnt0 <= 0;
                        norm_down_cnt1 <= norm_down_cnt1 + 1;
                        if (norm_down_cnt1 >= 10) begin
                            norm_down_cnt1 <= 0;
                        end
                    end
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
