module Sgame(
input I_clk, //ȫ��ʱ�ӣ�100MHz
input to_left, //�������ƣ��ߵ�ƽ��Ч
input to_right, //�������ƣ��ߵ�ƽ��Ч
output [3:0] O_blue, //��ɫ
output [3:0] O_green, //��ɫ
output [3:0] O_red,  //��ɫ 
output HSync, //VGA��ɨ���ź�
output VSync, //VGA��ɨ���ź�
output [3:0] seg_select, //�����λѡ�ź�
output [6:0] seg_LED //����������źţ�û��С����
    );
reg [3:0] bar_move_speed=3; //�����ƶ��ٶȿ��ƣ�Ϊ���ʾ��ֹ
wire mylose;
VGA_Dispay VGA(
.I_clk(I_clk), //����ʱ�ӣ�100MHz
.to_left(to_left), //ͬ��
.to_right(to_right), //ͬ��
.bar_move_speed(bar_move_speed), //ͬ��
       
.O_hs(HSync), //ͬ��
.O_vs(VSync), //ͬ��
.O_blue(O_blue),//ͬ��
.O_green(O_green),//ͬ��
.O_red(O_red),//ͬ��
.lose(mylose)   //��Ϸʧ���źţ�û�ܳɹ���ס��Ļ��ͻᴥ��һ���ߵ�ƽ���壬��������ܼ���
);

led score_board(
	.clk(I_clk),
	.lose(mylose),
	.select(seg_select),
	.seg(seg_LED)
	);
endmodule
