`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 14:28:04
// Design Name: 
// Module Name: top
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


module top(w_clk, w_sw,w_btnu, w_btnd, w_btnl, w_btnr, w_btnc, LED, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, r_sg, r_an); 
    input  wire w_clk, w_btnu, w_btnd, w_btnl, w_btnr, w_btnc; 
    input wire[1:0] w_sw;
    output wire [15:0] LED; 
    output reg         VGA_HS, VGA_VS;
    output wire [3:0]  VGA_R, VGA_G, VGA_B;
    output reg [6:0] r_sg;
    output reg [7:0] r_an;
    reg[10:0] block_x= 100, block_y= 50;
    wire[10:0] w_ran ;
    reg[2:0] ran;
    wire CLK, w_locked;
    //pos_ is enemy posision , b_ is ball posision, and m_ is player posision.
    reg[10:0] pos_x, pos_y, b_x, b_y, m_x, m_y;
    initial begin
      pos_x = 100;
      pos_y = 50;
      b_x = 300;
      b_y = 300;
      m_x = 500;
      m_y = 300;
    end
    reg r_wait=1;
    
    wire hit, hit2, hit3, hit4, hit5, goal1, goal2, disp1,disp2, center1, center2;
    reg[2:0] speed_x; initial speed_x <=1;
    reg[2:0] speed_y; initial speed_y <=1;
    reg[6:0] size1=21, size2=10;
    always @(posedge CLK) if(w_btnc && r_wait) begin
      r_wait = 0;
      end
    //judge did enemy hit a ball
    pow pow0(CLK, pos_x, pos_y, b_x, b_y, hit, size1, size2);
    //judge did enemy goal
    block g2(CLK, b_x, b_y, 749, 270, 330, goal1, size2);
    // judge did player goal
    block g1(CLK, b_x, b_y, 50, 270, 330, goal2, size2);
    //judge did player hit a ball
    pow pow3(CLK, m_x, m_y, b_x, b_y, hit3, size1,size2);
    reg[31:0] cnt1=0;// player and enemy move when cnt1 is zero
    reg[31:0] cnt2=0;// ball move when cnt2 is zero.
    always @(posedge CLK) begin
      cnt1 <=  (w_sw[0])? cnt1 : (cnt1>100000-1)? 0 : cnt1+1;
      cnt2 <=  (w_sw[0])? cnt2 : (cnt2>50000-1)? 0 : cnt2+1;
    end
   // player and enemy controller
    always @(posedge CLK) begin
      pos_x <= (goal1 || goal2)? 150 :(cnt1!=0)? pos_x: (b_x>pos_x)? pos_x+1 : (b_x==pos_x)? pos_x: pos_x-1;
      pos_y <= (goal1 || goal2)? 299 :(cnt1!=0)? pos_y: (b_y>pos_y)? pos_y+1 : (b_y==pos_y)? pos_y: pos_y-1;
      m_x <= (goal1 || goal2)? 600 :(cnt1!=0)? m_x: (w_btnl)? m_x-1 : (w_btnr)? m_x+1: m_x;
      m_y <= (goal1 || goal2)? 300 :(cnt1!=0)? m_y: (w_btnu)? m_y-1 : (w_btnd)? m_y+1: m_y; 
    end
    
    //ball controller
    always @(posedge CLK) begin
    //enemy hit a ball
      if(hit) begin
        speed_x <= (b_x>=pos_x)? 2 : 0;
        speed_y = (b_y>pos_y)? 2 : 0;
      end
      //player hit a ball.
      if(hit3) begin
        speed_x <= (b_x>m_x)? 2 : 0;
        speed_y = (b_y>m_y)? 2 : 0;
      end
      if(goal1 ||goal2) speed_x =1;// speed_y = 1;
      if(b_y<100) speed_y = 2;
      if(b_x<50) speed_x = 2;
      if(b_x>750) speed_x =0;
      if(b_y>499) speed_y=0;
      b_x <= (cnt2!=0)?  b_x : (goal1 || goal2)? 400 :  b_x+ speed_x -1;
      b_y <= (cnt2!=0)?  b_y: (goal1 || goal2)? 300 :  b_y + speed_y -1;
    end
    wire state[2:0];
    reg r_rst =0;
    
   
    clk_wiz_0 clk_wiz(CLK, 0, w_locked, w_clk); // 100MHz -> 40MHz 
    wire w_rst= ~w_locked || r_rst || w_sw[1];
    reg [31:0] r_cnt= 1;
    reg [31:0] score = 31'd0;
    always @(posedge CLK) begin 
      r_cnt<= (w_rst) ? 0 : r_cnt+ 1;
      
    end
    assign LED= r_cnt[31:16];
    /********** 800 x 600 60Hz SVGA Controller **********/ 
    reg [10:0] hcnt, vcnt;
    wire [6:0] w_sg;
    wire [7:0] w_an;
    
    
    always @(posedge CLK) begin
    if(w_rst && cnt2==0)
          score = 0;
    if( goal2 && cnt2 ==0) begin
     //r_wait <= 1;
     score = score + 31'd1;
    end
    if( goal1 && cnt2 ==0) begin
     //r_wait <= 1;
     score = score+ 31'd10000;
    
    end
    r_sg = w_sg;
    r_an = w_an;
    end
    //LED display each other score
    m_score s(CLK, score, w_sg, w_an);
    //VGA display game status
    pow pow1(CLK, hcnt, vcnt, m_x, m_y, hit2, 0,size1); 
    pow pow4(CLK, hcnt, vcnt, b_x, b_y, hit4, 0, size2);
    pow pow2(CLK,hcnt, vcnt, pos_x, pos_y, hit5, 0,size1);
    pow pow6(CLK, hcnt,vcnt, 400, 300, center1, 0,40);
    pow pow7(CLK, hcnt,vcnt, 400, 300, center2, 0,45);
    block d1(CLK, hcnt, vcnt, 50, 270, 330, disp1, 2);
    block d2(CLK, hcnt, vcnt, 748, 270, 330, disp2, 2);
    
    always @(posedge CLK) begin hcnt<= (w_rst) ? 0 : (hcnt==1055) ? 0 : hcnt+ 1;
     vcnt<= (w_rst) ? 0 : (hcnt!=1055) ? vcnt: (vcnt==627) ? 0 : vcnt+ 1;
     VGA_HS <= (w_rst) ? 1 : (hcnt>=840 && hcnt<=967) ? 0 : 1;
     VGA_VS <= (w_rst) ? 1 : (vcnt>=601 && vcnt<=604) ? 0 : 1; 
    end
     
    assign VGA_R =  (hit4 || hit5 || disp1 || disp2)? 4'b1111: (center2)? (center1)? 0:4'b1111:0;
    assign VGA_G = (~state[0])?   0: ( hit4 || hit5)? 0: 4'b1111;
    assign VGA_B = (hit2 || hit4)? 4'b1111: (center2)? (center1)? 0:4'b1111:0;
    assign state[0] =   hcnt > 50 && hcnt< 750 && vcnt<550 && vcnt >50;
endmodule

module pow (clk,pos_x, pos_y, x, y, hit, size1, size2);
   input clk;
   input wire[10:0] x, y, pos_x, pos_y;
   input wire[6:0] size1, size2; 
   output  reg hit;
   
   reg[31:0] cnt;
   always @(posedge clk)  begin
    cnt = (pos_x-x)**2+(pos_y-y)**2;
    hit <= (size1+size2)**2 > cnt;
    end
   
   //m_score score(clk,cnt, w_sg, w_an);
endmodule

module block (clk, pos_x, pos_y, x, y1,y2, hit, size1);
    input clk;
   input wire[10:0] x, y1,y2, pos_x, pos_y;
   input wire[6:0] size1; 
   output  reg hit;
   
   reg[31:0] cnt; 
   always @(posedge clk) begin
     hit <= (pos_y>y1 && pos_y<y2)? size1>pos_x-x:0;
   end
endmodule


