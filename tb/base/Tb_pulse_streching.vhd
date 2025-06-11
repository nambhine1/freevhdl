library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Streching_pulse is
end tb_Streching_pulse;

architecture behavior of tb_Streching_pulse is

  -- Component Declaration for the Unit Under Test (UUT)
  component Streching_pulse is
    generic (
      COUNTER_STRETCH : integer := 5
    );
    Port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      Data_in   : in  std_logic;
      Data_out  : out std_logic
    );
  end component;

  -- Signals for driving the UUT
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '0';
  signal Data_in  : std_logic := '0';
  signal Data_out : std_logic;

  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: Streching_pulse
  generic map (
    COUNTER_STRETCH => 8
  )
  port map (
    clk      => clk,
    rst      => rst,
    Data_in  => Data_in,
    Data_out => Data_out
  );


  -- Clock process definition
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    -- Initialize inputs
    rst <= '1';
    wait for 2 * clk_period;
    rst <= '0';

    -- Test case 1: Single pulse
    wait for 1 * clk_period;
    Data_in <= '1';
    wait for clk_period;
    Data_in <= '0';

    -- Wait for pulse to finish stretching
    wait for 10 * clk_period;

    -- Test case 2: Another pulse before previous stretch ends
    Data_in <= '1';
    wait for clk_period;
    Data_in <= '0';

    wait for 3 * clk_period;
    Data_in <= '1'; -- Inject pulse before stretch expires
    wait for clk_period;
    Data_in <= '0';

    wait for 10 * clk_period;

    -- Test case 3: Multiple fast pulses
    for i in 0 to 2 loop
      Data_in <= '1';
      wait for clk_period;
      Data_in <= '0';
      wait for 2 * clk_period;
    end loop;

    wait for 20 * clk_period;

    -- End simulation
    wait;
  end process;

end behavior;
