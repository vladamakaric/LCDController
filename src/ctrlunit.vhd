----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:18:26 01/19/2014 
-- Design Name: 
-- Module Name:    ctrlunit - Behavioral 
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
use work.my_CU_Utilities.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ctrlunit is
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
			  -----------------------
			  );
end ctrlunit;

architecture Behavioral of ctrlunit is

signal counter : INTEGER RANGE 0 TO 4; 
begin

CNT: process(iCLK, inRST)
begin
	if(inRST = '0') then
		counter <= 0;
	elsif (rising_edge(iCLK)) then
		if(counter = 4) then
			counter <= 1; 
		else
			counter <= counter + 1;
		end if;
	end if;
end process;

OUTPUT: process(iIR, iZERO, iSIGN, iCARRY, counter)
begin
   case (counter) is 
      when 0 => --reset
			oMUXB_SEL <= (others => '0');
			myIS_Reset(oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE,
						  oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL);
      when 1 => --instruction fetch
			oMUXB_SEL <= (others => '0');
			myIS_Reset(oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE,
						  oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL);
			oIR_WE <= '1';
      when 2 =>
		--	oIR_WE <= '0';
			
			myIS_Reset(oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE,
						  oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL);
			myIS_Decode(iIR,oA_WE,oB_WE,oMUXA_SEL,oMUXB_SEL);
      when 3 =>
			myIS_Reset(oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE,
						  oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL);
		
			myIS_Execute(iIR, oC_WE, oALU_SEL);
      when others => --4
			myIS_Reset(oPC_EN,oPC_LOAD,oA_WE,oB_WE,oC_WE,oIR_WE,oMEM_WE,
						  oPC_IN,oREG_WE,oMUXA_SEL,oALU_SEL);
			myIS_WriteBack(iIR,oPC_EN, oPC_LOAD, oMEM_WE,iZERO, iSIGN, iCARRY, oPC_IN, oREG_WE);
   end case;
end process;

end Behavioral;

