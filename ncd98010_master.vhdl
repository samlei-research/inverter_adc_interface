library ieee;
use ieee.std_logic_1164.all;


entity ncd98010_master is
port
(
-- local clock (needs to be max 32 Mhz as input)
clk_i                                : in std_logic;
rst_n                                : in std_logic;
-- data transfer interface
cs_n                                 : out std_logic;
sclk                                 : out std_logic;
data0_in                              : in std_logic;
data1_in                              : in std_logic;
data2_in                              : in std_logic;
data3_in                              : in std_logic;
data4_in                              : in std_logic;
data5_in                              : in std_logic;
data6_in                              : in std_logic;
data7_in                              : in std_logic;
data8_in                              : in std_logic;
data9_in                              : in std_logic;
-- output of all ADCs
adc0_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc0_data_valid                      : out std_logic;
adc1_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc1_data_valid                      : out std_logic;
adc2_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc2_data_valid                      : out std_logic;
adc3_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc3_data_valid                      : out std_logic;
adc4_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc4_data_valid                      : out std_logic;
adc5_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc5_data_valid                      : out std_logic;
adc6_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc6_data_valid                      : out std_logic;
adc7_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc7_data_valid                      : out std_logic;
adc8_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc8_data_valid                      : out std_logic;
adc9_out                             : out std_logic_vector(12-1 downto 0); -- for 12 Bit ADC
adc9_data_valid                      : out std_logic
);

end entity;


architecture ncd98010_master_rtl of ncd98010_master is

constant G_N                          : integer := 12; -- for 12 Bit ADC

-- serial to parallel control
signal r_data_enable0                  : std_logic;
signal r_data0                         : std_logic_vector(G_N-1 downto 0);
signal r_count0                        : integer range 0 to G_N-1;
signal r_data_enable1                  : std_logic;
signal r_data1                         : std_logic_vector(G_N-1 downto 0);
signal r_count1                        : integer range 0 to G_N-1;
signal r_data_enable2                  : std_logic;
signal r_data2                         : std_logic_vector(G_N-1 downto 0);
signal r_count2                        : integer range 0 to G_N-1;
signal r_data_enable3                  : std_logic;
signal r_data3                         : std_logic_vector(G_N-1 downto 0);
signal r_count3                        : integer range 0 to G_N-1;
signal r_data_enable4                  : std_logic;
signal r_data4                         : std_logic_vector(G_N-1 downto 0);
signal r_count4                        : integer range 0 to G_N-1;
signal r_data_enable5                  : std_logic;
signal r_data5                         : std_logic_vector(G_N-1 downto 0);
signal r_count5                        : integer range 0 to G_N-1;
signal r_data_enable6                  : std_logic;
signal r_data6                         : std_logic_vector(G_N-1 downto 0);
signal r_count6                        : integer range 0 to G_N-1;
signal r_data_enable7                  : std_logic;
signal r_data7                         : std_logic_vector(G_N-1 downto 0);
signal r_count7                        : integer range 0 to G_N-1;
signal r_data_enable8                  : std_logic;
signal r_data8                         : std_logic_vector(G_N-1 downto 0);
signal r_count8                        : integer range 0 to G_N-1;
signal r_data_enable9                  : std_logic;
signal r_data9                         : std_logic_vector(G_N-1 downto 0);
signal r_count9                        : integer range 0 to G_N-1;
signal synq_reset                     : std_logic := '0';

-- csn logic control
signal serial_read_enable             : std_logic;
signal sample_count                   : integer := 0;
signal tmp, internal_clk              : std_logic;
signal count: integer:=0;

begin

-- serial clock assignment
sclk <= internal_clk;

-- frequency divider
p_freq_div: process(clk_i, rst_n)
begin
  if falling_edge(clk_i) then
    if(rst_n = '0') then
      tmp <= '1';
      count <= 0;
    end if;
    if(count >= 4) then 
      tmp <= '0';
      count <= 0;
    end if;
  
    if (count = 9) then 
      count <= 0;
      tmp <= '1';
    else
      count <= count + 1;
    end if;

    internal_clk <= tmp;
  end if;

end process;

-- process to set csn
p_csn_control: process(internal_clk, rst_n)
begin
  if falling_edge(internal_clk) then

    if (sample_count > 0) and (sample_count <= 13) then -- 13 clk cycles csn low
      cs_n <= '0';
      if (sample_count > 1) then
        serial_read_enable <= '1';
      end if;
    else
      cs_n <= '1';
      serial_read_enable <= '0';
    end if;

    if(sample_count > 14) then
      sample_count <= 0;
    else
      sample_count <= sample_count + 1;   
    end if;
  
  end if;
end process;

-- serial to parallel process adc 0
p_s2p_adc0: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable0        <= '0';
    r_count0              <= 0;
    r_data0               <= (others=>'0');
    adc0_data_valid         <= '0';
    adc0_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc0_data_valid         <= r_data_enable0;
    if(r_data_enable0='1') then
      adc0_out         <= r_data0;
    end if;
    if(serial_read_enable='1') then -- 
      r_data0         <= r_data0(G_N-2 downto 0) & data0_in;
      if(r_count0>=G_N-1) then
        r_count0        <= 0;
        r_data_enable0  <= '1';
      else
        r_count0        <= r_count0 + 1;
        r_data_enable0  <= '0';
      end if;
    else
      r_data_enable0  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 1
p_s2p_adc1: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable1        <= '0';
    r_count1              <= 0;
    r_data1               <= (others=>'0');
    adc1_data_valid         <= '0';
    adc1_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc1_data_valid         <= r_data_enable1;
    if(r_data_enable1='1') then
      adc1_out         <= r_data1;
    end if;
    if(synq_reset='1') then
      r_count1        <= 0;
      r_data_enable1  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data1         <= r_data1(G_N-2 downto 0) & data1_in;
      if(r_count1>=G_N-1) then
        r_count1        <= 0;
        r_data_enable1  <= '1';
      else
        r_count1        <= r_count1 + 1;
        r_data_enable1  <= '0';
      end if;
    else
      r_data_enable1  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 2
p_s2p_adc2: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable2        <= '0';
    r_count2              <= 0;
    r_data2               <= (others=>'0');
    adc2_data_valid         <= '0';
    adc2_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc2_data_valid         <= r_data_enable2;
    if(r_data_enable2='1') then
      adc2_out         <= r_data2;
    end if;
    if(synq_reset='1') then
      r_count2        <= 0;
      r_data_enable2  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data2         <= r_data2(G_N-2 downto 0) & data2_in;
      if(r_count2>=G_N-1) then
        r_count2        <= 0;
        r_data_enable2  <= '1';
      else
        r_count2        <= r_count2 + 1;
        r_data_enable2  <= '0';
      end if;
    else
      r_data_enable2  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 3
p_s2p_adc3: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable3        <= '0';
    r_count3              <= 0;
    r_data3               <= (others=>'0');
    adc3_data_valid         <= '0';
    adc3_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc3_data_valid         <= r_data_enable3;
    if(r_data_enable3='1') then
      adc3_out         <= r_data3;
    end if;
    if(synq_reset='1') then
      r_count3        <= 0;
      r_data_enable3  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data3         <= r_data3(G_N-2 downto 0) & data3_in;
      if(r_count3>=G_N-1) then
        r_count3        <= 0;
        r_data_enable3  <= '1';
      else
        r_count3        <= r_count3 + 1;
        r_data_enable3  <= '0';
      end if;
    else
      r_data_enable3  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 4
p_s2p_adc4: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable4        <= '0';
    r_count4              <= 0;
    r_data4               <= (others=>'0');
    adc4_data_valid         <= '0';
    adc4_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc4_data_valid         <= r_data_enable4;
    if(r_data_enable4='1') then
      adc4_out         <= r_data4;
    end if;
    if(synq_reset='1') then
      r_count4        <= 0;
      r_data_enable4  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data4         <= r_data4(G_N-2 downto 0) & data4_in;
      if(r_count4>=G_N-1) then
        r_count4        <= 0;
        r_data_enable4  <= '1';
      else
        r_count4        <= r_count4 + 1;
        r_data_enable4  <= '0';
      end if;
    else
      r_data_enable4  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 5
p_s2p_adc5: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable5        <= '0';
    r_count5              <= 0;
    r_data5               <= (others=>'0');
    adc5_data_valid         <= '0';
    adc5_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc5_data_valid         <= r_data_enable5;
    if(r_data_enable5='1') then
      adc5_out         <= r_data5;
    end if;
    if(synq_reset='1') then
      r_count5        <= 0;
      r_data_enable5  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data5         <= r_data5(G_N-2 downto 0) & data5_in;
      if(r_count5>=G_N-1) then
        r_count5        <= 0;
        r_data_enable5  <= '1';
      else
        r_count5        <= r_count5 + 1;
        r_data_enable5  <= '0';
      end if;
    else
      r_data_enable5  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 6
p_s2p_adc6: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable6        <= '0';
    r_count6              <= 0;
    r_data6               <= (others=>'0');
    adc6_data_valid         <= '0';
    adc6_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc6_data_valid         <= r_data_enable6;
    if(r_data_enable6='1') then
      adc6_out         <= r_data6;
    end if;
    if(synq_reset='1') then
      r_count6        <= 0;
      r_data_enable6  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data6         <= r_data6(G_N-2 downto 0) & data6_in;
      if(r_count6>=G_N-1) then
        r_count6        <= 0;
        r_data_enable6  <= '1';
      else
        r_count6        <= r_count6 + 1;
        r_data_enable6  <= '0';
      end if;
    else
      r_data_enable6  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 7
p_s2p_adc7: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable7        <= '0';
    r_count7              <= 0;
    r_data7               <= (others=>'0');
    adc7_data_valid         <= '0';
    adc7_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc7_data_valid         <= r_data_enable7;
    if(r_data_enable7='1') then
      adc7_out         <= r_data7;
    end if;
    if(synq_reset='1') then
      r_count7        <= 0;
      r_data_enable7  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data7         <= r_data7(G_N-2 downto 0) & data7_in;
      if(r_count7>=G_N-1) then
        r_count7        <= 0;
        r_data_enable7  <= '1';
      else
        r_count7        <= r_count7 + 1;
        r_data_enable7  <= '0';
      end if;
    else
      r_data_enable7  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 8
p_s2p_adc8: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable8        <= '0';
    r_count8              <= 0;
    r_data8               <= (others=>'0');
    adc8_data_valid         <= '0';
    adc8_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc8_data_valid         <= r_data_enable8;
    if(r_data_enable8='1') then
      adc8_out         <= r_data8;
    end if;
    if(synq_reset='1') then
      r_count8        <= 0;
      r_data_enable8  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data8         <= r_data8(G_N-2 downto 0) & data8_in;
      if(r_count8>=G_N-1) then
        r_count8        <= 0;
        r_data_enable8  <= '1';
      else
        r_count8        <= r_count8 + 1;
        r_data_enable8  <= '0';
      end if;
    else
      r_data_enable8  <= '0';
    end if;
  end if;

end process;

-- serial to parallel process adc 9
p_s2p_adc9: process(internal_clk, rst_n)
begin
  if(rst_n='0') then
    r_data_enable9        <= '0';
    r_count9              <= 0;
    r_data9               <= (others=>'0');
    adc9_data_valid         <= '0';
    adc9_out               <= (others=>'0');
  elsif(falling_edge(internal_clk)) then               -- falling Edge for cycle detection
    adc9_data_valid         <= r_data_enable9;
    if(r_data_enable9='1') then
      adc9_out         <= r_data9;
    end if;
    if(synq_reset='1') then
      r_count9        <= 0;
      r_data_enable9  <= '0';
    elsif(serial_read_enable='1') then -- 
      r_data9         <= r_data9(G_N-2 downto 0) & data9_in;
      if(r_count9>=G_N-1) then
        r_count9        <= 0;
        r_data_enable9  <= '1';
      else
        r_count9        <= r_count9 + 1;
        r_data_enable9  <= '0';
      end if;
    else
      r_data_enable9  <= '0';
    end if;
  end if;

end process;

end ncd98010_master_rtl; 
