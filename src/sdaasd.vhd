--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:37:49 01/22/2014
-- Design Name:   
-- Module Name:   C:/Users/Vladimir/Desktop/xilix/cpuProjekat/sdaasd.vhd
-- Project Name:  cpuProjekat
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sdaasd IS
END sdaasd;
 
ARCHITECTURE behavior OF sdaasd IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT system_top
    PORT(
         iCLK : IN  std_logic;
         inRST : IN  std_logic
 
        );
    END COMPONENT;
    

   --Inputs
   signal iCLK : std_logic := '0';
   signal inRST : std_logic := '0';


   -- Clock period definitions
   constant iCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: system_top PORT MAP (
          iCLK => iCLK,
          inRST => inRST
        );

   -- Clock process definitions
   iCLK_process :process
   begin
		iCLK <= '0';
		wait for iCLK_period/2;
		iCLK <= '1';
		wait for iCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for iCLK_period*10;
		inRST <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
