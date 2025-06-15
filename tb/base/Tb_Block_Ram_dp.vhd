library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_Block_Ram_dp is
  generic (runner_cfg : string);
end entity;

architecture Behavioral of tb_Block_Ram_dp is

  constant DATA_WIDTH : integer := 32;
  constant RAM_DEPTH  : integer := 32;

  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';

  signal we_A   : std_logic := '0';
  signal add_A  : std_logic_vector(clog2(RAM_DEPTH)-1 downto 0) := (others => '0');
  signal din_A  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal dout_A : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal we_B   : std_logic := '0';
  signal add_B  : std_logic_vector(clog2(RAM_DEPTH)-1 downto 0) := (others => '0');
  signal din_B  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal dout_B : std_logic_vector(DATA_WIDTH-1 downto 0);

  constant CLK_PERIOD : time := 10 ns;

begin

  -- Clock generation
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- DUT instantiation
  DUT: entity work.Block_Ram_dp
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      RAM_DEPTH  => RAM_DEPTH
    )
    port map (
      clk    => clk,
      rst    => rst,
      we_A   => we_A,
      add_A  => add_A,
      din_A  => din_A,
      dout_A => dout_A,
      we_B   => we_B,
      add_B  => add_B,
      din_B  => din_B,
      dout_B => dout_B
    );

  -- Test process
  main : process
    variable runner : vunit_lib.test_runner_t;
  begin
    test_runner_setup(runner, runner_cfg);

    ----------------------------------------------------------------------
    if run("write_and_read_separate_addresses") then
      -- Reset
      rst <= '1';
      wait for CLK_PERIOD * 2;
      rst <= '0';
      wait for CLK_PERIOD;

      -- Write to address 1 and 2 simultaneously
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(1, add_A'length)); din_A <= x"AAAAAAAA";
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(2, add_B'length)); din_B <= x"55555555";
      wait for CLK_PERIOD;

      -- Disable write and wait for output
      we_A <= '0'; we_B <= '0';
      wait for CLK_PERIOD;

      -- Check values read back
      check_equal(dout_A, std_logic_vector(to_unsigned(16#AAAAAAAA#, DATA_WIDTH)), "Port A did not read expected data at addr 1.");
      check_equal(dout_B, std_logic_vector(to_unsigned(16#55555555#, DATA_WIDTH)), "Port B did not read expected data at addr 2.");

    ----------------------------------------------------------------------
    elsif run("simultaneous_write_collision_same_address") then
      -- Reset
      rst <= '1';
      wait for CLK_PERIOD * 2;
      rst <= '0';
      wait for CLK_PERIOD;

      -- Write different values to the SAME address on both ports simultaneously
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(3, add_A'length)); din_A <= x"12345678";
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(3, add_B'length)); din_B <= x"87654321";
      wait for CLK_PERIOD;

      -- Disable write and wait for output
      we_A <= '0'; we_B <= '0';
      wait for CLK_PERIOD;

      -- Port A has priority, so both should read Port A data
      check_equal(dout_A, std_logic_vector(to_unsigned(16#12345678#, DATA_WIDTH)), "Port A read incorrect data after write collision at addr 3.");
      check_equal(dout_B, std_logic_vector(to_unsigned(16#12345678#, DATA_WIDTH)), "Port B read incorrect data after write collision at addr 3.");

    ----------------------------------------------------------------------
    elsif run("read_uninitialized_address") then
      -- Reset
      rst <= '1';
      wait for CLK_PERIOD * 2;
      rst <= '0';
      wait for CLK_PERIOD;

      -- Read from address never written to (e.g., 5)
      add_A <= std_logic_vector(to_unsigned(5, add_A'length));
      we_A <= '0';
      wait for CLK_PERIOD;

      -- Expect zeros (RAM initialized to zero)
      check_equal(dout_A, (others => '0'), "Port A read non-zero from uninitialized addr 5.");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
