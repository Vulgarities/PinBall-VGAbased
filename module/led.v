module led(
     input clk, 
     input lose,
     output reg [3:0] select, 
     output reg [6:0] seg
    );
    reg [3:0] num0 = 4'b0000;
    
    reg [3:0] num1 = 4'b0000;
    
    reg [3:0] num2 = 4'b0000;
    
    reg [3:0] num3 = 4'b0000;
    
    reg [2:0] cnt = 0;
    
    reg [32:0] clk_cnt = 0;
    reg sclk = 0;
    
    //��Ƶ
    always@(posedge clk)
    begin
        if(clk_cnt == 10000)
        begin
            sclk <= ~sclk;
            clk_cnt <= 0;
        end
        else
            clk_cnt <= clk_cnt + 1;
    end
    
    
    wire [6:0] out0;
    wire [6:0] out1;
    wire [6:0] out2;
    wire [6:0] out3;
    
decoder seg0(
        .clk(clk),
        .num(num0),
        .oData(out0)
);
    
decoder seg1(
        .clk(clk),
        .num(num1),
        .oData(out1)
);
    
decoder seg2(
        .clk(clk),
        .num(num2),
        .oData(out2)
);
    
decoder seg3(
        .clk(clk),
        .num(num3),
        .oData(out3)
);
        
always@(posedge sclk)
begin
            case(cnt)
            2'b00:
            begin
                seg <= out0;
                select <= 4'b1110;
            end 
            2'b01:
            begin
                seg <= out1;
                select <= 4'b1101;
            end
            2'b10:
            begin
                seg <= out2;
                select <= 4'b1011;
            end
            2'b11:
            begin
                seg <= out3;
                select <= 4'b0111;
            end
            endcase
            if(cnt == 2'b11)
                cnt <= 0;
            else
                cnt <= cnt + 1; 
            
end
    
    // Flush data each time you lose
always@(posedge lose)
    begin
        if(num0 == 9)
        begin
            num0 <= 0;
            if(num1 == 9)
            begin
                num1 <= 0;
                if(num2 == 9)
                begin
                    num2 <= 0;
                    if(num3 == 9)
                        num3 <= 0;
                    else
                        num3 <= num3 + 1;
                end
                else
                    num2 <= num2 + 1;
            end
            else
                num1 <= num1 + 1;
        end
        else
            num0 <= num0 + 1;
    
 end
endmodule


