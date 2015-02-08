----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:10:20 01/18/2014 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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

entity mux is
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
			  -----------------------------------------
			  iSEL : in STD_LOGIC_VECTOR(3 downto 0);
			  oQ : out STD_LOGIC_VECTOR(n-1 downto 0));
end mux;

architecture Behavioral of mux is

begin
WITH iSEL SELECT
oQ <= iD0 WHEN "0000",
		iD1 WHEN "0001",
		iD2 WHEN "0010",
		iD3 WHEN "0011",
		iD4 WHEN "0100",
		iD5 WHEN "0101",
		iD6 WHEN "0110",
		iD7 WHEN "0111",
		iD8 WHEN OTHERS; 
end Behavioral;

