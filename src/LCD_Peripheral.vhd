----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:49:40 01/28/2014 
-- Design Name: 
-- Module Name:    LCD_Peripheral - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity LCD_Peripheral is
	GENERIC (n: INTEGER := 16; adrBits: INTEGER := 6 ); 
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

end LCD_Peripheral;

architecture Behavioral of LCD_Peripheral is


	
    component LCD_DRIVER is
    generic (WIDTH : NATURAL := 4;
            WIDTH_DISPLAY	 : integer := 16;
            WIDTH_OUTSIDE: integer:= 8;
            SIMULATION : boolean:= FALSE
            ); 
   
    port
    (
        CLR_IP		: in  STD_LOGIC;
        CLK_IP_DR	: in  STD_LOGIC; -- Running at 187500 kHz
        EN_IP			: in  STD_LOGIC; -- Detect if there is any incoming message
        MSG_IPV		: in  STD_LOGIC_VECTOR(WIDTH_OUTSIDE-1 downto 0); -- Message from outside
        LCD_DAT_OPV	: out STD_LOGIC_VECTOR(WIDTH-1 downto 0); -- LCD Data Bus Line
        LCD_EN_OP	: out STD_LOGIC; -- LCD Enable
        LCD_SEL_OP	: out STD_LOGIC; -- LCD Regiser Select
        LCD_RW_OP	: out STD_LOGIC;  -- LCD Data Read/Write
        READY 		: out std_logic 
    );
    end component;
	

signal sCHAR: std_logic_vector(7 downto 0);
signal sLCD_EN, sREADY: std_logic;
signal sTickCounter: integer;
constant MAX_PAUSE_TICKS: integer := 187500/2-1;

signal sRefreshPause: std_logic;
begin

i_LCD_DRIVER : LCD_DRIVER port map (
	CLR_IP		=> inRST,
	CLK_IP_DR	=> iCLK,
	EN_IP		=> sLCD_EN,
	MSG_IPV		=> sCHAR, --
	LCD_DAT_OPV	=> oLCD_D,
	LCD_EN_OP	=> oLCD_EN,
	LCD_SEL_OP	=> oLCD_RS,
	LCD_RW_OP	=> oLCD_RW,
	READY 		=> sREADY
);

oDATA <= (0 => sREADY, others=> '0') when (iADR = READY_ADR and sRefreshPause = '0') else 
			(others=> '0') when(iADR = READY_ADR and sRefreshPause = '1') else 
			(others=> 'Z');

process(iCLK, inRST) begin
	if(inRST = '0') then
		sTickCounter <= 0;
	elsif(rising_edge(iCLK)) then
		if(sRefreshPause = '1') then
			sTickCounter <= sTickCounter + 1;
		else
			sTickCounter <= 0;
		end if;
	end if;
end process;

process(iCLK, inRST, sREADY) begin
	if(inRST =  '0' or sREADY = '0') then
		sLCD_EN <= '0';
	elsif(rising_edge(iCLK)) then
		if((iADR = CHAR_ADR and iWE = '1' and iDATA(7 downto 0) /= x"1B") or (sTickCounter = MAX_PAUSE_TICKS)) then
			sLCD_EN <= '1';
		end if;			
	end if;
end process;

process(iCLK, inRST) begin
	if(inRST =  '0') then
		sCHAR <= x"1B";
		sRefreshPause <= '0';
	elsif(rising_edge(iCLK)) then
		if(iADR = CHAR_ADR and iWE = '1') then
			if(iDATA(7 downto 0) = x"1B") then
				sRefreshPause <= '1';
			else
				sCHAR <= iDATA(7 downto 0);
			end if;
		end if;
		
		if(sTickCounter = MAX_PAUSE_TICKS) then
			sRefreshPause <= '0';
			sCHAR <= x"1B";
		end if;
	end if;
end process;

end Behavioral;

