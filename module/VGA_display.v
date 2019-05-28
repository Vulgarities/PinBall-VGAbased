module VGA_Dispay
(
     input I_clk, //输入时钟，100MHz
     input to_left, //同上
     input to_right, //同上
     input [3:0] bar_move_speed, //同上
     output wire O_hs, //同上
     output wire O_vs, //同上
     output reg [3:0] O_blue,//同上
     output reg [3:0] O_green,//同上
     output reg [3:0] O_red,//同上
     output reg lose       //游戏失败信号，没能成功挡住球的话就会触发一个高电平脉冲，用于数码管计数
);
initial lose=0;
reg R_clk_25M;
reg [2:0] count;
wire W_active_flag;
reg [32:0]ball_move_speed = 3;

// 分辨率为640*480时行时序各个参数定义
parameter      
                C_H_SYNC_PULSE      =   96  , 
                C_H_BACK_PORCH      =   48  ,
                C_H_ACTIVE_TIME     =   640 ,
                C_H_FRONT_PORCH     =   16  ,
                C_H_LINE_PERIOD     =   800 ;
// 分辨率为640*480时场时序各个参数定义               
parameter       
                C_V_SYNC_PULSE      =   2   , 
                C_V_BACK_PORCH      =   33  ,
                C_V_ACTIVE_TIME     =   480 ,
                C_V_FRONT_PORCH     =   10  ,
                C_V_FRAME_PERIOD    =   525 ;  

parameter
                ball_r=20;    //半径

reg [11:0]      R_h_cnt=0        ; // 行时序计数器
reg [11:0]      R_v_cnt=0        ; // 列时序计数器

reg [32:0]up_pos;
reg [32:0]down_pos;
reg [32:0]left_pos;
reg [32:0]right_pos;
reg [32:0]ball_x_pos;//球心坐标
reg [32:0]ball_y_pos;

reg [32:0]LEFT_BOUND=0+96+48;
reg [32:0]RIGHT_BOUND=640+96+48;
reg [32:0]UP_BOUND=0+2+33;
reg [32:0]DOWN_BOUND=480+2+33;
reg v_speed=1;//球的上下,0为向上
reg h_speed=1;//球的左右,0为向左，1为向右

initial
begin
up_pos=(430+2+33);
down_pos=(450+2+33);
left_pos=(190+96+48);
right_pos=(310+96+48);
ball_x_pos=(320+96+48);
ball_y_pos=(240+2+33);
end

//功能： 产生25MHz的时钟
initial count=0;
always @(posedge I_clk)
begin
     count<=(count+1)%4;
     if(count==1)
     R_clk_25M <= 1;
     else
     R_clk_25M <= 0;  
end

// 功能：产生行时序
always @(posedge R_clk_25M)
begin
    if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
        R_h_cnt <=  12'd0   ;
    else
        R_h_cnt <=  R_h_cnt + 1'b1  ;                
end               
assign O_hs = (R_h_cnt < C_H_SYNC_PULSE) ? 0 : 1    ;
// 功能：产生场时序
always @(posedge R_clk_25M)
begin
    if(R_v_cnt == C_V_FRAME_PERIOD - 1'b1)
        R_v_cnt <=  12'd0   ;
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
        R_v_cnt <=  R_v_cnt + 1'b1  ;
    else
        R_v_cnt <=  R_v_cnt ;                        
end                
assign O_vs =   (R_v_cnt < C_V_SYNC_PULSE) ? 0 : 1    ; 

wire flag;
assign flag=((R_h_cnt > (C_H_SYNC_PULSE + C_H_BACK_PORCH   -1 ))  &&
            (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  && 
            (R_v_cnt > (C_V_SYNC_PULSE + C_V_BACK_PORCH ))  &&
            (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME)));

wire bar;
wire ball;
assign bar=((R_v_cnt>up_pos) && 
            (R_v_cnt<down_pos) && 
            (R_h_cnt>left_pos) && 
            (R_h_cnt<right_pos));
assign ball=(((R_h_cnt-ball_x_pos)*(R_h_cnt - ball_x_pos)+
            (R_v_cnt - ball_y_pos)*(R_v_cnt - ball_y_pos))<= 
            (ball_r * ball_r));
//Display the downside bar and the ball
always @ (posedge R_clk_25M)   
begin  
        // Display the downside bar
        if (bar&&flag) 
        begin  
            O_red   <= 4'b1111;  
            O_green <= 4'b0000;  
            O_blue  <= 4'b0000; 
        end  
        
        // Display the ball
        else if (ball&&flag)  
        begin  
            O_red   <= 4'b0000;  
            O_green <= 4'b0000;  
            O_blue  <= 4'b1111;  
        end 
        
        else if(flag)
        begin  
            O_red   <= 4'b1111;  
            O_green <= 4'b1111;
            O_blue  <= 4'b1111; 
        end
        else
        begin
             O_red   <=  4'b0000 ;
             O_green <=  4'b0000   ;
             O_blue  <=  4'b0000;
       end      
end

//flush the image every frame

always @ (negedge O_vs)  
begin        
   // movement of the bar
   if (to_left && (left_pos >= LEFT_BOUND)) 
      begin  
            left_pos <= (left_pos - bar_move_speed);  
            right_pos <= (right_pos - bar_move_speed);  
      end  
   else if(to_right && (right_pos <= RIGHT_BOUND))
      begin       
            left_pos <= (left_pos + bar_move_speed); 
            right_pos <= (right_pos + bar_move_speed);  
      end  

        //movement of the ball
     if (v_speed == 0) // go up 
            ball_y_pos <= (ball_y_pos - ball_move_speed);  
     else //go down
            ball_y_pos <= (ball_y_pos + ball_move_speed);  
     if (h_speed == 1) // go right 
            ball_x_pos <= (ball_x_pos + ball_move_speed);  
     else //go left
            ball_x_pos <= (ball_x_pos - ball_move_speed);      
end 



//change directions when reach the edge or crush the bar
always @ (negedge O_vs)  
begin
        if (ball_y_pos <= (UP_BOUND+ball_r))   // Here, all the jugement should use >= or <= instead of ==
        begin   
            v_speed <= 1;            
            lose <= 0;
        end
        else if ((ball_y_pos >= (up_pos - ball_r)) && 
                (ball_x_pos <= right_pos) && 
                (ball_x_pos >= left_pos))  
            begin
                v_speed <= 0;
                
              //  ball_move_speed<=(ball_move_speed+2);  
            end
        else if ((ball_y_pos >= down_pos) && 
                (ball_y_pos < (DOWN_BOUND - ball_r)) )
        begin
            //Do what you want when lose
            v_speed<=0;
            h_speed<=0;
            lose <= 1;
            //ball_move_speed<=1;
            //初始化
        end
        else if (ball_y_pos >= (DOWN_BOUND - ball_r))
            v_speed <= 0; 
      else  
         v_speed <= v_speed;  

      if (ball_x_pos <= (LEFT_BOUND+ball_r))  
         h_speed <= 1;  
      else if (ball_x_pos >= (RIGHT_BOUND-ball_r))  
         h_speed <= 0;  
      else  
         h_speed <= h_speed;  
end 
endmodule