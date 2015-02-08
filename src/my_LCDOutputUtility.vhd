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

use work.my_instructionSet.all;
use work.thirdPartyFunctions.all;
use IEEE.NUMERIC_STD.ALL;

package my_LCDOutputUtility is




type ascii_arr is array(integer range <>) of std_logic_vector(7 downto 0);


procedure myLOU_Output(signal iIR : in  STD_LOGIC_VECTOR;
							  signal memory : out  ascii_arr);

end my_LCDOutputUtility;

package body my_LCDOutputUtility is



procedure myLOU_Output(signal iIR : in  STD_LOGIC_VECTOR;
							  signal memory : out  ascii_arr) is
							  

constant arrowSymbol: STD_LOGIC_VECTOR(7 downto 0) := "01111111";
constant spaceSymbol: STD_LOGIC_VECTOR(7 downto 0) := x"20";		
constant pcCode: ascii_arr(0 to 1) := (x"50", x"43");				  


alias operation : STD_LOGIC_VECTOR(5 downto 0) is iIR(14 downto 9);

alias r1Code : STD_LOGIC_VECTOR(2 downto 0) is iIR(8 downto 6);
alias r2Code : STD_LOGIC_VECTOR(2 downto 0) is iIR(5 downto 3);
alias r3Code : STD_LOGIC_VECTOR(2 downto 0) is iIR(2 downto 0);

variable opSymbol: STD_LOGIC_VECTOR(7 downto 0); --: +,|,-,&



variable romADRSymbol: ascii_arr(0 to 1);
variable r1Symbol: ascii_arr(0 to 1);
variable r2Symbol: ascii_arr(0 to 1);
variable r3Symbol: ascii_arr(0 to 1);


variable reg1Num: integer range 0 to 7 := TO_INTEGER(unsigned(r1Code)); 
begin

romADRSymbol := (HEX_TO_DIGIT(iIR( 7 downto 4)),HEX_TO_DIGIT(iIR( 3 downto 0)));


memory <= (0 => x"1B", others => spaceSymbol);
--memory <= (x"56",x"56",x"6c",x"61",x"64",x"69",x"6d",x"69",x"72",
--										  x"2d",x"2d",x"2d",x"2d",x"2d",x"2d",x"2d",x"2d",
--										  x"4d",x"61",x"6b",x"61",x"72",x"69",x"63",x"2d",
--										  x"2d",x"2d",x"2d",x"2d",x"2d",x"2d",x"2d",x"2d");
--				


r1Symbol := (x"52",   STD_LOGIC_VECTOR(  TO_UNSIGNED(TO_INTEGER(unsigned(r1Code)),8) + TO_UNSIGNED(48,8) ));
r2Symbol := (x"52",   STD_LOGIC_VECTOR(  TO_UNSIGNED(TO_INTEGER(unsigned(r2Code)),8) + TO_UNSIGNED(48,8) ));
r3Symbol := (x"52",   STD_LOGIC_VECTOR(  TO_UNSIGNED(TO_INTEGER(unsigned(r3Code)),8) + TO_UNSIGNED(48,8) ));
	

	case (operation) is 
		when opADD | opINC => opSymbol := x"2b";
		when opSUB | opDEC => opSymbol := x"2d";
		when opAND => opSymbol := x"26";
		when opOR => opSymbol := x"7c";
		when others => NULL;
	end case;
	

	case (operation) is
		when opMOV =>
			memory(1 to 3) <= ( x"6d",x"6f",x"76");
		when opADD =>
			memory(1 to 3) <= (  x"61",x"64",x"64"  );	
		when opSUB =>
			memory(1 to 3) <= (   x"73",x"75",x"62" );
		when opAND =>
			memory(1 to 3) <= (  x"61",x"6e",x"64"  );	
		when opOR =>
			memory(1 to 2) <= (  x"6f",x"72"  );
		when opNOT =>
			memory(1 to 3) <= (  x"6e",x"6f",x"74"  );	
		when opINC =>
			memory(1 to 3) <= (  x"69",x"6e",x"63"  );
		when opDEC =>
			memory(1 to 3) <= (  x"64",x"65",x"63"  );	
		when opSHL =>
			memory(1 to 3) <= (  x"73",x"68",x"6c"  );
		when opSHR =>
			memory(1 to 3) <= (  x"73",x"68",x"72"  );	
		when opASHL =>
			memory(1 to 4) <= (  x"61",x"73",x"68",x"6c"  );
		when opASHR =>
			memory(1 to 4) <= (  x"61",x"73",x"68",x"72"  );	
		when opJMP =>
			memory(1 to 3) <= (  x"6a",x"6d",x"70"  );
		when opJMPZ =>
			memory(1 to 4) <= (  x"6a",x"6d",x"70",x"7a"  );	
		when opJMPS =>
			memory(1 to 4) <= (  x"6a",x"6d",x"70",x"73"  );
		when opJMPC =>
			memory(1 to 4) <= (  x"6a",x"6d",x"70",x"63"  );	
		when opJMPNZ =>
			memory(1 to 5) <= (  x"6a", x"6d", x"70", x"6e", x"7a"  );	
		when opJMPNS =>
			memory(1 to 5) <= (  x"6a",x"6d",x"70",x"6e",x"73"  );
		when opJMPNC =>
			memory(1 to 5) <= (  x"6a",x"6d",x"70",x"6e",x"63"  );	
		when opLD =>
			memory(1 to 2) <= (  x"6c",x"64"  );
			memory(3) <= spaceSymbol; 
			
			memory(4 to 5) <= r1Symbol;
			
			memory(6) <= arrowSymbol;
			memory(7) <= x"5b";
			memory(8 to 9) <= r2Symbol;
			memory(10) <= x"5d";
		when opST =>
			memory(1 to 2) <= (  x"73",x"74"  );
			memory(3) <= spaceSymbol; 
			memory(4) <= x"5b";
			memory(5 to 6) <= r2Symbol;
			memory(7) <= x"5d";
			memory(8) <= arrowSymbol;
			memory(9 to 10) <= r2Symbol;
		when others => NULL;
	end case;
						
	case (operation) is
		when opADD | opSUB | opAND  | opMOV | opNOT | opINC | opDEC | opSHL | opSHR =>
			memory(4) <= spaceSymbol; 
			memory(5 to 6) <= r1Symbol;
			memory(7) <= arrowSymbol;
			memory(8 to 9) <= r2Symbol;
		when opOR => 
			memory(3) <= spaceSymbol; 
			memory(4 to 5) <= r1Symbol;
			memory(6) <= arrowSymbol;
			memory(7 to 8) <= r2Symbol;
		when opASHL | opASHR => 
			memory(5) <= spaceSymbol; 
			memory(6 to 7) <= r1Symbol;
			memory(8) <= arrowSymbol;
			memory(9 to 10) <= r2Symbol;
		when  opJMP => 
		   memory(4) <= spaceSymbol; 
			memory(5 to 6) <= pcCode;
			memory(7) <= arrowSymbol;
			memory(8 to 9) <= romADRSymbol;
		when opJMPZ | opJMPC | opJMPS => 
			memory(5) <= spaceSymbol; 
			memory(6 to 7) <= pcCode;
			memory(8) <= arrowSymbol;
			memory(9 to 10) <= romADRSymbol;
		when opJMPNS | opJMPNZ | opJMPNC =>
			memory(6) <= spaceSymbol; 
			memory(7 to 8) <= pcCode;
			memory(9) <= arrowSymbol;
			memory(10 to 11) <= romADRSymbol;
		when others => NULL;
	end case;
	
	case (operation) is 
		when opADD | opSUB | opAND =>
			memory(10) <= opSymbol;
			memory(11 to 12) <= r3Symbol;
		when opOR =>
			memory(9) <= opSymbol;
			memory(10 to 11) <= r3Symbol;
		when others => NULL;
	end case;
		  
end myLOU_Output;

end my_LCDOutputUtility;
