----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:21:32 01/18/2014 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
use work.my_instructionSet.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity alu is
	GENERIC ( n: INTEGER := 16  ); 
    Port (   
			  iA : in  STD_LOGIC_VECTOR(n-1 downto 0);
			  iB : in  STD_LOGIC_VECTOR(n-1 downto 0);
			  iSEL : in  STD_LOGIC_VECTOR(3 downto 0);
			  -----------------------------------------
			  oC : out  STD_LOGIC_VECTOR(n-1 downto 0);
			  oZERO : out STD_LOGIC;
			  oSIGN : out STD_LOGIC;
			  oCARRY : out STD_LOGIC);
end alu;

architecture Behavioral of alu is
SIGNAL sC : STD_LOGIC_VECTOR(n downto 0);
SIGNAL stA,stB : STD_LOGIC_VECTOR(n downto 0);

begin

stA <= '0' & iA;
stB <= '0' & iB;

WITH iSEL SELECT
sC <= stA WHEN aoMOV,
		std_logic_vector(signed(stA) + signed(stB)) WHEN aoADD,
		std_logic_vector(signed(stA) - signed('1' & stB(n-1 downto 0))) WHEN aoSUB,
		(stA and stB) WHEN aoAND,
		(stA or stB) WHEN aoOR,
		not(stA) WHEN aoNOT,
		std_logic_vector( signed(stA) + 1) WHEN aoINC,
		std_logic_vector( signed('1' & stA(n-1 downto 0)) - 1) WHEN aoDEC,
		std_logic_vector(shift_left(unsigned(stA), 1)) WHEN aoSHL,
		std_logic_vector(shift_right(unsigned(stA), 1)) WHEN aoSHR,
		std_logic_vector(shift_left(signed(stA), 1)) WHEN aoASHL,
		std_logic_vector(shift_right(signed(stA), 1)) WHEN OTHERS;
		
oC <= sC(n-1 downto 0);
		

oZERO <= '1' WHEN (sC(n-1 downto 0) = (n-1 downto 0 => '0')) ELSE '0';
oSIGN <= sC(n-1);
oCARRY <=  sC(sC'HIGH) WHEN (iSEL = aoADD) ELSE not(sC(sC'HIGH)) WHEN (iSEL = aoSUB) ELSE iA(iA'HIGH) WHEN (iSEL = aoSHL) ELSE '0';
end Behavioral;

--		sC <= '0' & iA WHEN aoMOV,
--		std_logic_vector( TO_SIGNED( TO_INTEGER( signed(iA)), 17) + TO_SIGNED(TO_INTEGER(signed(iB)), 17)) WHEN aoADD,
--		std_logic_vector( TO_SIGNED( TO_INTEGER( signed(iA)), 17) - TO_SIGNED(TO_INTEGER(signed(iB)), 17)) WHEN aoSUB,
--		'0' & (iA and iB) WHEN aoAND,
--		'0' & (iA or iB) WHEN aoOR,
--		'0' & not(iA) WHEN aoNOT,
--		std_logic_vector( TO_SIGNED(TO_INTEGER(signed(iA)), 17) + 1) WHEN aoINC,
--		std_logic_vector( TO_SIGNED(TO_INTEGER(signed(iA)), 17) - 1) WHEN aoDEC,
--		'0' & std_logic_vector(shift_left(unsigned(iA), 1)) WHEN aoSHL,
--		'0' & std_logic_vector(shift_right(unsigned(iA), 1)) WHEN aoSHR,
--		'0' & std_logic_vector(shift_left(signed(iA), 1)) WHEN aoASHL,
--		'0' & std_logic_vector(shift_right(signed(iA), 1)) WHEN OTHERS;