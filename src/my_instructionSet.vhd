--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;


package my_instructionSet is

type instr_array is array (integer range <>) of STD_LOGIC_VECTOR(14 downto 0);

--------------------memorijske adrese----------------------------------
constant CHAR_ADR: std_logic_vector(5 downto 0) := "111110";
constant READY_ADR: std_logic_vector(5 downto 0) := "111111";
--------------------------------------------------------------------
-----------------REG CONSTANT-e-------------------------
constant REG_0 : std_logic_vector(2 downto 0):= "000";
constant REG_1 : std_logic_vector(2 downto 0):= "001";
constant REG_2 : std_logic_vector(2 downto 0):= "010";
constant REG_3 : std_logic_vector(2 downto 0):= "011";
constant REG_4 : std_logic_vector(2 downto 0):= "100";
constant REG_5 : std_logic_vector(2 downto 0):= "101";
constant REG_6 : std_logic_vector(2 downto 0):= "110";
constant REG_7 : std_logic_vector(2 downto 0):= "111";
---------------------------------------------------------------
-----------------ISA CONSTANT-e-------------------------
--------------------------------------------------------------
constant opMOV : std_logic_vector(5 downto 0):= "000000";
constant opADD : std_logic_vector(5 downto 0):= "000001";
constant opSUB : std_logic_vector(5 downto 0):= "000010";
constant opAND : std_logic_vector(5 downto 0):= "000011";
constant  opOR : std_logic_vector(5 downto 0):= "000100";
constant opNOT : std_logic_vector(5 downto 0):= "000101";
constant opINC : std_logic_vector(5 downto 0):= "000110";
constant opDEC : std_logic_vector(5 downto 0):= "000111";
constant opSHL : std_logic_vector(5 downto 0):= "001000";
constant opSHR : std_logic_vector(5 downto 0):= "001001";
constant opASHL : std_logic_vector(5 downto 0):= "001010";
constant opASHR : std_logic_vector(5 downto 0):= "001011";
---------------------------------------------------------
constant opJMP : std_logic_vector(5 downto 0):= "010000";
---------------------------------------------------
constant  opJMPZ : std_logic_vector(5 downto 0):= "010001";
constant  opJMPS : std_logic_vector(5 downto 0):= "010010";
constant  opJMPC : std_logic_vector(5 downto 0):= "010011";
constant opJMPNZ : std_logic_vector(5 downto 0):= "010101";
constant opJMPNS : std_logic_vector(5 downto 0):= "010110";
constant opJMPNC : std_logic_vector(5 downto 0):= "010111";
-------------------------------------------------------
constant opLD : std_logic_vector(5 downto 0):= "100000";
constant opST : std_logic_vector(5 downto 0):= "110000";


---------------ALU CONSTANT-e-------------------------------
constant aoMOV : std_logic_vector(3 downto 0):= "0000";
constant aoADD : std_logic_vector(3 downto 0):= "0001";
constant aoSUB : std_logic_vector(3 downto 0):= "0010";
constant aoAND : std_logic_vector(3 downto 0):= "0011";
constant  aoOR : std_logic_vector(3 downto 0):= "0100";
constant aoNOT : std_logic_vector(3 downto 0):= "0101";
constant aoINC : std_logic_vector(3 downto 0):= "0110";
constant aoDEC : std_logic_vector(3 downto 0):= "0111";
constant aoSHL : std_logic_vector(3 downto 0):= "1000";
constant aoSHR : std_logic_vector(3 downto 0):= "1001";
constant aoASHL : std_logic_vector(3 downto 0):= "1010";
constant aoASHR : std_logic_vector(3 downto 0):= "1011";

						 
function Log2( input:integer ) return integer;


procedure LoadRegFromMemory(CONSTANT regDest, regMemAdr: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);

procedure SetReg(CONSTANT reg: in std_logic_vector; CONSTANT N: in integer; CONSTANT isZero: in boolean; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure SendCHARFromReg(CONSTANT reg, spareReg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure Jump(CONSTANT jumpToLocation : in INTEGER; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure JumpIfZero(CONSTANT jumpToLocation : in INTEGER; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure JumpIfNotZero(CONSTANT jumpToLocation : in INTEGER; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure JumpIfRegNotZero(CONSTANT reg: in std_logic_vector; CONSTANT jumpToLocation : in INTEGER; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure JumpIfNotEqual(CONSTANT reg1,reg2,spareReg: in std_logic_vector; CONSTANT jumpToLocation : in INTEGER; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure JumpIfEqual(CONSTANT reg1,reg2,spareReg: in std_logic_vector; CONSTANT jumpToLocation : in INTEGER; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure MovReg(CONSTANT regDest, regSrc: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure IncReg(CONSTANT reg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure DecReg(CONSTANT reg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure SetRegToMinusOne(CONSTANT reg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure SetRegToZero(CONSTANT reg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure SHLReg(CONSTANT reg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure SHRReg(CONSTANT reg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure LoopInstr(CONSTANT instruction: in std_logic_vector; CONSTANT N: in INTEGER; CONSTANT spareReg: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure LoopInstr(CONSTANT instruction: in std_logic_vector; CONSTANT countReg: in std_logic_vector;VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
procedure Inst(CONSTANT instruction: in std_logic_vector; VARIABLE instructionsArr: inout instr_array; VARIABLE currentIndx: inout INTEGER);
end my_instructionSet;

package body my_instructionSet is


function Log2( input:integer ) return integer is 
 variable temp,log:integer; 
 begin 
  temp:=input; 
  log:=0; 
  while (temp /= 0) loop 
   temp:=temp/2; 
   log:=log+1; 
   end loop; 
   return log; 
  end function log2; 
  
  
procedure Inst(CONSTANT instruction: in std_logic_vector; 
					VARIABLE instructionsArr: inout instr_array; 
					VARIABLE currentIndx: inout INTEGER) is
begin
	instructionsArr := instructionsArr;
	instructionsArr(currentIndx) := instruction;
	currentIndx := currentIndx+1;
end Inst;				
  
						
procedure Jump(CONSTANT jumpToLocation : in INTEGER;
					VARIABLE instructionsArr: inout instr_array;
					VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opJMP & STD_LOGIC_VECTOR(TO_UNSIGNED(jumpToLocation,9)),instructionsArr, currentIndx);
end Jump;

procedure JumpIfNotZero(CONSTANT jumpToLocation : in INTEGER;
								VARIABLE instructionsArr: inout instr_array;
								VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opJMPNZ & STD_LOGIC_VECTOR(TO_UNSIGNED(jumpToLocation,9)), instructionsArr, currentIndx);
end JumpIfNotZero;

procedure JumpIfZero(CONSTANT jumpToLocation : in INTEGER;
							VARIABLE instructionsArr: inout instr_array;
							VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opJMPZ & STD_LOGIC_VECTOR(TO_UNSIGNED(jumpToLocation,9)), instructionsArr, currentIndx);
end JumpIfZero;

procedure JumpIfRegNotZero(CONSTANT reg: in std_logic_vector;
								CONSTANT jumpToLocation : in INTEGER;
								VARIABLE instructionsArr: inout instr_array;
								VARIABLE currentIndx: inout INTEGER) is
begin
	MovReg(reg, reg, instructionsArr, currentIndx);
	JumpIfNotZero(jumpToLocation,instructionsArr,currentIndx);

end JumpIfRegNotZero;


procedure JumpIfNotEqual(CONSTANT reg1,reg2,spareReg: in std_logic_vector;
								CONSTANT jumpToLocation : in INTEGER;
								VARIABLE instructionsArr: inout instr_array;
								VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opSUB & spareReg &  reg1 & reg2, instructionsArr, currentIndx);
	Inst(opJMPNZ & STD_LOGIC_VECTOR(TO_UNSIGNED(jumpToLocation,9)), instructionsArr, currentIndx);
end JumpIfNotEqual;							

procedure JumpIfEqual(CONSTANT reg1,reg2,spareReg: in std_logic_vector;
								CONSTANT jumpToLocation : in INTEGER;
								VARIABLE instructionsArr: inout instr_array;
								VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opSUB & spareReg &  reg1 & reg2 , instructionsArr, currentIndx);
	Inst(opJMPZ & STD_LOGIC_VECTOR(TO_UNSIGNED(jumpToLocation,9)), instructionsArr, currentIndx);
end JumpIfEqual;		


procedure MovReg(CONSTANT regDest, regSrc: in std_logic_vector;
					 VARIABLE instructionsArr: inout instr_array;
					 VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opMOV & regDest & regSrc & "000", instructionsArr, currentIndx);
end MovReg;

procedure IncReg(CONSTANT reg: in std_logic_vector;
					 VARIABLE instructionsArr: inout instr_array;
					 VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opINC & reg & reg & "000", instructionsArr, currentIndx);
end IncReg;

procedure DecReg(CONSTANT reg: in std_logic_vector;
					 VARIABLE instructionsArr: inout instr_array;
					 VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opDec & reg & reg & "000", instructionsArr, currentIndx);
end DecReg;

procedure SetRegToMinusOne(CONSTANT reg: in std_logic_vector;
									VARIABLE instructionsArr: inout instr_array;
									VARIABLE currentIndx: inout INTEGER) is
begin
	SetRegToZero(reg, instructionsArr, currentIndx);
	DecReg(reg, instructionsArr, currentIndx);
end SetRegToMinusOne;


procedure SetRegToZero(CONSTANT reg: in std_logic_vector;
							  VARIABLE instructionsArr: inout instr_array;
							  VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opSUB & reg & reg & reg, instructionsArr, currentIndx);
end SetRegToZero;

procedure SHLReg(CONSTANT reg: in std_logic_vector;
							  VARIABLE instructionsArr: inout instr_array;
							  VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opSHL & reg & reg & "000", instructionsArr, currentIndx);
end SHLReg;

procedure SHRReg(CONSTANT reg: in std_logic_vector;
							  VARIABLE instructionsArr: inout instr_array;
							  VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opSHR & reg & reg & "000", instructionsArr, currentIndx);
end SHRReg;


procedure LoopInstr(CONSTANT instruction: in std_logic_vector; 
						  CONSTANT countReg: in std_logic_vector;
						  VARIABLE instructionsArr: inout instr_array;
						  VARIABLE currentIndx: inout INTEGER) is
constant loopBeginAdr: INTEGER := currentIndx;
begin
	-----loopBeginAdr
	Inst(instruction, instructionsArr, currentIndx);
	DecReg(countReg, instructionsArr, currentIndx);
	JumpIfNotZero(loopBeginAdr, instructionsArr, currentIndx);
end LoopInstr;

procedure SetReg(CONSTANT reg: in std_logic_vector; 
						CONSTANT N: in integer; 
						CONSTANT isZero: in boolean;
						VARIABLE instructionsArr: inout instr_array; 
						VARIABLE currentIndx: inout INTEGER) is
constant bitNumber: INTEGER := Log2(N);
constant binaryN: std_logic_vector(bitNumber-1 downto 0) := std_logic_vector(TO_UNSIGNED(N,bitNumber));
begin
		if(isZero=false)  then
			SetRegToZero(reg, instructionsArr, currentIndx);
		end if;
		
		for I in bitNumber-1 downto 0 loop
			if(binaryN(I)='1') then
				IncReg(reg, instructionsArr, currentIndx);
			end if;
			
			if (I /= 0) then
				SHLReg(reg, instructionsArr, currentIndx);
			end if;
		end loop;
		
end SetReg;

procedure LoopInstr(CONSTANT instruction: in std_logic_vector; 
						  CONSTANT N: in INTEGER;
						  CONSTANT spareReg: in std_logic_vector;
						  VARIABLE instructionsArr: inout instr_array;
						  VARIABLE currentIndx: inout INTEGER) is
begin
	SetReg(spareReg, N, false, instructionsArr, currentIndx);
	LoopInstr(instruction, spareReg, instructionsArr, currentIndx);
end LoopInstr;

procedure SendCHARFromReg(CONSTANT reg, spareReg: in std_logic_vector;
									VARIABLE instructionsArr: inout instr_array;
									VARIABLE currentIndx: inout INTEGER) is
begin
	SetRegToZero(spareReg, instructionsArr, currentIndx);
	DecReg(spareReg, instructionsArr, currentIndx);
	DecReg(spareReg, instructionsArr, currentIndx);
	Inst(opST & spareReg & reg & "000", instructionsArr, currentIndx);
end SendCHARFromReg;

procedure LoadRegFromMemory(CONSTANT regDest, regMemAdr: in std_logic_vector; 
									 VARIABLE instructionsArr: inout instr_array; 
									 VARIABLE currentIndx: inout INTEGER) is
begin
	Inst(opLD & regDest & regMemAdr & "000", instructionsArr, currentIndx);
end LoadRegFromMemory;								 
							

end my_instructionSet;
