----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:33:04 01/19/2014 
-- Design Name: 
-- Module Name:    cpu_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu_top is
GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
			  iINST : in  STD_LOGIC_VECTOR (14 downto 0);
           iDATA : in  STD_LOGIC_VECTOR (n-1 downto 0);
			  -------------------------------------------
           oPC : out  STD_LOGIC_VECTOR (n-1 downto 0);
			  oDATA : out  STD_LOGIC_VECTOR (n-1 downto 0);
			  oADDR : out  STD_LOGIC_VECTOR (n-1 downto 0);
			  oMEM_WE : out  STD_LOGIC
			  ---------------------------------------------
			  );
end cpu_top;

architecture Behavioral of cpu_top is

component alu
	GENERIC ( n: INTEGER := 16  ); 
    Port (   
			  iA : in  STD_LOGIC_VECTOR(n-1 downto 0);
			  iB : in  STD_LOGIC_VECTOR(n-1 downto 0);
			  iSEL : in  STD_LOGIC_VECTOR(3 downto 0);
			  ------------------------------------------
			  oC : out  STD_LOGIC_VECTOR(n-1 downto 0);
			  oZERO : out STD_LOGIC;
			  oSIGN : out STD_LOGIC;
			  oCARRY : out STD_LOGIC);
end component;

component ctrlunit
	GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iZERO : in  STD_LOGIC;
           iSIGN : in  STD_LOGIC;
           iCARRY : in  STD_LOGIC;
			  iIR : in STD_LOGIC_VECTOR (14 downto 0);
			  ------------------------------------------
			  oPC_EN : out  STD_LOGIC;
			  oPC_LOAD : out  STD_LOGIC;
			  oPC_IN : out  STD_LOGIC_VECTOR (n-1 downto 0);
           oREG_WE : out  STD_LOGIC_VECTOR (7 downto 0);
           oA_WE : out  STD_LOGIC;
           oB_WE : out  STD_LOGIC;
           oC_WE : out  STD_LOGIC; 
			  oIR_WE : out  STD_LOGIC; 
           oMUXA_SEL : out  STD_LOGIC_VECTOR (3 downto 0);
           oMUXB_SEL : out  STD_LOGIC_VECTOR (3 downto 0);
           oALU_SEL : out  STD_LOGIC_VECTOR (3 downto 0);
			  oMEM_WE : out  STD_LOGIC
			  -------------------------
			  );
end component;

component mux
	GENERIC ( n: INTEGER := 16  ); 
    Port ( iD0 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD1 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD2 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD3 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD4 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD5 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD6 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD7 : in  STD_LOGIC_VECTOR(n-1 downto 0);
           iD8 : in  STD_LOGIC_VECTOR(n-1 downto 0);
			 
			  iSEL : in STD_LOGIC_VECTOR(3 downto 0);
			  -----------------------------------------
			  oQ : out STD_LOGIC_VECTOR(n-1 downto 0));
end component;

component reg
GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iD : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iWE : in  STD_LOGIC;
           oQ : out  STD_LOGIC_VECTOR (n-1 downto 0));
end component;

COMPONENT cnt
GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iD : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iEN : in  STD_LOGIC;
           iLOAD : in  STD_LOGIC;
           oQ : out  STD_LOGIC_VECTOR (n-1 downto 0));
end COMPONENT;

SIGNAL sZERO, sSIGN, sCARRY :STD_LOGIC;
SIGNAL sALU_ZERO, sALU_SIGN, sALU_CARRY :STD_LOGIC;
SIGNAL sA_WE, sB_WE, sC_WE, sIR_WE, sMEM_WE, sPC_EN, sPC_LOAD :STD_LOGIC;
SIGNAL sMUXA_SEL, sMUXB_SEL, sALU_SEL: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL sREG_WE: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL sIR: STD_LOGIC_VECTOR(14 downto 0);
SIGNAL sR0, sR1, sR2, sR3, sR4, sR5, sR6, sR7, sA, sB, sC, sMUXA, sMUXB, sRESULT, sPC_IN, sPC: STD_LOGIC_VECTOR(n-1 downto 0);
begin

oDATA <= sC;
oPC <= sPC;
oADDR <= sMUXB;
oMEM_WE <= sMEM_WE;


ZSC: process(iCLK, inRST, sC_WE)
begin
	if(inRST = '0') then
		sZERO <= '0';
		sSIGN <= '0';
		sCARRY <= '0';
	elsif (rising_edge(iCLK) and sC_WE = '1') then
		sZERO <= sALU_ZERO;
		sSIGN <= sALU_SIGN;
		sCARRY <= sALU_CARRY;
	end if;
end process;

IR : reg generic map (15) port map(iCLK, inRST, iINST, sIR_WE, sIR);

PC : cnt generic map (n => n) port map(
iCLK => iCLK, 
inRST => inRST, 
iD => sPC_IN, 
iEN => sPC_EN, 
iLOAD => sPC_LOAD, 
oQ => sPC); 

R0 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(0), sR0);
R1 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(1), sR1);
R2 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(2), sR2);
R3 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(3), sR3);
R4 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(4), sR4);
R5 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(5), sR5);
R6 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(6), sR6);
R7 : reg generic map (n => n) port map(iCLK, inRST, sC, sREG_WE(7), sR7);

A : reg generic map (n => n) port map(iCLK, inRST, sMUXA, sA_WE, sA);
B : reg generic map (n => n) port map(iCLK, inRST, sMUXB, sB_WE, sB);
C : reg generic map (n => n) port map(iCLK, inRST, sRESULT, sC_WE, sC);


ALU0 : alu generic map (n => n) port map(
			  iA => sA,
			  iB => sB,
			  iSEL => sALU_SEL, 
			  oC => sRESULT,
			  oZERO => sALU_ZERO, 
			  oSIGN => sALU_SIGN, 
			  oCARRY => sALU_CARRY); 
			  

CONTROLUNIT : ctrlunit generic map (n => n) port map(	  
iCLK => iCLK,
inRST => inRST,
iZERO => sZERO,
iSIGN => sSIGN,
iCARRY => sCARRY,
iIR => sIR,
------------------------------------------
oPC_EN => sPC_EN,
oPC_LOAD => sPC_LOAD,
oPC_IN => sPC_IN,
oREG_WE => sREG_WE,
oA_WE => sA_WE,
oB_WE => sB_WE,
oC_WE => sC_WE,
oIR_WE => sIR_WE,
oMUXA_SEL => sMUXA_SEL,
oMUXB_SEL => sMUXB_SEL,
oALU_SEL => sALU_SEL,
oMEM_WE => sMEM_WE
);
			  

MUXA : mux generic map (n => n) PORT MAP (
sR0, sR1, sR2, sR3, sR4, sR5, sR6, sR7, iDATA, sMUXA_SEL, sMUXA);

MUXB : mux generic map (n => n) PORT MAP (
sR0, sR1, sR2, sR3, sR4, sR5, sR6, sR7, iDATA, sMUXB_SEL, sMUXB);
end Behavioral;

