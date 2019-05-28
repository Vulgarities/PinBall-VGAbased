module Sgame(
input I_clk, //全局时钟，100MHz
input to_left, //挡板左移，高电平有效
input to_right, //挡板右移，高电平有效
output [3:0] O_blue, //蓝色
output [3:0] O_green, //绿色
output [3:0] O_red,  //红色 
output HSync, //VGA行扫描信号
output VSync, //VGA场扫描信号
output [3:0] seg_select, //数码管位选信号
output [6:0] seg_LED //数码管数据信号，没有小数点
    );
reg [3:0] bar_move_speed=3; //挡板移动速度控制，为零表示静止
wire mylose;
VGA_Dispay VGA(
.I_clk(I_clk), //输入时钟，100MHz
.to_left(to_left), //同上
.to_right(to_right), //同上
.bar_move_speed(bar_move_speed), //同上
       
.O_hs(HSync), //同上
.O_vs(VSync), //同上
.O_blue(O_blue),//同上
.O_green(O_green),//同上
.O_red(O_red),//同上
.lose(mylose)   //游戏失败信号，没能成功挡住球的话就会触发一个高电平脉冲，用于数码管计数
);

led score_board(
	.clk(I_clk),
	.lose(mylose),
	.select(seg_select),
	.seg(seg_LED)
	);
endmodule
