----------------------------------------------------------------------
-- Fakultet tehnickih nauka - Novi Sad
-- Katedra za racunarsku tehniku i racunarske komunikacije
-- Laboratorijske vezbe iz predmeta
-- Logicko projektovanje racunarskih sistema 1
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Laboratorijska vezba broj 8
--
-- Naziv modula: CPU_CLK_GEN
-- Autor: Mihajlo Katona E6676 <Mihajlo.Katona@krt.neobee.net>
--
-- Modified: Ivan Kastelan <ivan.kastelan@rt-rk.com>
--   on 23.09.2011 - removed CPU enable signal and switch input
--
-- Opis:
-- Generator takta za procesor na osnovu pritiska tastera
-- Pored toga, generise i takt za LCD displej (za prikaz stanja procesora)
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- ULAZI:
--  iCLK     - takt signal
--  inRST    - asinhroni signal postavljanja u pocetno stanje
--             aktivan na niskom naponskom nivou
--  iSW      - dozvola rada procesora (prekidac)
--  iPB      - tasterski ulaz, takt se generise nakon otpustanja tastera
--
-- IZLAZI:
--  oCLK     - izlazni takt, 187500Hz
--  onRST    - izlazni reset, aktivan na niskom naponskom nivou
--  oCPU_CLK - takt signal prema procesoru generisan nakon otpustanja tastera
--  oCPU_EN  - signal dozvole rada procesora, aktivan ako je prekidac u stanju ON
--
-------------------------------------------------------------------------

library IEEE;
   use IEEE.STD_LOGIC_1164.ALL;
   use IEEE.STD_LOGIC_ARITH.ALL;
   use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CPU_CLK_GEN is
   port ( iCLK       : in   STD_LOGIC;
          inRST      : in   STD_LOGIC;
          iPB        : in   STD_LOGIC;
          oCLK       : out  STD_LOGIC;
          onRST      : out  STD_LOGIC;
          oCPU_CLK   : out  STD_LOGIC
        );
end CPU_CLK_GEN;

architecture beh of CPU_CLK_GEN is

   COMPONENT LCD_CLK_GEN is
      PORT ( iCLK  : in   STD_LOGIC;
             inRST : in   STD_LOGIC;
             oCLK  : out  STD_LOGIC;
             onRST : out  STD_LOGIC
      );
   END COMPONENT;

   -- internal signals
   signal sCLK          : STD_LOGIC := '0'; -- 187500Hz clock signal
   signal snRST         : STD_LOGIC := '0'; -- asynchronous reset aligned with sCLK
   signal rF1           : STD_LOGIC := '0'; -- flip-flop for rising edge detection
   signal rF2           : STD_LOGIC := '0'; -- flip-flop for rising edge detection
   signal sRISING       : STD_LOGIC := '0'; -- signal indicating rising edge
   signal sPB_DEBOUNCED : STD_LOGIC := '0'; -- debounced push button input
   signal sSHIFT_PB     : STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- delay line for push button filtering

begin

   -- generisanje takta i reseta (187500Hz)
   mLCD_CLK_GEN: LCD_CLK_GEN
   PORT MAP (
               iCLK  => iCLK,
               inRST => inRST,
               oCLK  => sCLK,
               onRST => snRST
   );

   -- filtriranje ulaznog tastera
   pDEBOUNCE: PROCESS (sCLK, snRST) BEGIN
      IF (sCLK'event AND sCLK='1') THEN
         sSHIFT_PB(2 DOWNTO 0) <= sSHIFT_PB(3 DOWNTO 1);
         sSHIFT_PB(3) <= iPB;
         IF sSHIFT_PB(3 DOWNTO 0) = "0000" THEN
            sPB_DEBOUNCED <= '0';
         ELSE
            sPB_DEBOUNCED <= '1';
         END IF;
      END IF;
   END PROCESS pDEBOUNCE;

   -- detekcija rastuce ivice
   pR_EDGE: PROCESS (sCLK) BEGIN
      IF (sCLK'event AND sCLK='1') THEN
         rF2 <= rF1;
         rF1 <= sPB_DEBOUNCED;
      END IF;
   END PROCESS pR_EDGE;
   sRISING <= rF1 AND NOT(rF2);

   -- registrovanje izlaza
   pOUT_REGS: PROCESS (sCLK, snRST) BEGIN
      IF (snRST = '0') THEN
         oCPU_CLK <= '0';
      ELSIF (sCLK'event AND sCLK='1') THEN
         oCPU_CLK <= sRISING;
      END IF;
   END PROCESS pOUT_REGS;

   oCLK  <= sCLK;
   onRST <= snRST;

end beh;

