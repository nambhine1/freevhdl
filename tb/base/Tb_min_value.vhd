library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library vunit_lib;
context vunit_lib.vunit_context;

entity min_value_tb is
  generic (
    runner_cfg : string := ""
  );
end entity;

architecture Behavioral of min_value_tb is

  constant DATA_WIDTH_g      : positive := 32;
  constant NUMBER_IN_DATA_g  : positive := 8;
  constant SPLIT_DATA_NUM_g  : positive := 4;
  constant TOTAL_WIDTH       : integer := NUMBER_IN_DATA_g * DATA_WIDTH_g;

  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal data     : std_logic_vector(TOTAL_WIDTH - 1 downto 0) := (others => '0');
  signal min_data : std_logic_vector(DATA_WIDTH_g - 1 downto 0);

  constant CLK_PERIOD : time := 10 ns;

  type int_array_t is array (0 to NUMBER_IN_DATA_g - 1) of integer;

  -- VUnit runner object
  shared variable runner : runner_t;

begin

  -- DUT instantiation
  uut: entity work.min_value
    generic map (
      DATA_WIDTH_g      => DATA_WIDTH_g,
      NUMBER_IN_DATA_g  => NUMBER_IN_DATA_g,
      SPLIT_DATA_NUM_g  => SPLIT_DATA_NUM_g
    )
    port map (
      clk      => clk,
      rst      => rst,
      data     => data,
      min_data => min_data
    );

  -- Clock process
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Test process
  main : process
    variable input_array  : int_array_t;
    variable packed_data  : std_logic_vector(TOTAL_WIDTH - 1 downto 0);
    variable expected_min : integer;
    variable observed_min : integer;
  begin
    test_runner_setup(runner, runner_cfg);

    -- Reset
    rst <= '1';
    wait for CLK_PERIOD * 2;
    rst <= '0';
    wait for CLK_PERIOD;

    if run("test_case_1") then
      input_array := (12, 5, 20, 30, 7, 3, 15, 9);  -- min = 3
      expected_min := 3;

      for i in 0 to NUMBER_IN_DATA_g - 1 loop
        packed_data((i+1)*DATA_WIDTH_g - 1 downto i*DATA_WIDTH_g) :=
          std_logic_vector(to_unsigned(input_array(i), DATA_WIDTH_g));
      end loop;
      data <= packed_data;

      wait for CLK_PERIOD * 3;

      observed_min := to_integer(unsigned(min_data));
      check_equal(observed_min, expected_min, "Min value mismatch in test_case_1");

    elsif run("test_case_2") then
      input_array := (100, 250, 80, 65, 90, 70, 30, 55); -- min = 30
      expected_min := 30;

      for i in 0 to NUMBER_IN_DATA_g - 1 loop
        packed_data((i+1)*DATA_WIDTH_g - 1 downto i*DATA_WIDTH_g) :=
          std_logic_vector(to_unsigned(input_array(i), DATA_WIDTH_g));
      end loop;
      data <= packed_data;

      wait for CLK_PERIOD * 3;

      observed_min := to_integer(unsigned(min_data));
      check_equal(observed_min, expected_min, "Min value mismatch in test_case_2");

    elsif run("test_case_3") then
      input_array := (42, 42, 42, 42, 42, 42, 42, 42); -- min = 42
      expected_min := 42;

      for i in 0 to NUMBER_IN_DATA_g - 1 loop
        packed_data((i+1)*DATA_WIDTH_g - 1 downto i*DATA_WIDTH_g) :=
          std_logic_vector(to_unsigned(input_array(i), DATA_WIDTH_g));
      end loop;
      data <= packed_data;

      wait for CLK_PERIOD * 3;

      observed_min := to_integer(unsigned(min_data));
      check_equal(observed_min, expected_min, "Min value mismatch in test_case_3");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
