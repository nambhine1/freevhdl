library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_decode_first_bit is
  generic (runner_cfg : string);
end entity;

architecture Behavioral of tb_decode_first_bit is

  constant DATA_WIDTH_g : positive := 32;
  constant OUT_WIDTH : integer := clog2(DATA_WIDTH_g);
  constant SPLIT_DATA_g : integer := 4;

  -- DUT signals
  signal clk       : std_logic := '0';
  signal rst       : std_logic := '1';
  signal valid     : std_logic := '0';
  signal data      : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');
  signal out_valid : std_logic;
  signal out_data  : std_logic_vector(OUT_WIDTH - 1 downto 0);
  signal out_found : std_logic;

  constant ZERO_VECTOR : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');

  -- Clock period
  constant clk_period : time := 10 ns;

begin

  uut: entity work.decode_first_bit
    generic map (
      DATA_WIDTH_g => DATA_WIDTH_g,
	  SPLIT_DATA_g => SPLIT_DATA_g
    )
    port map (
      clk       => clk,
      rst       => rst,
      valid     => valid,
      data      => data,
      out_valid => out_valid,
      out_data  => out_data,
      out_found => out_found
    );
	
  -- Clock generation
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    if run("test_all_zero") then
      -- Reset sequence
      rst <= '1'; valid <= '0'; data <= ZERO_VECTOR;
      wait for clk_period * 2;
      rst <= '0'; wait for clk_period;

      -- Test stimulus
      valid <= '1';
      wait for clk_period *2;
      check_equal(out_valid, '1', "out_valid mismatch on all zero");
      check_equal(out_found, '0', "out_found mismatch on all zero");
      check_equal(out_data, std_logic_vector(to_unsigned(0, OUT_WIDTH)), "out_data mismatch on all zero");

    elsif run("test_first_bit_set") then
      rst <= '1'; valid <= '0'; data <= ZERO_VECTOR;
      wait for clk_period * 2;
      rst <= '0'; wait for clk_period;

      data <= (others => '0');
      data(0) <= '1';
      valid <= '1';
      wait for clk_period *2;
      check_equal(out_valid, '1', "out_valid mismatch on first bit set");
      check_equal(out_found, '1', "out_found mismatch on first bit set");
      check_equal(out_data, std_logic_vector(to_unsigned(0, OUT_WIDTH)), "out_data mismatch on first bit set");

    elsif run("test_middle_bit_set") then
      rst <= '1'; valid <= '0'; data <= ZERO_VECTOR;
      wait for clk_period * 2;
      rst <= '0'; wait for clk_period *2;

      data <= (others => '0');
      data(15) <= '1';
      valid <= '1';
      wait for clk_period *2;
      check_equal(out_valid, '1', "out_valid mismatch on middle bit set");
      check_equal(out_found, '1', "out_found mismatch on middle bit set");
      check_equal(out_data, std_logic_vector(to_unsigned(15, OUT_WIDTH)), "out_data mismatch on middle bit set");

    elsif run("test_multiple_bits_set") then
      rst <= '1'; valid <= '0'; data <= ZERO_VECTOR;
      wait for clk_period * 2;
      rst <= '0'; wait for clk_period *2;

      data <= (others => '0');
      data(0) <= '0';
      data(31) <= '1';
      valid <= '1';
      wait for clk_period *2;
      check_equal(out_valid, '1', "out_valid mismatch on multiple bits set");
      check_equal(out_found, '1', "out_found mismatch on multiple bits set");
      check_equal(out_data, std_logic_vector(to_unsigned(31, OUT_WIDTH)), "out_data mismatch on multiple bits set");

    elsif run("test_valid_low") then
      rst <= '1'; valid <= '0'; data <= ZERO_VECTOR;
      wait for clk_period * 2;
      rst <= '0'; wait for clk_period;

      data <= (others => '1');
      valid <= '0';
      wait for clk_period *2;
      check_equal(out_valid, '0', "out_valid mismatch when valid is low");
      check_equal(out_found, '0', "out_found mismatch when valid is low");
      check_equal(out_data, std_logic_vector(to_unsigned(0, OUT_WIDTH)), "out_data mismatch when valid is low");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
