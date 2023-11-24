/* 
** Engineer:  mgwang37  mgwang37@126.com
** Create Date: 11/16/2023 23:00:52
**
** Module Name: FP32Multi
**
** Description: 
**      符合IEEE-754标准fp32浮点乘法器(四级流水)
**
** Dependencies: NO
**
** Revision:
**
** Revision 0.01 - File Created
**
** Additional Comments:
*/

module FP32Multi
(
	input         clk,
	input         en,

	input [31:0]  x1,
	input [31:0]  x2,

	input [31:0]  y
);

/********0********/
wire [23:0] x1_0 = (x1[30:23] == 8'h00) ? {1'b0, x1[22:0]} : {1'b1, x1[22:0]};
wire [23:0] x2_0 = (x2[30:23] == 8'h00) ? {1'b0, x2[22:0]} : {1'b1, x2[22:0]};

wire [ 1:0] state_0;
assign state_0[1] = (x1[30:23] == 8'hff) | (x2[30:23] == 8'hff);
assign state_0[0] = (x1[30: 0] == 8'h00) | (x2[30: 0] == 8'h00);

wire signed [9:0] expo_x1_base = (x1[30:23] == 8'h00) ? 126 : 127;
wire signed [9:0] expo_x2_base = (x2[30:23] == 8'h00) ? 126 : 127;

/********1********/
reg  signed [ 9:0] expo_1;
reg         [47:0] mant_1;
reg                sign_1;
reg         [ 1:0] state_1;

wire signed [9:0] expo_x1 = {2'h0,x1[30:23]};
wire signed [9:0] expo_x2 = {2'h0,x2[30:23]};

always @(posedge clk)begin
	if (!en)begin
	end
	else begin
		expo_1  <= expo_x1 + expo_x2 - expo_x1_base - expo_x2_base;
		mant_1  <= x1_0 * x2_0;
		sign_1  <= x1[31] ^ x2[31];
		state_1 <= state_0;
	end
end

/********2********/
reg signed  [ 9:0] expo_2;
reg         [47:0] mant_2;
reg                sign_2;
reg         [ 1:0] state_2;

always @(posedge clk)begin
	if (!en)begin
	end
	else begin
		sign_2  <= sign_1;
		state_2 <= state_1;

		if (mant_1[47:36]!=12'h000)begin
			mant_2 <= mant_1;
			expo_2 <= expo_1;
		end
		else if (mant_1[35:24]!=12'h000)begin
			mant_2 <= mant_1 << 12;
			expo_2 <= expo_1 - 12;
		end
		else if (mant_1[23:12]!=12'h000)begin
			mant_2 <= mant_1 << 24;
			expo_2 <= expo_1 - 24;
		end
		else begin
			mant_2 <= mant_1 << 36;
			expo_2 <= expo_1 - 36;
		end
	end
end

/********3********/
reg  signed [ 9:0] expo_3;
reg         [47:0] mant_3;
reg                sign_3;
reg         [ 1:0] state_3;

always @(posedge clk)begin
	if (!en)begin
	end
	else begin
		sign_3  <= sign_2;
		state_3 <= state_2;

		if (mant_2[47])begin
			mant_3 <= mant_2 << 0;
			expo_3 <= expo_2 +1;
		end
		else if (mant_2[46])begin
			mant_3 <= mant_2 << 1;
			expo_3 <= expo_2 +0;
		end
		else if (mant_2[45])begin
			mant_3 <= mant_2 << 2;
			expo_3 <= expo_2 -1;
		end
		else if (mant_2[44])begin
			mant_3 <= mant_2 << 3;
			expo_3 <= expo_2 -2;
		end
		else if (mant_2[43])begin
			mant_3 <= mant_2 << 4;
			expo_3 <= expo_2 -3;
		end
		else if (mant_2[42])begin
			mant_3 <= mant_2 << 5;
			expo_3 <= expo_2 -4;
		end
		else if (mant_2[41])begin
			mant_3 <= mant_2 << 6;
			expo_3 <= expo_2 -5;
		end
		else if (mant_2[40])begin
			mant_3 <= mant_2 << 7;
			expo_3 <= expo_2 -6;
		end
		else if (mant_2[39])begin
			mant_3 <= mant_2 << 8;
			expo_3 <= expo_2 -7;
		end
		else if (mant_2[38])begin
			mant_3 <= mant_2 << 9;
			expo_3 <= expo_2 -8;
		end
		else if (mant_2[37])begin
			mant_3 <= mant_2 << 10;
			expo_3 <= expo_2 -9;
		end
		else if (mant_2[36])begin
			mant_3 <= mant_2 << 11;
			expo_3 <= expo_2 -10;
		end
	end
end

/********4********/
reg signed  [ 9:0] expo_4;
reg         [47:0] mant_4;
reg                sign_4;

assign y[31]    = sign_4;
assign y[30:23] = expo_4[7:0];
assign y[22:0]  = mant_4[46:24];

always @(posedge clk)begin
	if (!en)begin
	end
	else if (state_3[1])begin
		expo_4 <= 8'b11111111;
		mant_4 <= 48'h0;
		sign_4 <= sign_3;
	end
	else if (state_3[0])begin
		expo_4 <=  9'h0;
		mant_4 <= 48'h0;
		sign_4 <= sign_3;
	end
	else if (expo_3 > 127)begin
		expo_4 <= 8'b11111111;
		mant_4 <= 48'h0;
		sign_4 <= sign_3;
	end
	else if (expo_3 < -126)begin
		expo_4 <= 9'h0;
		mant_4 <= mant_3 >> (-126 - expo_3);
		sign_4 <= sign_3;
	end
	else begin
		expo_4 <= expo_3 + 127;
		mant_4 <= mant_3;
		sign_4 <= sign_3;
	end
end

endmodule
