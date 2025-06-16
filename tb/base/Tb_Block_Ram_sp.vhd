library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- VUnit
library vunit_lib;
context vunit_lib.vunit_context;

use work.math_utils.all;

entity Block_Ram_tb is
 generic (runner_cfg : string);
end entity;

architecture sim of Block_Ram_tb is

  -- Test parameters
  constant RAM_DEPTH  : integer := 8;
  constant DATA_WIDTH : integer := 8;
  constant ADDR_WIDTH : integer := clog2(RAM_DEPTH);

  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal we    : std_logic := '0';
  signal addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal din   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal dout  : std_logic_vector(DATA_WIDTH - 1 downto 0);

  -- RAM mode under test
  constant RAM_MODE : string := "RBW";  -- change to "WBR" to test the other mode

begin

  -- Instantiate DUT
  DUT: entity work.Block_Ram
    generic map (
      RAM_DEPTH  => RAM_DEPTH,
      DATA_WIDTH => DATA_WIDTH,
      RAM_MODE   => RAM_MODE
    )
    port map (
      clk  => clk,
      rst  => rst,
      we   => we,
      addr => addr,
      din  => din,
      dout => dout
    );

  -- Clock generation
  clk_proc: process
  begin
    wait for 5 ns;
    clk <= not clk;
  end process;

  -- Test process
  main: process
    variable expected : std_logic_vector(DATA_WIDTH - 1 downto 0);
  begin
  
    test_runner_setup(runner, runner_cfg);
		if run ("read memory without write") then 
			addr <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
			din <= x"AB";
			wait for 10 ns;
			check_equal(dout, std_logic_vector(to_unsigned(0, DATA_WIDTH)), "Port A did not read expected data at addr 1.");
		elsif run ("read memory after write value") then 
			we <= '1';
			addr <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
			din <= std_logic_vector(to_unsigned(25, ADDR_WIDTH));
			wait for 10 ns;
			check_equal(dout, std_logic_vector(to_unsigned(25, DATA_WIDTH)), "Port A did not read expected data at addr 1.");
		end if;
	test_runner_cleanup(runner);
  end process ;

end architecture;
