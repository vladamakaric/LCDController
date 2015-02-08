----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:51 01/18/2014 
-- Design Name: 
-- Module Name:    reg - Behavioral 
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

entity reg is
GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iD : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iWE : in  STD_LOGIC;
           oQ : out  STD_LOGIC_VECTOR (n-1 downto 0));
end reg;

architecture Behavioral of reg is
SIGNAL iReg: STD_LOGIC_VECTOR(n-1 downto 0);
begin

process(inRST, iCLK, iD, iWE)
begin
	if(inRST = '0') then
		iReg <= (OTHERS => '0');
	elsif(rising_edge(iCLK) and iWE ='1') then
		iReg <= iD;
	end if;
	
end process;

oQ <= iReg;

end Behavioral;

