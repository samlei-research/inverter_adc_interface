-- (C) 2021 Samuel Leitenmaier (University of Applied Sciences Augsburg/Starkstrom Augsburg)

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

library work;


entity NCD98010_TB is
end NCD98010_TB;

-- Behavioural testbench architecture
architecture BEHAVIORAL of NCD98010_TB is

-- Component declaration
component ncd98010_master
	port(
		clk_i                                : in std_logic;
		rst_n                                : in std_logic;
		cs_n                                 : out std_logic;
		sclk                                 : out std_logic;
		data0_in                             : in std_logic;
		data1_in                             : in std_logic;
		data2_in                             : in std_logic;
		data3_in                             : in std_logic;
		data4_in                             : in std_logic;
		data5_in                             : in std_logic;
		data6_in                             : in std_logic;
		data7_in                             : in std_logic;
		data8_in                             : in std_logic;
		data9_in                             : in std_logic;
		adc0_out                             : out std_logic_vector(12-1 downto 0); 
		adc0_data_valid                      : out std_logic;
		adc1_out                             : out std_logic_vector(12-1 downto 0); 
		adc1_data_valid                      : out std_logic;
		adc2_out                             : out std_logic_vector(12-1 downto 0); 
		adc2_data_valid                      : out std_logic;
		adc3_out                             : out std_logic_vector(12-1 downto 0); 
		adc3_data_valid                      : out std_logic;
		adc4_out                             : out std_logic_vector(12-1 downto 0); 
		adc4_data_valid                      : out std_logic;
		adc5_out                             : out std_logic_vector(12-1 downto 0); 
		adc5_data_valid                      : out std_logic;
		adc6_out                             : out std_logic_vector(12-1 downto 0); 
		adc6_data_valid                      : out std_logic;
		adc7_out                             : out std_logic_vector(12-1 downto 0); 
		adc7_data_valid                      : out std_logic;
		adc8_out                             : out std_logic_vector(12-1 downto 0); 
		adc8_data_valid                      : out std_logic;
		adc9_out                             : out std_logic_vector(12-1 downto 0); 
		adc9_data_valid                      : out std_logic
	);
end component;

-- Clock period
constant period: time := 50000 ps; -- 1 / 32 MHz

-- Signals
signal clk, rst, sim_csn, sim_sclk, input_clk: std_logic;
signal sim_data0_in, sim0_adc0_data_valid: std_logic;
signal sim_data1_in, sim0_adc1_data_valid: std_logic;
signal sim_data2_in, sim0_adc2_data_valid: std_logic;
signal sim_data3_in, sim0_adc3_data_valid: std_logic;
signal sim_data4_in, sim0_adc4_data_valid: std_logic;
signal sim_data5_in, sim0_adc5_data_valid: std_logic;
signal sim_data6_in, sim0_adc6_data_valid: std_logic;
signal sim_data7_in, sim0_adc7_data_valid: std_logic;
signal sim_data8_in, sim0_adc8_data_valid: std_logic;
signal sim_data9_in, sim0_adc9_data_valid: std_logic;
signal sim_adc0_out: std_logic_vector(12-1 downto 0);
signal sim_adc1_out: std_logic_vector(12-1 downto 0);
signal sim_adc2_out: std_logic_vector(12-1 downto 0);
signal sim_adc3_out: std_logic_vector(12-1 downto 0);
signal sim_adc4_out: std_logic_vector(12-1 downto 0);
signal sim_adc5_out: std_logic_vector(12-1 downto 0);
signal sim_adc6_out: std_logic_vector(12-1 downto 0);
signal sim_adc7_out: std_logic_vector(12-1 downto 0);
signal sim_adc8_out: std_logic_vector(12-1 downto 0);
signal sim_adc9_out: std_logic_vector(12-1 downto 0);

signal simulated_analog_value: std_logic_vector(12-1 downto 0) := "110010011110"; -- value: 3230
signal index_count: integer := 11;

begin

  -- Instantiate master to read adc chips
  u_ncd98010_master : ncd98010_master port map (	
    clk_i   		=> clk,       
	rst_n   		=> rst,       
	cs_n    		=> sim_csn,             
	sclk    		=> sim_sclk,     
	data0_in 		=> sim_data0_in,   
	data1_in 		=> sim_data1_in,   
	data2_in 		=> sim_data2_in,   
	data3_in 		=> sim_data3_in,   
	data4_in 		=> sim_data4_in,   
	data5_in 		=> sim_data5_in,   
	data6_in 		=> sim_data6_in,   
	data7_in 		=> sim_data7_in,   
	data8_in 		=> sim_data8_in,   
	data9_in 		=> sim_data9_in,   
	adc0_out		=> sim_adc0_out,    
	adc0_data_valid => sim0_adc0_data_valid,
	adc1_out		=> sim_adc1_out,    
	adc1_data_valid => sim0_adc1_data_valid,
	adc2_out		=> sim_adc2_out,    
	adc2_data_valid => sim0_adc2_data_valid,
	adc3_out		=> sim_adc3_out,    
	adc3_data_valid => sim0_adc3_data_valid,
	adc4_out		=> sim_adc4_out,    
	adc4_data_valid => sim0_adc4_data_valid,
	adc5_out		=> sim_adc5_out,    
	adc5_data_valid => sim0_adc5_data_valid,
	adc6_out		=> sim_adc6_out,    
	adc6_data_valid => sim0_adc6_data_valid,
	adc7_out		=> sim_adc7_out,    
	adc7_data_valid => sim0_adc7_data_valid,
	adc8_out		=> sim_adc8_out,    
	adc8_data_valid => sim0_adc8_data_valid,
	adc9_out		=> sim_adc9_out,    
	adc9_data_valid => sim0_adc9_data_valid
  );

  -- Process for applying patterns
  process

    -- Helper procedure to perform one clock cycle...
    procedure sim_run_cycle is
    begin
   	  clk <= '0';
      wait for period / 2;
      clk <= '1';
      wait for period / 2;
    end procedure;

  begin

  	sim_run_cycle;
  	rst <= '0';
  	sim_run_cycle;
  	rst <= '1'; -- -> RST is low active
  	for n in 1 to 2 loop
  		for j in 1 to 16 loop
			sim_run_cycle;
			sim_data0_in <= simulated_analog_value(index_count);
			sim_data1_in <= simulated_analog_value(index_count);
			sim_data2_in <= simulated_analog_value(index_count);
			sim_data3_in <= simulated_analog_value(index_count);
			sim_data4_in <= simulated_analog_value(index_count);
			sim_data5_in <= simulated_analog_value(index_count);
			sim_data6_in <= simulated_analog_value(index_count);
			sim_data7_in <= simulated_analog_value(index_count);
			sim_data8_in <= simulated_analog_value(index_count);
			sim_data9_in <= simulated_analog_value(index_count);
			if(j > 1) and (j < 14) then
				if(index_count < 1) then
					index_count <= 11;
				else
					index_count <= index_count - 1;
				end if;
			end if;
		end loop;
		simulated_analog_value <= "101010101010";
	end loop;
	rst <= '0';


   -- Print when simualtion is finisheds
   assert false report "Simulation finished" severity note;
   wait;

  end process;
  
end BEHAVIORAL;

