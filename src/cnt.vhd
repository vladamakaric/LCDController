----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:24 01/21/2014 
-- Design Name: 
-- Module Name:    cnt - Behavioral 
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

entity cnt is
GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iD : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iEN : in  STD_LOGIC;
           iLOAD : in  STD_LOGIC;
           oQ : out  STD_LOGIC_VECTOR (n-1 downto 0));
end cnt;

architecture Behavioral of cnt is
SIGNAL sCounter: UNSIGNED(n-1 downto 0);
begin

process(iCLK, inRST, iEN, iLOAD, iD) 
begin
	if(inRST = '0') then
		sCounter <= (others => '0');
	elsif(rising_edge(iCLK) and iEN = '1') then 
		if(iLOAD = '1') then
			sCounter <= unsigned(iD);
		else
			sCounter <= sCounter + 1;
		end if;
	end if;
end process;

oQ <= std_logic_vector(sCounter);

end Behavioral;

