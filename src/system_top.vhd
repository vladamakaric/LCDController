----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:06:14 01/22/2014 
-- Design Name: 
-- Module Name:    system_top - Behavioral 
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

entity system_top is
GENERIC(n: INTEGER := 16; adrBits: INTEGER := 6);
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
			  ------------------------------------------
           oLCD_D : out  STD_LOGIC_VECTOR (3 downto 0);
           oLCD_EN : out  STD_LOGIC;
           oLCD_RW : out  STD_LOGIC;
           oLCD_RS : out  STD_LOGIC
			  );
end system_top;

architecture Behavioral of system_top is

COMPONENT cpu_top
GENERIC ( n: INTEGER := 16  ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
			  iINST : in  STD_LOGIC_VECTOR (14 downto 0);
           iDATA : in  STD_LOGIC_VECTOR (n-1 downto 0);
			  ---------------------------------------------
           oPC : out  STD_LOGIC_VECTOR (n-1 downto 0);
			  oDATA : out  STD_LOGIC_VECTOR (n-1 downto 0);
			  oADDR : out  STD_LOGIC_VECTOR (n-1 downto 0);
			  oMEM_WE : out  STD_LOGIC
			  ---------------------------------------------
			  );
end COMPONENT;

COMPONENT data_ram
	GENERIC( n: INTEGER := 16; adrBits: INTEGER := 6);
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iA : in  STD_LOGIC_VECTOR (adrBits-1 downto 0);
           iD : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iWE : in  STD_LOGIC;
			  -------------------------------------------
           oQ : out  STD_LOGIC_VECTOR (n-1 downto 0));
end COMPONENT;

COMPONENT instr_rom
	GENERIC (  adrBits: INTEGER := 6); 
    Port ( iA : in  STD_LOGIC_VECTOR (adrBits-1 downto 0);
	        ----------------------------------------------
           oQ : out  STD_LOGIC_VECTOR (14 downto 0));
end COMPONENT;

COMPONENT LCD_Peripheral is
	GENERIC (n: INTEGER := 16;  adrBits: INTEGER := 6 ); 
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iDATA : in  STD_LOGIC_VECTOR (n-1 downto 0);
           iADR : in  STD_LOGIC_VECTOR (adrBits-1 downto 0);
			  iWE : in STD_LOGIC;
			  ---------------------------------------------
			  oDATA : out  STD_LOGIC_VECTOR (n-1 downto 0);
           oLCD_D : out  STD_LOGIC_VECTOR (3 downto 0);
           oLCD_EN : out  STD_LOGIC;
           oLCD_RW : out  STD_LOGIC;
           oLCD_RS : out  STD_LOGIC
			  );
end COMPONENT;

COMPONENT LCD_CLK_GEN is
	PORT ( iCLK  : in   STD_LOGIC;
			 inRST : in   STD_LOGIC;
			 oCLK  : out  STD_LOGIC;
			 onRST : out  STD_LOGIC
	);
END COMPONENT;

signal sCLK_LCD, snRST: std_logic;
SIGNAL sMEM_WE :STD_LOGIC;
SIGNAL sADDR, sDATA_ST, sDATA_LD, sPC :STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL sINSTR :STD_LOGIC_VECTOR(14 downto 0);
begin


mLCD_CLK_GEN: LCD_CLK_GEN PORT MAP (
	iCLK  => iCLK,
	inRST => inRST,
	oCLK  => sCLK_LCD,
	onRST => snRST
);


CPU : cpu_top generic map (n) port map (
iCLK => sCLK_LCD,
inRST => snRST,
iINST => sINSTR,
iDATA => sDATA_LD,
-------------------------------------------
oPC => sPC,
oDATA => sDATA_ST, 
oADDR => sADDR,
oMEM_WE => sMEM_WE
--------------------
);

LCD_Disp : LCD_Peripheral generic map (adrBits=>adrBits, n=>n) port map (
iCLK => sCLK_LCD,
inRST => snRST,
iDATA => sDATA_ST,
iADR => sADDR(adrBits-1 downto 0),
iWE => sMEM_WE,
---------------------------------------------
oDATA => sDATA_LD,
oLCD_D	=> oLCD_D, -- LCD Data Bus Line
oLCD_EN => oLCD_EN, -- LCD Enable
oLCD_RS => oLCD_RS, -- LCD Regiser Select
oLCD_RW => oLCD_RW  -- LCD Data Read/Write
);

RAM : data_ram generic map (n=>n, adrBits=>adrBits) port map (
iCLK => sCLK_LCD,
inRST => inRST,
iA => sADDR(adrBits-1 downto 0),
iD => sDATA_ST, 
iWE => sMEM_WE,
oQ => sDATA_LD);

ROM : instr_rom generic map (adrBits) port map (
iA => sPC(adrBits-1 downto 0),
oQ => sINSTR);


end Behavioral;

