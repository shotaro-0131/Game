`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 14:45:23
// Design Name: 
// Module Name: m_score
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


module m_score(w_clk, w_num, r_sg, r_an);
    input wire w_clk;
    output reg [6:0] r_sg;
    output reg [7:0] r_an;
    input wire[31:0] w_num;
    reg [3:0] num1, num2, num3, num4,  num5, num6, num7, num8;
    always @(posedge w_clk) begin
        num1 = w_num%10;
        num2 = w_num/10%10;
        num3 = w_num/100%10;
        num4 = w_num/1000%10;
        num5 = w_num/10000%10;
        num6 = w_num/100000%10;
        num7 = w_num/1000000%10;
        num8 = w_num/10000000%10;
    end
    wire [6:0] w_sg1, w_sg2, w_sg3, w_sg4, w_sg5, w_sg6, w_sg7, w_sg8;
    m_7segled m1(num1, w_sg1);
    m_7segled m2(num2, w_sg2);
    m_7segled m3(num3, w_sg3);
    m_7segled m4(num4, w_sg4);
    m_7segled m5(num5, w_sg5);
    m_7segled m6(num6, w_sg6);
    m_7segled m7(num7, w_sg7);
    m_7segled m8(num8, w_sg8);
    reg[31:0] r_cnt;
    reg[3:0] r_digit=0;
    always@(posedge w_clk) begin
       r_cnt <= (r_cnt>=(20000-1)) ? 0 : r_cnt+1;
           if(r_cnt==0) begin
            r_digit <= (r_digit>8-1)? 0: r_digit+1;
                case(r_digit)
                    3'h0:begin 
                        r_sg <= w_sg1; 
                        r_an <= 8'b11111110;
                        end
                    3'h1:begin 
                        r_sg <= w_sg2;  
                        r_an <= 8'b11111101;
                        end
                    3'h2:begin 
                        r_sg <= w_sg3; 
                        r_an <= 8'b11111011;
                        end
                    3'h3:begin 
                        r_sg <= w_sg4;  
                        r_an <= 8'b11110111;
                        end
                   3'h4:begin 
                       r_sg <= w_sg5; 
                       r_an <= 8'b11101111;
                       end
                   3'h5:begin 
                       r_sg <= w_sg6;  
                       r_an <= 8'b11011111;
                       end
                   3'h6:begin 
                       r_sg <= w_sg7; 
                       r_an <= 8'b10111111;
                       end
                   3'h7:begin 
                       r_sg <= w_sg8;  
                       r_an <= 8'b01111111;
                       end endcase
                end
           end    
endmodule

module m_7segled (w_num, r_sg);
     input wire [3:0] w_num;
     output reg [6:0] r_sg;
     always @(*) begin
     case(w_num%4'd10)         
     4'd0: r_sg <=~7'b1111110;
     4'd1: r_sg <=~7'b0110000;
     4'd2: r_sg <=~7'b1101101; 
     4'd3: r_sg <=~7'b1111001; 
     4'd4: r_sg <=~7'b0110011;
     4'd5: r_sg <=~7'b1011011;
     4'd6: r_sg <=~7'b1011111; 
     4'd7: r_sg <=~7'b1110000; 
     4'd8: r_sg <=~7'b1111111; 
     4'd9: r_sg <=~7'b1111011;
     endcase
     end 
endmodule
