--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

use work.my_instructionSet.all;

package my_programs is
function scrollingChars(constant instructionNum :integer) return instr_array;
function IterativeF(constant instructionNum :integer) return instr_array;
function RekursiveF(constant instructionNum :integer) return instr_array;

-------REG5=return, REG7=stack------------------
constant STACK_PTR : std_logic_vector(2 downto 0) := REG_7;
constant BASE_PTR : std_logic_vector(2 downto 0) := REG_6;
constant RETURN_REG : std_logic_vector(2 downto 0) := REG_5;

constant asmSTORE_RETURN : std_logic_vector(8 downto 0):= opMOV & RETURN_REG;
constant asmPUSH_ON_STACK : std_logic_vector(8 downto 0):= opST & STACK_PTR;
constant asmINC_BASE_PTR : std_logic_vector(14 downto 0):= opINC & BASE_PTR & BASE_PTR & "000";
constant asmDEC_BASE_PTR : std_logic_vector(14 downto 0):= opDEC & BASE_PTR & BASE_PTR & "000";
constant asmINC_STACK_PTR : std_logic_vector(14 downto 0):= opINC & STACK_PTR & STACK_PTR & "000";
constant asmDEC_STACK_PTR : std_logic_vector(14 downto 0):= opDEC & STACK_PTR & STACK_PTR & "000";

constant LAST_INSTR_ADR : std_logic_vector(8 downto 0)    := std_logic_vector(TO_UNSIGNED(9,9)); 
constant FUNCTION_F_ADR : std_logic_vector(8 downto 0)    := std_logic_vector(TO_UNSIGNED(10,9)); 

constant REKUR_F_ADR : std_logic_vector(8 downto 0)       := std_logic_vector(TO_UNSIGNED(14+1,9)); 
constant AFTER_REKUR_F_ADR : std_logic_vector(8 downto 0) := std_logic_vector(TO_UNSIGNED(20+1,9)); 
constant SHIFT_LOOP_ADR : std_logic_vector(8 downto 0)    := std_logic_vector(TO_UNSIGNED(24+1,9)); 
constant RETURN_LOGIC_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(27+1,9)); 
---

constant IS_MAIN_LOOP_ADR : std_logic_vector(8 downto 0)  := std_logic_vector(TO_UNSIGNED(5,9)); 
constant IS_SHIFT_LOOP_ADR : std_logic_vector(8 downto 0) := std_logic_vector(TO_UNSIGNED(7,9)); 
constant IS_LAST_INST_ADR : std_logic_vector(8 downto 0) := std_logic_vector(TO_UNSIGNED(15,9)); 

constant HB_R : std_logic_vector(2 downto 0) := REG_3; --HIGH_BYTE
constant CLP_R : std_logic_vector(2 downto 0) := REG_4;
constant START_HB_R : std_logic_vector(2 downto 0) := REG_5;
constant START_CLP_R : std_logic_vector(2 downto 0) := REG_6;
constant CUR_CHAR_CNT_R : std_logic_vector(2 downto 0) := REG_7;
end my_programs;

package body my_programs is


function scrollingChars(constant instructionNum :integer) return instr_array is
variable indx: integer := 0;

variable waitReadyAdr: integer := 0;
variable characterSend: integer := 0;
variable lastLetterTest: integer := 0;
variable charCountMaxHBIs1: integer := 0;

variable updateCLP_and_HBtoNewStart: integer := 0;

variable Jump_clrChar_ToSendChar: integer := 0;
variable Jump_lowChar_ToSendChar: integer := 0;
variable Jump_LCD_SIZE_equalTo_CHAR_Counter: integer := 0;
variable Jump_HBR_Equal_1: integer := 0;
variable Jump_START_LPis2_RollBack: integer := 0;

variable iarr: instr_array(0 to instructionNum-1);

begin
	iarr := (others => (others => '0'));
	SetReg(START_CLP_R, 2 , true, iarr, indx);
	MovReg(CLP_R, START_CLP_R, iarr, indx);
	DecReg(CUR_CHAR_CNT_R, iarr, indx); --brojac karaktera = -1
	waitReadyAdr:=indx; --------------------------------------------

	SetRegToZero(REG_0, iarr, indx); 
	DecReg(REG_0, iarr, indx); --REG0 je -1 (READY ADR)
	LoadRegFromMemory(REG_0, REG_0, iarr, indx); --u R0 je ready
	JumpIfZero(waitReadyAdr, iarr, indx); --ako nije ready vracamo se nazad
	-----------------------------------------------------------------------------------
	IncReg(CUR_CHAR_CNT_R, iarr, indx);
	
	JumpIfNotZero(indx + 4, iarr, indx); --ako je brojac 0 onda saljemo 1B (clear) na LCD
		LoadRegFromMemory(REG_0, REG_0, iarr, indx); -- u R0 je 1, pa je to adresa od 1B, 
		MovReg(REG_2, REG_0, iarr, indx); --REG2<>0, znaci da posle slanja karaktera se vracamo u waitReadyLoop 
		Jump_clrChar_ToSendChar:=indx; indx := indx+1; --Jump(characterSend, iarr, Jump_clrChar_ToSendChar);
		
	-----------BROJAC NIJE 0, UCITAVA SE ZNAK---------------------------------------------
	LoadRegFromMemory(REG_0, CLP_R, iarr, indx);--<<<<<<<<<<<<<<<<<<<<<indx+4^

	--Inst(opSUB & REG_0 & REG_0 & "000", REG_1, iarr, indx)
	SetRegToZero(REG_2, iarr, indx); --REG_2 = 0 posle slanja znaka neidemo u wait_ready
	
	JumpIfRegNotZero(HB_R, indx + 4, iarr, indx); --ako je HB == 0 onda:
		IncReg(HB_R, iarr, indx); 
		Jump_lowChar_ToSendChar:=indx; indx := indx+1; 
		--Jump(characterSend, iarr, Jump_lowChar_ToSendChar); 
		
	------------SLANJE VISEG BAJTA-------------------------------------------------------

	
	Inst(opINC & REG_1 & HB_R & "000", iarr, indx); 
	SHLReg(REG_1, iarr, indx);
	SHLReg(REG_1, iarr, indx); --REG1 = 8
	
	SetRegToZero(HB_R, iarr, indx);
	IncReg(CLP_R, iarr, indx); 
	
	LoopInstr(opSHR & REG_0 & REG_0 & "000", REG_1, iarr, indx);  -- gornji bajt u donju poziciju
	-------------------------------------------------------------------------------------------
	
	---SLANJE KARAKTERA--
	characterSend:=indx;--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	SendCHARFromReg(REG_0, REG_1, iarr, indx); --u bilo kom slucaju ovde se salje CHAR
	JumpIfRegNotZero(REG_2,  waitReadyAdr, iarr, indx); --ako je REG_2!=0 to znaci da je poslat clr 
	------------------------------------------------------------------------------------------------
	
	------PROVERAVANJE GRANICA------REG2=0-------------------------------------
	
	LoadRegFromMemory(REG_1,REG_2, iarr, indx); -- REG1 <=  LCD_SIZE 
	
	Inst(opINC & REG_0 & REG_2 & "000", iarr, indx); --REG0 = 1 adresa od LAST_LETTER & 1B
	Inst(opINC & REG_2 & REG_0 & "000", iarr, indx); 
	SHLReg(REG_2, iarr, indx);
	SHLReg(REG_2, iarr, indx); --REG2 = 8
	
	
	LoadRegFromMemory(REG_0,REG_0, iarr, indx); -- REG0 <=  LAST_LETTER & 1B	
	LoopInstr(opSHR & REG_0 & REG_0 & "000", REG_2, iarr, indx); --REG_0 <= LAST_LETTER
   --------------------------------------

	Jump_LCD_SIZE_equalTo_CHAR_Counter := indx; indx:=indx+2; --
	--JumpIfNotEqual(REG_1, CUR_CHAR_CNT_R, REG_2, lastLetterTest, iarr, Jump_LCD_SIZE_equalTo_CHAR_Counter);
		Inst(opDEC & CUR_CHAR_CNT_R & REG_2 & "000", iarr, indx);--CUR_CHAR_CNT_R <= -1
		--
		DecReg(START_CLP_R, iarr, indx);
		--
		Jump_HBR_Equal_1:= indx; indx:=indx+2;
		--JumpIfRegNotZero(START_HB_R, charCountMaxHBIs1, iarr, Jump_HBR_Equal_1); --moguce da mora da se startuje od pocetka. 
			IncReg(START_HB_R, iarr, indx); --START_HB_R <= 1
			--Inst(opINC & REG_1 & START_HB_R & "000",  iarr, indx);---
			
			JumpIfNotEqual(START_HB_R, START_CLP_R, REG_2, indx + 6, iarr, indx); --Ako je START_CLP == 1, (znaci da je bilo 2) krecemo od kraja
				MovReg(START_CLP_R, REG_0, iarr, indx); --START_LP <= LAST_LETTER
				Jump_START_LPis2_RollBack:= indx; indx:=indx+1; 
				--Jump(updateCLP_and_HBtoNewStart, iarr, Jump_START_LPis2_RollBack);
	 --else
			charCountMaxHBIs1:=indx;--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
			SetRegToZero(START_HB_R, iarr, indx);
			IncReg(START_CLP_R, iarr, indx);
		 --preskacemo dekrement trenutnog pokazaivaca na karakter (zato sto je hb bio 1)
			
		--<<<<<indx+5^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		

		updateCLP_and_HBtoNewStart := indx;--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		MovReg(CLP_R, START_CLP_R, iarr, indx);
		MovReg(HB_R, START_HB_R, iarr, indx);
		
		Jump(waitReadyAdr, iarr, indx); 
---else

	lastLetterTest:= indx; --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	IncReg(REG_0, iarr, indx); --REG0 <= LAST_LETTER_ADR + 1

	JumpIfNotEqual(REG_0, CLP_R, REG_1, waitReadyAdr, iarr, indx);

	Inst(opINC & CLP_R & REG_1 & "000",  iarr, indx); 
	
	IncReg(CLP_R, iarr, indx); --CLP = 2

	Jump(waitReadyAdr, iarr, indx); 	
	
---Skokovi ka dole-----------------------------------------------------------------------
	Jump(characterSend, iarr, Jump_clrChar_ToSendChar);
	Jump(characterSend, iarr, Jump_lowChar_ToSendChar); 
	JumpIfNotEqual(REG_1, CUR_CHAR_CNT_R, REG_2, lastLetterTest, iarr, Jump_LCD_SIZE_equalTo_CHAR_Counter); 
	JumpIfRegNotZero(START_HB_R, charCountMaxHBIs1, iarr, Jump_HBR_Equal_1);
	Jump(updateCLP_and_HBtoNewStart, iarr, Jump_START_LPis2_RollBack);
----------PROVERA ISPADANJA IZ NIZA SLOVA-------------------
	






---------------------------------------------------------------
	
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
	
return iarr;
end function scrollingChars;




function IterativeF(constant instructionNum :integer) return instr_array is
variable indx: integer := 0;
variable theEnd: integer := 0;
variable mainLoop: integer := 0;
variable iarr: instr_array(0 to instructionNum-1);
begin

iarr := (others => (others => '0'));

LoopInstr(opINC & REG_0 & REG_0 & "000",5,REG_6,iarr,indx);
IncReg(REG_1, iarr,indx);

mainLoop := indx;-----------------------------------------
Inst(opINC & REG_3 & REG_2 & "000",iarr,indx);
MovReg(REG_4 , REG_1, iarr,indx);
LoopInstr(opSHL & REG_3 & REG_3 & "000", REG_4, iarr,indx);

MovReg(REG_2,REG_3,iarr,indx);

JumpIfEqual(REG_0,REG_1,REG_5, indx + 4, iarr,indx);
IncReg(REG_1, iarr,indx);
Jump(mainLoop, iarr,indx);
theEnd := indx;----------------
Jump(theEnd, iarr,indx);

return iarr;
end function IterativeF;

function RekursiveF(constant instructionNum :integer) return instr_array is
variable iarr: instr_array(0 to instructionNum-1);
begin

iarr := (others => (others => '0'));

iarr :=(
------------INICIJALIZACIJA----------------------------------
-----------------smesta se 2 u REG3--------------------------
0 => opINC & REG_2 & REG_2 & "000",
1 => opINC & REG_2 & REG_2 & "000", 
2 to 3 => opINC & REG_0 & REG_0 & "000",
--0 => opINC & REG_2 & REG_2 & "000",
--1 => opINC & REG_2 & REG_2 & "000", 
-----------------smesta se 5 u REG0, to ce biti N------------NAJVECA MOGUCA VREDNOST JE 5 f(5) = 53792
--2 => opINC & REG_0 & REG_0 & "000",
--3 => opINC & REG_0 & REG_0 & "000",



4 => opINC & REG_0 & REG_0 & "000",
5 => opINC & REG_0 & REG_0 & "000",

-------------------------push N na stack---------------------
6 => asmPUSH_ON_STACK & REG_0 & "000",
7 => asmINC_STACK_PTR, --inkrementiranjem STACK_PTR i time implicitno saljemo 0 na stek (na adresu 1), 
--posto gornja lokaceija pre poziva oznacava povratnu, 0 oznacava da je povratna lokacija 
--lokacija posle spoljasnje funkcije (kraj programa), !0 oznacava povratnu lokaciju unutrasnje
--rekurzivne funkcije

-------------------------------------------------------------
8 => opJMP & FUNCTION_F_ADR, -->poziv F
9 => opJMP & LAST_INSTR_ADR, --KONACNA INSTRUKCIJA, MRTVA PETLJA


---------ULAZ U FUNKCIJU F--FUNCTION_F_ADR-------------------
10 => opDEC & REG_3 & STACK_PTR & "000", --privremeni drzac STACK_PTR-1, pokazuje na N
11 => opLD & REG_0 & REG_3 & "000", --u reg0 se nalazi N

12 => opJMPNZ & REKUR_F_ADR, --ako N nije nula poziva se funkcija rekurzivno. else vraca se 0
--else
	13 => asmSTORE_RETURN & REG_0 & "000", --stavlje se nula u RETURN registar
	14 => opJMP & RETURN_LOGIC_ADR, --SKACEMO NA OBRACUN-------
------------------------------------------------
	
-------------------------------------------------------------
---------REKUR_F_ADR---------------rekurzivni poziv F--------
15 => opDEC & REG_0 & REG_0 & "000", --smanjuje se N za 1.---

-------------------------push N-1 na stack------------------
16 => asmINC_STACK_PTR,
17 => asmPUSH_ON_STACK & REG_0 & "000",
18 => asmINC_STACK_PTR,
19 => asmPUSH_ON_STACK & STACK_PTR & "000",  --stavljamo na stek sadrzaj STEK_PTR posto nije 0. 
----------------------------------------------------------
20 => opJMP & FUNCTION_F_ADR, -->poziv F
----------------------------------------------------------
---------------AFTER_REKUR_F_ADR--------------------------
21 => opSUB & STACK_PTR & STACK_PTR & REG_2, --stackPtr-=2
22 => opINC & RETURN_REG & RETURN_REG & "000", --F(N-1) + 1

---------RETURN_REG*2^n-----------------------------------

23 => opDEC & REG_3 & STACK_PTR & "000", --privremeni drzac STACK_PTR-1, pokazuje na N
24 => opLD & REG_0 & REG_3 & "000", --u reg0 se nalazi N

----------------------------------------------------------
------SHIFT_LOOP_ADR--------------------------------------
25 => opSHL & RETURN_REG & RETURN_REG & "000",
26 => opDEC & REG_0 & REG_0 & "000", --smanjuje se N za 1. 
27 => opJMPNZ & SHIFT_LOOP_ADR,
----------------------------------------------------------


----gotovo,vracamo rezultat----RETURN_LOGIC_ADR-----------
28 => opLD & REG_0 & STACK_PTR & "000", --uzimamo povratnu adresu
29 => opJMPZ & LAST_INSTR_ADR,
30 => opJMP & AFTER_REKUR_F_ADR,
others => (others => '0')); 




return iarr;

end function RekursiveF;

 
end my_programs;
