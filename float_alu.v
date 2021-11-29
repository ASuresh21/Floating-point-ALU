`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:29:36 03/11/2018 
// Design Name: 
// Module Name:    float_alu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module float_alu(op,a,b,clk,out);
input [31:0] a,b; 
input [2:0] op;
input clk;
output reg [31:0] out;
reg signed [7:0] exp_a,exp_b,expo;
reg signed [22:0] integ_a,integ_b,float_a,float_b,a_s,b_s,intega_s,integb_s,floata_s,floatb_s,intego,floato,intego_s,floato_s,intego_so,floato_so,mano;
reg signed [45:0] arg_a,arg_b,res_md;
reg [2:0] op_s;
reg [5:0] ia,ib,ja,jb,io,jo,fla,flb,fla_s,flb_s;
integer neg_flag,neg_flag_s;

always@(posedge clk) begin
	exp_a=a[30:23]-127;
	
	if(exp_a==0) begin
		integ_a=1;
		float_a=0; end
		
	else begin
		a_s=a[22:0];
		if(exp_a<0) begin
			exp_a=exp_a*-1;
			a_s={1,a_s}>>exp_a; 
			integ_a=0;
		end
		else
			integ_a={1,a_s}>>(23-exp_a);
		float_a=a_s<<exp_a; 
	end
	if(a[31]) begin
		integ_a=-integ_a;
		float_a=-float_a;
	end
	for(ia=0,ja=23;ia<23;ia=ia+1)
		if((float_a[ia]==1)&&(ja>ia))
			ja=ia;
	fla=23-ja;
end

always@(posedge clk) begin
	exp_b=b[30:23]-127;
	
	if(exp_b==0) begin
		integ_b=1;
		float_b=0; end
		
	else begin
		b_s=b[22:0];
		if(exp_b<0) begin
			exp_b=exp_b*-1;
			b_s={1,b_s}>>exp_b; 
			integ_b=0;
		end
		else
			integ_b={1,b_s}>>(23-exp_b);
		float_b=b_s<<exp_b; 
	end
	if(b[31]) begin
		integ_b=-integ_b;
		float_b=-float_b;
	end
	for(ib=0,jb=23;ib<23;ib=ib+1)
		if((float_b[ib]==1)&&(jb>ib))	
			jb=ib;
	flb=23-jb;
end

always@(negedge clk) begin
	intega_s=integ_a;
	floata_s=float_a;
	integb_s=integ_b;
	floatb_s=float_b;
	op_s=op;
	fla_s=fla;
	flb_s=flb;
end

always@(posedge clk) begin
case(op_s)
3'b00:begin
	{intego,floato}={intega_s,floata_s}+{integb_s,floatb_s};
	if(intego<0) begin
		{intego,floato}=-{intego,floato};
		neg_flag=1; 
		end
	else
		neg_flag=0;	
	end
3'b001:begin
	{intego,floato}={intega_s,floata_s}-{integb_s,floatb_s}; 
	end

3'b010:begin
	arg_a={intega_s,floata_s};
	arg_b={integb_s,floatb_s};
	arg_a=arg_a>>(23-fla_s);
	arg_b=arg_b>>(23-flb_s);
	res_md=arg_a*arg_b;
	res_md=res_md<<23-(fla_s+flb_s);
	{intego,floato}=res_md;
	end
3'b011:begin
	arg_a={intega_s,floata_s};
	arg_b={integb_s,floatb_s};
	arg_a=arg_a>>(23-fla_s);
	arg_b=arg_b>>(23-flb_s);
	res_md=arg_a/arg_b;
	res_md=res_md<<23-(fla_s-flb_s);
	{intego,floato}=res_md;
	end
3'b100:{intego,floato}={intega_s,floata_s};
3'b101:{intego,floato}=-{intega_s,floata_s};
3'b110:{intego,floato}={intega_s,floata_s}>>>integb_s;
3'b111:{intego,floato}={intega_s,floata_s}<<<integb_s;
endcase
if(intego<0) begin 
		{intego,floato}=-{intego,floato};
		neg_flag=1; 
		end
	else
		neg_flag=0;
end

always@(negedge clk) begin
	neg_flag_s=neg_flag;
	intego_s=intego;
	floato_s=floato;
end

always@(posedge clk) begin
	if({intego_s,floato_s}) begin
		if(intego_s) begin
			for(io=22,jo=0;io>0;io=io-1)
				if((intego_s[io]==1) && (jo<io))
					jo=io;
			expo=jo+127;
			if(jo) mano={intego_s,floato_s}>>jo;
			else
				mano=floato_s;
		end
		else begin
			for(io=0;(~intego_s[0])&&io<23;io=io+1)
				{intego_so,floato_so}={intego_s,floato_s}<<1;
			expo=io+125;
			mano=floato_so;
		end
		out={neg_flag_s,expo,mano};
	end
	else
		out=0;
end
endmodule
