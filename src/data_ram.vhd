----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:34:36 01/21/2014 
-- Design Name: 
-- Module Name:    data_ram - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_ram is

	GENERIC( n: INTEGER := 16; adrBits: INTEGER := 6);
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iA : in  STD_LOGIC_VECTOR (adrBits-1 downto 0);
           iD : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iWE : in  STD_LOGIC;
           oQ : out  STD_LOGIC_VECTOR (n-1 downto 0));
end data_ram;

architecture Behavioral of data_ram is
type vector_array is array (0 to (2**5)-1) of STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL ram: vector_array;
begin
	process(iCLK, inRST, iA, iD, iWE)
	begin
		if(inRST = '0') then
			ram <= (
			0 => x"0010", --LCD_SIZE: 16
			1 => x"1F1B", --LAST_LETTER: 31
			--------------------V M
			2 => x"6c56",
			3 => x"6461",
			4 => x"6d69",
			5 => x"7269",
			6 => x"4d20",
			7 => x"6b61",
			8 => x"7261",
			9 => x"6369",
			--------------------JMBG
			10 => x"4a20",
			11 => x"424d",
			12 => x"2047",
			13 => x"3931",
			14 => x"3430",
			15 => x"3939",
			16 => x"3833",
			17 => x"3030",
			18 => x"3230",
			19 => x"2033",
			---------------------dr
			20 => x"6164",
			21 => x"7574",
			22 => x"206d",
			23 => x"6f72",
			24 => x"6a64",
			25 => x"6e65",
			26 => x"616a",
			---------------------
			27 => x"3120",
			28 => x"2e39",
			29 => x"2e34",
			30 => x"3339",
			31 => x"2020");
		elsif(rising_edge(iCLK) and iWE = '1' and iA(5)= '0') then
			ram(TO_INTEGER(UNSIGNED(iA))) <= iD;
		end if;
	end process;

	oQ <= ram(TO_INTEGER(UNSIGNED(iA))) when (iA(5) = '0') else (others => 'Z');
end Behavioral;

