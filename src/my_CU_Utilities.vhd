
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.my_instructionSet.all;
use IEEE.NUMERIC_STD.ALL;

package my_CU_Utilities is

	procedure myIS_Reset (signal oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE : out  STD_LOGIC;
								 signal oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL : out  STD_LOGIC_VECTOR);

	procedure myIS_Decode(signal iIR : in STD_LOGIC_VECTOR;
				signal oA_WE,oB_WE : out  STD_LOGIC;
				signal oMUXA_SEL,oMUXB_SEL : out  STD_LOGIC_VECTOR);
								 
	procedure myIS_Execute(signal iIR : in STD_LOGIC_VECTOR; 
				signal oC_WE : out  STD_LOGIC; 
				signal oALU_SEL : out  STD_LOGIC_VECTOR);
								 
	procedure myIS_WriteBack(signal iIR : in STD_LOGIC_VECTOR;
				signal oPC_EN, oPC_LOAD, oMEM_WE : out  STD_LOGIC;
				signal iZERO, iSIGN, iCARRY : in  STD_LOGIC;
				signal oPC_IN, oREG_WE : out  STD_LOGIC_VECTOR);

	procedure myIS_MUXAB(signal iIR : in STD_LOGIC_VECTOR;
								signal oA_WE, oB_WE : out STD_LOGIC;
								signal oMUXA_SEL, oMUXB_SEL : out STD_LOGIC_VECTOR);
								
	procedure myIS_MUXA(signal iIR : in STD_LOGIC_VECTOR;
								signal oA_WE, oB_WE : out STD_LOGIC;
								signal oMUXA_SEL, oMUXB_SEL : out STD_LOGIC_VECTOR);

	procedure myIS_Jump(signal iIR : in STD_LOGIC_VECTOR;
							  signal oPC_LOAD : out STD_LOGIC;
							  signal oPC_IN,oREG_WE: out  STD_LOGIC_VECTOR);

end my_CU_Utilities;

package body my_CU_Utilities is
procedure myIS_Reset(
SIGNAL oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE : out  STD_LOGIC;
SIGNAL oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL : out  STD_LOGIC_VECTOR) is

begin
	oPC_EN <= '0';
	oPC_LOAD <= '0';
	oPC_IN <= (oPC_IN'RANGE => '0');
   oREG_WE <= (oREG_WE'RANGE => '0');
   oA_WE <= '0';
   oB_WE <= '0';
   oC_WE <= '0';
	oIR_WE <= '0';
   oMUXA_SEL <= (oMUXA_SEL'RANGE => '0');
   --oMUXB_SEL <= (oMUXB_SEL'RANGE => '0');
  	oALU_SEL <= (oALU_SEL'RANGE => '0');
	oMEM_WE <= '0';
end myIS_Reset;

procedure myIS_MUXAB(
signal iIR : in STD_LOGIC_VECTOR;
signal oA_WE, oB_WE : out STD_LOGIC;
signal oMUXA_SEL, oMUXB_SEL : out STD_LOGIC_VECTOR) is

begin
	oMUXA_SEL <= '0' & iIR(5 downto 3);
	oMUXB_SEL <= '0' & iIR(2 downto 0);
	oA_WE <= '1';
	oB_WE <= '1';
end myIS_MUXAB;
							
procedure myIS_MUXA(
signal iIR : in STD_LOGIC_VECTOR;
signal oA_WE, oB_WE : out STD_LOGIC;
signal oMUXA_SEL, oMUXB_SEL : out STD_LOGIC_VECTOR) is 

begin
	oMUXA_SEL <= '0' & iIR(5 downto 3);
	oMUXB_SEL <= (oMUXB_SEL'RANGE => '0');
	oA_WE <= '1';
	oB_WE <= '0';
end myIS_MUXA;

procedure myIS_Decode(
signal iIR : in STD_LOGIC_VECTOR; 
signal oA_WE,oB_WE : out  STD_LOGIC; 
signal oMUXA_SEL,oMUXB_SEL : out  STD_LOGIC_VECTOR) is

CONSTANT operation: STD_LOGIC_VECTOR(5 downto 0) := iIR(14 downto 9);
begin
	case (operation) is 
		when opADD | opSUB | opAND | opOR =>
			myIS_MUXAB(iIR, oA_WE, oB_WE, oMUXA_SEL, oMUXB_SEL);
		when opMOV | opNOT | opINC | opDEC | opSHL | opSHR | opASHL | opASHR  => 
			myIS_MUXA(iIR, oA_WE, oB_WE, oMUXA_SEL, oMUXB_SEL);
		when opLD =>
			oMUXB_SEL <= '0' & iIR(5 downto 3); --drugi registar je adresa sa koje se cita
			oMUXA_SEL <= "1000"; --iDATA, procitana vrednost
			oA_WE <= '1';
			oB_WE <= '0';
		when opST =>
			oMUXB_SEL <= '0' & iIR(8 downto 6); --prvi registar je adresa na koju se pise
			oMUXA_SEL <= '0' & iIR(5 downto 3); --drugi registar je vrednost koja se pise
			oA_WE <= '1';
			oB_WE <= '0';
		when others => --jumpovi nerade nista
			oMUXA_SEL <= (oMUXA_SEL'RANGE => '0');
			oMUXB_SEL <= (oMUXB_SEL'RANGE => '0');
			oA_WE <= '0';
			oB_WE <= '0';
	end case;
end myIS_Decode;


procedure myIS_Execute(
signal iIR : in STD_LOGIC_VECTOR; 
signal oC_WE : out  STD_LOGIC; 
signal oALU_SEL : out  STD_LOGIC_VECTOR) is

CONSTANT operation: STD_LOGIC_VECTOR(5 downto 0) := iIR(14 downto 9);
begin
	oC_WE <= '1';
	case (operation) is 
      when opMOV | opLD  => 
			oALU_SEL <= aoMOV;
		when opST =>
			oALU_SEL <= aoMOV;
		when opADD => 
			oALU_SEL <= aoADD;
      when opSUB =>
			oALU_SEL <= aoSUB;
      when opAND =>
			oALU_SEL <= aoAND;
      when opOR =>
			oALU_SEL <= aoOR;
      when opNOT =>
			oALU_SEL <= aoNOT;
      when opINC =>
			oALU_SEL <= aoINC;
      when opDEC =>
			oALU_SEL <= aoDEC;
      when opSHL =>
			oALU_SEL <= aoSHL;
      when opSHR =>
			oALU_SEL <= aoSHR;
      when opASHL =>
			oALU_SEL <= aoASHL;
      when opASHR =>
			oALU_SEL <= aoASHR;
		when others => --jumpovi nerade nista
			oC_WE <= '0';
   end case;
end myIS_Execute;

procedure myIS_Jump(
signal iIR : in STD_LOGIC_VECTOR;
signal oPC_LOAD : out STD_LOGIC;
signal oPC_IN,oREG_WE: out  STD_LOGIC_VECTOR) is 

begin
	oPC_IN(8 downto 0) <= iIR(8 downto 0);
	oPC_LOAD <= '1';
	oREG_WE <= (oREG_WE'RANGE => '0');
end myIS_Jump;

procedure myIS_WriteBack(
signal iIR : in STD_LOGIC_VECTOR;
signal oPC_EN, oPC_LOAD, oMEM_WE : out  STD_LOGIC;
signal iZERO, iSIGN, iCARRY : in  STD_LOGIC;
signal oPC_IN, oREG_WE : out  STD_LOGIC_VECTOR) is

CONSTANT operation: STD_LOGIC_VECTOR(5 downto 0) := iIR(14 downto 9);
begin
	oPC_EN <= '1';
	oREG_WE <= (oREG_WE'RANGE => '0');
	
	case (operation) is 
		when opJMP =>
			myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE);
		when opJMPZ =>
			if(iZERO = '1') then myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE); end if;
		when opJMPS =>
			if(iSIGN = '1') then myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE); end if;
      when opJMPC =>
			if(iCARRY = '1') then myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE); end if;
      when opJMPNZ =>
			if(iZERO = '0') then myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE); end if;
		when opJMPNS =>
			if(iSIGN = '0') then myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE); end if;
      when opJMPNC =>
			if(iCARRY = '0') then myIS_Jump(iIR, oPC_LOAD, oPC_IN, oREG_WE); end if;		
		when opST =>	
			oMEM_WE <= '1';
      when others => --sve ostale instrukcije pisu u prvi registar
			oREG_WE(TO_INTEGER(unsigned(iIR(8 downto 6)))) <= '1';
   end case;
end myIS_WriteBack;

end my_CU_Utilities;
