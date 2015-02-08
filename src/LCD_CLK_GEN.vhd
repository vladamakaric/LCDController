----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:19:47 12/17/2013 
-- Design Name: 
-- Module Name:    LCD_CLK_GEN - Behavioral 
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

entity LCD_CLK_GEN is
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           onRST : out  STD_LOGIC;
           oCLK : out  STD_LOGIC);
end LCD_CLK_GEN;

architecture Behavioral of LCD_CLK_GEN is
signal sCLK_DIV : unsigned(7 downto 0);
signal snRST : std_logic;
begin

	process(iCLK, inRST) begin
		if(inRST = '0') then
			sCLK_DIV <= to_unsigned(0, 8);
		elsif(rising_edge(iCLK)) then
			sCLK_DIV <= sCLK_DIV + 1;
		end if;
	end process;

	process(iCLK, inRST, sCLK_DIV) begin
		if(inRST = '0') then
			snRST <= '0';
		elsif(rising_edge(iCLK) and sCLK_DIV(7) = '1') then
			snRST <= '1';
		end if;	
	end process;

	oCLK <= sCLK_DIV(6); --2^7=128, na prvih 64 je 0 na drugih je 1, znaci takt je 24mhz/128 = 187500hz
	onRST <= snRST;
	
end Behavioral;

