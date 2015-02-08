
----------------------------------------------------------------------------------
-- Logicko projektovanje racunarskih sistema 1
-- 2011/2012
-- Lab 7
--
-- LCD handler
--
-- author: Ivan Kastelan (ivan.kastelan@rt-rk.com)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.my_LCDOutputUtility.all;
use work.thirdPartyFunctions.all;

entity top_shell is
    Port ( iCLK : in  STD_LOGIC;
           inRST : in  STD_LOGIC;
           iPB : in  STD_LOGIC;
           iSW : in  STD_LOGIC_VECTOR (7 downto 0);
           oLCD_D : out  STD_LOGIC_VECTOR (3 downto 0);
           oLCD_EN : out  STD_LOGIC;
           oLCD_RW : out  STD_LOGIC;
           oLCD_RS : out  STD_LOGIC);
end top_shell;

architecture Behavioral of top_shell is

		component system_top is
		 GENERIC(n: INTEGER := 16; adrBits: INTEGER := 5);
		 Port ( iCLK : in  STD_LOGIC;
				  inRST : in  STD_LOGIC;
				  ------------------------------------------------
				  oPC : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oIR : out  STD_LOGIC_VECTOR (14 downto 0);
				  oPHASE : out STD_LOGIC_VECTOR (1 downto 0);
				  oR0 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR1 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR2 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR3 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR4 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR5 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR6 : out STD_LOGIC_VECTOR (n-1 downto 0);
				  oR7 : out STD_LOGIC_VECTOR (n-1 downto 0)
				  );
		end component;
    
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
    
    component CPU_CLK_GEN is
    port ( iCLK      : in   STD_LOGIC;
          inRST      : in   STD_LOGIC;
          iPB        : in   STD_LOGIC;
          oCLK       : out  STD_LOGIC;
          onRST      : out  STD_LOGIC;
          oCPU_CLK   : out  STD_LOGIC
        );
    end component;
   
    signal sCLK_LCD : std_logic;
    signal sCLK_CPU : std_logic;
    signal snRST : std_logic;
    
    signal sPC : std_logic_vector(15 downto 0);
    signal sIR : std_logic_vector(14 downto 0);
    signal sPHASE : std_logic_vector(1 downto 0);
    signal sR0, sR1, sR2, sR3, sR4, sR5, sR6, sR7 : std_logic_vector(15 downto 0);
    
    signal sLCD_EN : std_logic;
    signal sLCD_DATA : std_logic_vector(7 downto 0);
    signal sREADY : std_logic;
    
    type tSTATES is (WAIT_READY, SEND_CHAR, DELAY);
    signal sSTATE : tSTATES;
    
    signal sMEM : ascii_arr(0 to 32);
    signal sINDEX : std_logic_vector(5 downto 0);
    
    signal sREG_SEL : std_logic_vector(2 downto 0);
    signal sREG_VAL : std_logic_vector(15 downto 0);
	 
	 constant ticksPerHalfSecund: integer := 93750; --93750 za plocu --30 za tb
	 signal s2Counter : integer range 0 to ticksPerHalfSecund-1;
begin

    i_CPU_CLK_GEN : CPU_CLK_GEN port map (
        iCLK       => iCLK,
        inRST      => inRST,
        iPB        => iPB,
        oCLK       => sCLK_LCD,
        onRST      => snRST,
        oCPU_CLK   => sCLK_CPU
    );
    
    i_TOP : system_top port map (
        iCLK    => sCLK_CPU,
        inRST   => snRST,
        oPC     => sPC,
        oIR     => sIR,
        oPHASE  => sPHASE,
        oR0     => sR0,
        oR1     => sR1,
        oR2     => sR2,
        oR3     => sR3,
        oR4     => sR4,
        oR5     => sR5,
        oR6     => sR6,
        oR7     => sR7
    );
    
    i_LCD_DRIVER : LCD_DRIVER port map (
        CLR_IP		=> snRST,
        CLK_IP_DR	=> sCLK_LCD,
        EN_IP		=> sLCD_EN,
        MSG_IPV		=> sLCD_DATA,
        LCD_DAT_OPV	=> oLCD_D,
        LCD_EN_OP	=> oLCD_EN,
        LCD_SEL_OP	=> oLCD_RS,
        LCD_RW_OP	=> oLCD_RW,
        READY 		=> sREADY
    );
    
    -- LCD handler FSM --
    
    process (sCLK_LCD, snRST) begin
        if (snRST = '0') thenl
            sSTATE <= WAIT_READY;
        elsif (sCLK_LCD'event and sCLK_LCD = '1') then
            case (sSTATE) is
                when WAIT_READY =>
                    if (sREADY = '1') then
                        sSTATE <= SEND_CHAR;
                    end if;
                when SEND_CHAR =>
                    if (sREADY = '0') then
                        if (sINDEX = "100000") then
                            sSTATE <= DELAY;
                        else
                            sSTATE <= WAIT_READY;
                        end if;
                    end if;
                when DELAY => --ispisana 32 slova (+ signal za brisanje), ceka se refresh
						if(s2Counter = ticksPerHalfSecund) then --svakih pola sekunde se refreshuje
                    sSTATE <= WAIT_READY;
						end if;
            end case;
        end if;
    end process;



	 process (sCLK_LCD, snRST) begin
			 if (snRST = '0') then
            s2Counter <= 0;
			elsif (sCLK_LCD'event and sCLK_LCD = '1') then
				if(s2Counter /= ticksPerHalfSecund) then
					s2Counter <= s2Counter + 1;
				else
					s2Counter <= 0;
				end if;
			end if;
	 end process;
	 
	 
	 
    process (sCLK_LCD, snRST) begin
        if (snRST = '0') then
            sINDEX <= (others => '0');
        elsif (sCLK_LCD'event and sCLK_LCD = '1') then
            if (sSTATE = SEND_CHAR and sREADY = '0') then
					if(sINDEX = "100000") then
						sINDEX <= (others => '0');
					else
						sINDEX <= sINDEX + 1;
					end if;
            end if;
        end if;
    end process;
    
    sLCD_EN <= '1' when sSTATE = SEND_CHAR else '0';
    sLCD_DATA <= sMEM(conv_integer(sINDEX));
    
    process (sCLK_LCD, snRST) begin
        if (snRST = '0') then
            sMEM <= (0 => x"1B", others => (x"20"));
        elsif (sCLK_LCD'event and sCLK_LCD = '1') then
            if (sSTATE = DELAY) then
					 myLOU_Output(sIR, sMEM);
                sMEM(17) <= x"41"; --A
                sMEM(18) <= HEX_TO_DIGIT(sPC(15 downto 12));
                sMEM(19) <= HEX_TO_DIGIT(sPC(11 downto 8));
                sMEM(20) <= HEX_TO_DIGIT(sPC(7 downto 4));
                sMEM(21) <= HEX_TO_DIGIT(sPC(3 downto 0));
					 sMEM(22) <= x"20";
					 sMEM(23) <= x"46"; --F
					 sMEM(24) <= HEX_TO_DIGIT("00" & sPHASE);
					 sMEM(25) <= x"20";
					 sMEM(26) <= x"52"; --R
					 sMEM(27) <= HEX_TO_DIGIT('0' & sREG_SEL);
					 sMEM(28) <= "00111010"; --:
					 sMEM(29) <= HEX_TO_DIGIT(sREG_VAL(15 downto 12));
					 sMEM(30) <= HEX_TO_DIGIT(sREG_VAL(11 downto 8));
					 sMEM(31) <= HEX_TO_DIGIT(sREG_VAL(7 downto 4));
					 sMEM(32) <= HEX_TO_DIGIT(sREG_VAL(3 downto 0));
            end if;
        end if;
    end process;
    
    sREG_SEL <= "001" when iSW(1) = '1' else
                "010" when iSW(2) = '1' else
                "011" when iSW(3) = '1' else
                "100" when iSW(4) = '1' else
                "101" when iSW(5) = '1' else
                "110" when iSW(6) = '1' else
                "111" when iSW(7) = '1' else
                "001";
    
    sREG_VAL <= sR1 when iSW(1) = '1' else
                sR2 when iSW(2) = '1' else
                sR3 when iSW(3) = '1' else
                sR4 when iSW(4) = '1' else
                sR5 when iSW(5) = '1' else
                sR6 when iSW(6) = '1' else
                sR7 when iSW(7) = '1' else
                sR1;

end Behavioral;
