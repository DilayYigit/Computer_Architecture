`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2021 10:30:19 AM
// Design Name: 
// Module Name: PipelinedMips
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

module PipeFtoD(input logic[31:0] instr, PcPlus4F,
                input logic EN, clk,
                output logic[31:0] instrD, PcPlus4D);
 always_ff @(posedge clk)
    if(EN)
        begin
        instrD<=instr;
        PcPlus4D<=PcPlus4F;
        end
endmodule 

//--------------------------------------------------------------------

module PipeWtoF(input logic[31:0] PC,
                input logic EN, clk,
                output logic[31:0] PCF);
 always_ff @(posedge clk)
     if(EN)
         begin
         PCF<=PC;
         end
endmodule

//--------------------------------------------------------------------

module PipeDtoE(input logic[31:0] RD1, RD2, SignImmD,
                input logic[4:0] RsD, RtD, RdD,
                input logic[2:0] ALUControlD,
                input logic RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD,
                input logic clear, clk,
                output logic RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, RegDstE, BranchE,
                output logic[4:0] RsE, RtE, RdE,
                output logic[31:0] SignImmE,
                output logic[31:0] RD1E, RD2E,
                output logic[2:0] ALUControlE);
always_ff @(posedge clk)
    if (clear)
        begin
        RD1E <= 0;
        RD2E <= 0;
        RtData <= 0;
        RsE <= 0;
        RtE <= 0;
        RdE <= 0;
        SignImmE <= 0;
        RegWriteE <= 0;
        MemtoRegE <= 0;
        MemWriteE <= 0;
        ALUControlE <= 0;
        ALUSrcE <= 0;
        RegDstE <= 0;
        BranchE <= 0;
        end
    else
        begin
        RegWriteE <= RegWriteD;
        MemtoRegE <= MemtoRegD;
        MemWriteE <= MemWriteD;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        RegDstE <= RegDstD;
        BranchE <= BranchD;
        RD1E <= RD1;
        RD2E <= RD2;
        RsE <= RsD;
        RtE <= RtD;
        RdE <= RdD;
        SignImmE <= SignImmD;
        end
endmodule

//--------------------------------------------------------------------

module PipeEtoM(input logic RegWriteE, MemtoRegE, MemWriteE,BranchE, 
                input logic clk, ZeroE,
                input logic [31:0] ALUOutM,
                input logic [31:0] WriteDataE,
                input logic [4:0] WriteRegE,
                input logic PCBranchE,
                output logic RegWriteM, MemtoRegM, MemWriteM, BranchM, ZeroM,
                output logic [31:0] ALUOutM, WriteDataM,
                output logic [4:0] WriteRegM,
                output logic PCBranchM);
 always_ff @(posedge clk)
    begin
    ALUOutM <= ALUOutE;
    WriteDataM <= WriteDataE;
    RegWriteM <= RegWriteE;
    MemtoRegM <= MemtoRegE;
    MemWriteM <= MemWriteE;
    WriteRegM <= WriteRegM;
    BranchM <= BranchE;
    ZeroM <= ZeroM;
    PCBranchM <= PCBranchE;
    end
endmodule

//--------------------------------------------------------------------

module PipeMtoW(input logic clk,
                input logic [31:0] ReadDataM,
                input logic RegWriteM, MemtoRegM,
                input logic [31:0] ALUOutM,
                input logic [4:0] WriteRegM,
                output logic [31:0] ReadDataW, ALUOutW,
                output logic RegWriteW, MemtoRegW,
                output logic [4:0] WriteRegW);
always_ff @(posedge clk)
    begin
    ReadDataW <= ReadDataM;
    ALUOutW <= ALUOutM;
    RegWriteW <= RegWriteM;
    MemtoRegW <= MemtoRegM;
    WriteRegW <= WriteRegM;
    end
endmodule

//--------------------------------------------------------------------

module datapath(input logic clk, RegWriteW,
                input logic[2:0] ALUControlD,
                input logic BranchD,
                input logic [31:0] PCPlus4D, PC, PCF,
                input logic [31:0] ResultW,
                input logic [4:0] RsD,RtD,RdD,
                input logic [4:0] WriteRegW,
                output logic [31:0] instrF,instrD,
                output logic RegWriteE, MemToRegE,MemWriteE,
                output logic[31:0] ALUOutE, WriteDataE,
                output logic [4:0] WriteRegE,
                output logic [31:0] PCBranchE,
                output logic pcSrcE);

logic stallF, stallD, FlushE, ForwardAE, ForwardBE;
logic [31:0] PCMux2A, PCMux2B, PCPlus4F, PCBranchM;
logic [31:0] RD1, RD2, SignImmD, SignImmE, SignImmEN;

// 1---
PipeWtoF pipe1(PC, ~StallF, clk, PCF);
assign PCPlus4F = PCF + 4;
assign PCMux2A = PCPlus4F;
assign PCMux2B = PCBranchM;
mux2 #(32) counterMux(PCMux2A, PCMux2B, PCSrcM,PC);
imem instMem(PCF[7:2], instrF);

// 2---
PipeFtoD pipe2(instrF, PCPlus4F, ~StallD, clk, instrD, PCPlus4D);
regfile rf (clk, RegWriteW, instrD[25:21], instrD[20:16],
            WriteRegW, ResultW, RD1, RD2);
signext n(instrD[15:0], SignImmD);
assign RsD = instrD[25:21];
assign RtD = instrD[20:16];
assign RdD = instrD[15:11];

// 3---
PipeDtoE pipe3(RD1, RD2, SignImmD, RsD, RtD, RdD,
                RegWriteD, MemtoRegD, MemWriteD,
                ALUControlD, ALUSrcD, RegDstD,
                BranchD, BranchE, FlushE, clk, clear,
                RD1E, RD2E, SignImmE, RsE, RtE, RdE,
                RegWriteE, MemtoRegE, MemWriteE,
                ALUSrcE, RegDstE, ALUControlE);
mux2 #(5) PartEmux(RtE, RdE, RegDstE, WriteRegE);
mux3 #(32) otherMux41(RD1E, ResultW, ALUOutM, ForwardAE, SrcAE);
mux3 #(32) otherMux42(RD2E, ResultW, ALUOutM, ForwardBE, WriteDataE);
mux2 #(32) anotherMux2(WriteDataE, SignImmE, ALUSrcE, SrcBE);
sl2 sleft(SignImmE, SignImmEN);
adder dAdder(SignImmEN, PCPlus4E, PCBranchE);
alu oneAlu (SrcAE, SrcBE, ALUControlE, ALUOutE, ZeroE);

// 4---
PipeEtoM pipe3(ALUOutE, ZeroE, RegWriteE, MemtoRegE,
               MemWriteE, BranchE, WriteDataE, WriteRegE, 
               clk, PCBranchE, ALUOutM, WriteDataM, 
               RegWriteM, MemtoRegM, MemWriteM, PCBranchM,
               ZeroM, BranchM, WriteRegM);
assign PCSrcM = BranchM & ZeroM;
dmem dm(clk, MemWriteM, ALUOutM, WriteDataM, ReadDataM);

// 5---
PipeMtoW pipe4(ReadDataM, RegWriteM, MemtoRegM, ALUOutM,
               WriteRegM, clk, ReadDataW, ALUOutW,
               RegWriteW, MemtoRegW, WriteRegW);
mux2 #(5) oneMoreMux(ReadDataW, ALUOutW, MemtoRegW, ResultW);
endmodule

//--------------------------------------------------------------------
module HazardUnit( input logic RegWriteW,
                   input logic [4:0] WriteRegW,
                   input logic RegWriteM,MemToRegM,
                   input logic [4:0] WriteRegM,
                   input logic RegWriteE,MemToRegE,
                   input logic [4:0] RsE,RtE,
                   input logic [4:0] rsD,rtD,
                   output logic [2:0] ForwardAE,ForwardBE,
                   output logic FlushE,StallD,StallF);

logic lwstall, branchstall;
always_comb
begin
if ((RsE != 0) && (RsE == WriteRegM) && RegWriteM ) begin
    ForwardAE = 2'b10;
end else if ((RsE != 0) && (RsE == WriteRegW) && RegWriteW) begin
    ForwardAE = 2'b01;
end else
    ForwardAE = 2'b00;

if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM) begin
    ForwardBE = 2'b10;
end else if ((RtE != 0) & (RtE == WriteRegW) & RegWriteW) begin
    ForwardBE = 2'b01;
end else
    ForwardBE = 2'b00;
end
assign lwstall = ((RsD == RtE) || (RtD == RtE) && MemtoRegE) ? 1'b1: 1'b0;

assign branchstall = (BranchD && RegWriteW && 
                    (WriteRegE == Rsd || WriteRegE == RtD)) ||
                    (BranchD && MemtoRegM &&
                    (WriteRegM == RsD || WriteRegM == RtD));

assign StallF = (lwstall || branchstall) ? 1'b1: 1'b0;
assign StallD = (lwstall || branchstall) ? 1'b1: 1'b0;
assign FlushE = (lwstall || branchstall) ? 1'b1: 1'b0;

endmodule

//--------------------------------------------------------------------

module mips(input logic clk,
            output logic[31:0] PC,
            input logic[31:0] instr,
            output logic memwrite,
            output logic[31:0] aluout, resultW,
            output logic[31:0] instrOut,
            input logic[31:0] readdata);
            
logic memtoreg, pcsrc, zero, alusrc, regdst, regwrite, jump;
logic [2:0] alucontrol;
assign instrOut = instr;

datapath d(clk, RegWriteW, ALUControlD[2:0], BranchD, PCPlus4D[31:0], PC, PCF,
           ResultW[31:0], RsD[4:0], RtD[4:0], RdD[4:0], WriteRegW[4:0],
           instrF[31:0], instrD[31:0], RegWriteE, MemToRegE, MemWriteE,
           ALUOutE[31:0], WriteDataE[31:0],
           WriteRegE[4:0],
           PCBranchE[31:0],
           pcSrcE);

endmodule

//--------------------------------------------------------------------

module imem ( input logic [5:0] addr, output logic [31:0] instr);
always_comb
    case ({addr,2'b00}) 
    
    8'h00: instr = 32'h20020005; 
    8'h04: instr = 32'h2003000c; 
    8'h08: instr = 32'h2067fff7; 
    8'h0c: instr = 32'h00e22025; 
    8'h10: instr = 32'h00642824;
    8'h14: instr = 32'h00a42820;
    8'h18: instr = 32'h10a7000a;
    8'h1c: instr = 32'h0064202a;
    8'h20: instr = 32'h10800001;
    8'h24: instr = 32'h20050000;
    8'h28: instr = 32'h00e2202a;
    8'h2c: instr = 32'h00853820;
    8'h30: instr = 32'h00e23822;
    8'h34: instr = 32'hac670044;
    8'h38: instr = 32'h8c020050;
    8'h3c: instr = 32'h08000011;
    8'h40: instr = 32'h20020001;
    8'h44: instr = 32'hac020054;
    8'h48: instr = 32'h08000012;
    default: instr = {32{1'bx}}; // unknown address
    
    endcase
endmodule

//--------------------------------------------------------------------

module controller(input logic[5:0] op, funct,
                  output logic memtoreg, memwrite,
                  output logic alusrc,
                  output logic regdst, regwrite,
                  output logic jump,
                  output logic[2:0] alucontrol,
                  output logic branch);
logic [1:0] aluop;
maindec md (op, memtoreg, memwrite, branch, alusrc,
            regdst, regwrite, jump, aluop);
aludec ad (funct, aluop, alucontrol);
endmodule

//--------------------------------------------------------------------

module dmem(input logic clk, we,
            input logic[31:0] a, wd,
            output logic[31:0] rd);
            
logic [31:0] RAM[63:0];
assign rd = RAM[a[31:2]]; 
            
always_ff @(posedge clk)
    if (we)
    RAM[a[31:2]] <= wd; 
endmodule

//--------------------------------------------------------------------

module maindec (input logic[5:0] op,
                output logic memtoreg, memwrite, branch,
                output logic alusrc, regdst, regwrite, jump,
                output logic[1:0] aluop );
logic [8:0] controls;
assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, aluop, jump} = controls;
always_comb
    case(op)
    6'b000000: controls <= 9'b110000100; // R-type
    6'b100011: controls <= 9'b101001000; // LW
    6'b101011: controls <= 9'b001010000; // SW
    6'b000100: controls <= 9'b000100010; // BEQ
    6'b001000: controls <= 9'b101000000; // ADDI
    6'b000010: controls <= 9'b000000001; // J
    default: controls <= 9'bxxxxxxxxx; // illegal op
    endcase
endmodule

//--------------------------------------------------------------------

module aludec (input logic[5:0] funct,
               input logic[1:0] aluop,
               output logic[2:0] alucontrol);
always_comb
    case(aluop)
    2'b00: alucontrol = 3'b010; // add (for lw/sw/addi)
    2'b01: alucontrol = 3'b110; // sub (for beq)
        default: case(funct) // R-TYPE instructions
        6'b100000: alucontrol = 3'b010; // ADD
        6'b100010: alucontrol = 3'b110; // SUB
        6'b100100: alucontrol = 3'b000; // AND
        6'b100101: alucontrol = 3'b001; // OR
        6'b101010: alucontrol = 3'b111; // SLT
        default: alucontrol = 3'bxxx; // ???
        endcase
    endcase
endmodule

//--------------------------------------------------------------------

module regfile (input logic clk, we3,
                input logic[4:0] ra1, ra2, wa3,
                input logic[31:0] wd3,
                output logic[31:0] rd1, rd2);
                logic [31:0] rf [31:0];

always_ff @(negedge clk)
    if (we3)
        rf [wa3] <= wd3;
assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;
endmodule

//--------------------------------------------------------------------

module alu(input logic [31:0] a, b,
           input logic [2:0] alucont,
           output logic [31:0] result,
           output logic zero);
always_comb
    case(alucont)
    3'b010: result = a + b;
    3'b110: result = a - b;
    3'b000: result = a & b;
    3'b001: result = a | b;
    3'b111: result = (a < b) ? 1 : 0;
    default: result = {32{1'bx}};
    endcase
assign zero = (result == 0) ? 1'b1 : 1'b0;
endmodule

//--------------------------------------------------------------------

module adder (input logic[31:0] a, b,
              output logic[31:0] y);
assign y = a + b;
endmodule

//--------------------------------------------------------------------

module sl2 (input logic[31:0] a,
            output logic[31:0] y);
assign y = {a[29:0], 2'b00};
endmodule

//--------------------------------------------------------------------

module signext (input logic[15:0] a,
                output logic[31:0] y);
assign y = {{16{a[15]}}, a}; 
endmodule

//--------------------------------------------------------------------

module mux3 #(parameter WIDTH = 8)
(input logic[WIDTH-1:0] d0, d1, d2,
input logic[1:0] s,
output logic[WIDTH-1:0] y);
always_comb
    case(s)
    2'b00: y = d0;
    2'b01: y = d1;
    2'b10: y = d2;
    endcase
endmodule

//--------------------------------------------------------------------

module mux2 #(parameter WIDTH = 8)
(input logic[WIDTH-1:0] d0, d1,
input logic s,
output logic[WIDTH-1:0] y);
assign y = s ? d1 : d0;
endmodule
