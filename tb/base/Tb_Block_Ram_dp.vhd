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
  begin
    test_runner_setup(runner, runner_cfg);

    ----------------------------------------------------------------------
    if run("write_and_read_separate_addresses") then
      rst <= '1';
      wait for CLK_PERIOD * 2;
      rst <= '0';
      wait for CLK_PERIOD;

      -- Write to address 1 and 2
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(1, add_A'length)); din_A <= x"AAAAAAAA";
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(2, add_B'length)); din_B <= x"55555555";
      wait for CLK_PERIOD;

      -- Disable write, read back
      we_A <= '0'; we_B <= '0';
      wait for CLK_PERIOD;
      
      check_equal(dout_A, x"AAAAAAAA", "Port A did not read expected data at addr 1.");
      check_equal(dout_B, x"55555555", "Port B did not read expected data at addr 2.");

    ----------------------------------------------------------------------
    elsif run("simultaneous_write_collision_same_address") then
      -- Write different values to the SAME address on both ports simultaneously
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(3, add_A'length)); din_A <= x"12345678";
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(3, add_B'length)); din_B <= x"87654321";
      wait for CLK_PERIOD;

      -- Disable write, read back
      we_A <= '0'; we_B <= '0';
      wait for CLK_PERIOD;

      -- Assuming Port A has priority
      check_equal(dout_A, x"12345678", "Port A read incorrect data after write collision at addr 3.");
      check_equal(dout_B, x"12345678", "Port B read incorrect data after write collision at addr 3.");

    ----------------------------------------------------------------------
    elsif run("read_uninitialized_address") then
      -- Read from address that was never written (e.g., address 5)
      add_A <= std_logic_vector(to_unsigned(5, add_A'length));
      we_A <= '0';
      wait for CLK_PERIOD;

      -- Depending on RAM init, expect 0s (most inferred RAM initializes to zero)
      check_equal(dout_A, x"00000000", "Port A read non-zero from uninitialized addr 5.");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
