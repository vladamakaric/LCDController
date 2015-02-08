----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:10:49 01/21/2014 
-- Design Name: 
-- Module Name:    instr_rom - Behavioral 
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
use work.my_programs.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_rom is
	GENERIC ( adrBits: INTEGER := 6); 
    Port ( iA : in  STD_LOGIC_VECTOR (adrBits-1 downto 0);
           oQ : out  STD_LOGIC_VECTOR (14 downto 0));
end instr_rom;

architecture Behavioral of instr_rom is

--CONSTANT rekursiveSolution: instr_array(0 to (2**adrBits)-1) := RekursiveF(2**adrBits);
CONSTANT iterativeSolution: instr_array(0 to (2**adrBits)-1) := scrollingChars(2**adrBits);



constant HB_R : std_logic_vector(2 downto 0) := REG_7; --HIGH_BYTE
constant CLP_R : std_logic_vector(2 downto 0) := REG_6;
constant START_LH_R : std_logic_vector(2 downto 0) := REG_7;
constant START_CLP_R : std_logic_vector(2 downto 0) := REG_6;
constant CUR_CHAR_CNT_R : std_logic_vector(2 downto 0) := REG_6;

constant WAIT_READY_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9)); 
constant SEND_CLEAR_CHAR_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9)); 
constant	SEND_HIGH_BYTE_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9)); 
constant	CHECK_BOUNDS_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9)); 
constant CURCHARCNT_NOTZERO_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9)); 
constant SHIFT_LOOP_ADR1 : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9));  
constant SHIFT_LOOP_ADR2 : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9));  

--CONSTANT movingLetters: instr_array := (
----STARTLP = 1, 
--0 => opINC & START_CLP_R & START_CLP_R & "000",
--0 => opSHL & START_CLP_R & START_CLP_R & "000", --STARTLP = 2
--0 => opMOV & CLP_R & START_CLP_R & "000", --CLP = STARTLP
--0 => opDEC & CUR_CHAR_CNT_R & CUR_CHAR_CNT_R & "000", --CHARCONTER = -1
-------------WAIT_READY_ADR------------------------------
--
--0 => opSUB & REG_0 & REG_0 & REG_0, --REG0 = 0;
--0 => opDEC & REG_0 & REG_0 & "000", --REG0 = -1 (READY_ADR)
--0 => opLD & REG_0 & REG_0 & "000", -- u reg0 je ready signal (koji se nalazi na adresi u R0)
--0 => opJMPZ & WAIT_READY_ADR,
-------------SEND_CLEAR_CHAR_ADR----------------------------------
--0 => opINC & CUR_CHAR_CNT_R & CUR_CHAR_CNT_R & "000", --uvecavamo trenutni brojac ispisanih karaktera
--
--0 => opJMPNZ & CURCHARCNT_NOTZERO_ADR, --ako je 0 izvrsiti sledeci blok: 
--		0 => opSUB & REG_0 & REG_0 & REG_0, 
--		0 => opINC & REG_0 & REG_0 & "000", --REG0 = 1;
--		0 => opLD & REG_0 & REG_0 & "000", --REG0 = 1B;
--		-------------------slanje karaktera iz REG0 u CHAR_ADR--------
--		0 => opSUB & REG_1 & REG_1 & REG_1, 
--		0 => opDEC & REG_1 & REG_1 & "000",
--		0 => opDEC & REG_1 & REG_1 & "000", --REG1 = -2 (CHAR_ADR)
--		0 => opST & REG_1 & REG_0 & "000", --poslat karakter! 
--		----------------------------------------------------
--		0 => opJMP & WAIT_READY_ADR,
------------CURCHARCNT_NOTZERO_ADR--------------------------------
--0 => opMOV & HB_R & HB_R & "000", --propustamo hb kroz alu da vidimo dal je 0
--
--
--0 => opLD & REG_0 & CLP_R & "000", --u svakom slucaju se u REG0 ucitava adresa trenutnog karaktera za ispis (trenutna 2)
--
--0 => opJMPNZ & SEND_HIGH_BYTE_ADR, --ako je HB_R==0, salje se donji karakter:
--		0 => opINC & HB_R & HB_R & "000",   --HB_R<=1
--		-------------------slanje karaktera iz REG0 u CHAR_ADR--------
--		0 => opSUB & REG_1 & REG_1 & REG_1, 
--		0 => opDEC & REG_1 & REG_1 & "000",
--		0 => opDEC & REG_1 & REG_1 & "000", --REG1 = -2 (CHAR_ADR)
--		0 => opST & REG_1 & REG_0 & "000", --poslat karakter! 
--		----------------------------------------------------
--		0 => opJMP & CHECK_BOUNDS_ADR,
--		----------------------------------------------------------
--		
--------SEND_HIGH_BYTE_ADR-----HB_R==1-------------------------------------------
--------------------------------------------------------------------------
--
--0 => opSUB & HB_R & HB_R & HB_R, --HB_R<=1
--0 => opINC & CLP_R & CLP_R & "000", 
-----------------------------------------------
--0 => opINC & REG_1 & HB_R & "000", --REG1 = 2
--0 => opSHL & REG_1 & REG_1 & "000", --REG1 = 4
--0 => opSHL & REG_1 & REG_1 & "000", --REG1 = 8
--
--------SHIFT_LOOP_ADR1
--0 => opSHR & REG_0 & REG_0 & "000",
--0 => opDEC & REG_1 & REG_1 & "000", --brojac shiftovanja
--0 => opJMPNZ & SHIFT_LOOP_ADR1,
--
---------------------slanje karaktera iz REG0 u CHAR_ADR-----------------
--0 => opSUB & REG_1 & REG_1 & REG_1, 
--0 => opDEC & REG_1 & REG_1 & "000",
--0 => opDEC & REG_1 & REG_1 & "000", --REG1 = -2 (CHAR_ADR)
--0 => opST & REG_1 & REG_0 & "000", --poslat karakter! 
------------------------------------------------------
----------------------------------------------------------------------------
--
-------------------CHECK_BOUNDS_ADR---------------------------------
--0 => opSUB & REG_1 & REG_1 & REG_1, 
--0 => opLD & REG_1 & REG_1 & "000", --REG1 <= LCD_SIZE
--0 => function_name(asmINC_BASE_PTR),
--0 => opSUB & REG_2 & REG_2 & REG_2, 
--
-------SHIFT_LOOP_ADRR2-----------------------------------
--0 => opSHR & REG_1 & REG_1 & "000",
--0 => opDEC & REG_2 & REG_2 & "000", --brojac shiftovanja
--0 => opJMPNZ & SHIFT_LOOP_ADR2,
-----------------SEND_CHAR_ADR--------------------------
--
----------------------------------------------------------
--
--		
--others => (others => '0'));



alias rom: instr_array(0 to (2**adrBits)-1 ) is iterativeSolution;

begin
	oQ <= rom(TO_INTEGER(UNSIGNED(iA)));
end Behavioral;