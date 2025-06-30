library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_mux is
  generic (
    runner_cfg : string
  );
end entity;

architecture Behavioral of tb_mux is

  constant DATA_WIDTH     : integer := 8;
  constant NUMBER_INPUT   : integer := 4;
  constant SEL_WIDTH      : integer := clog2(NUMBER_INPUT);

  signal clk       : std_logic := '0';
  signal rst       : std_logic := '0';
  signal sel       : std_logic_vector(SEL_WIDTH - 1 downto 0) := (others => '0');
  signal in_data   : std_logic_vector(NUMBER_INPUT * DATA_WIDTH - 1 downto 0) := (others => '0');
  signal out_data  : std_logic_vector(DATA_WIDTH - 1 downto 0);

  constant CLK_PERIOD : time := 10 ns;

  -- Input values as integers (decimal equivalent of hex)
  constant INPUT0_INT : integer := 17; -- 0x11
  constant INPUT1_INT : integer := 34; -- 0x22
  constant INPUT2_INT : integer := 51; -- 0x33
  constant INPUT3_INT : integer := 68; -- 0x44

begin

  -- DUT instantiation
  uut : entity work.mux
    generic map (
      SYNC_MODE_g     => "SYNC",
      DATA_WIDTH_g    => DATA_WIDTH,
      NUMBER_INPUT_g  => NUMBER_INPUT
    )
    port map (
      clk      => clk,
      rst      => rst,
      in_data  => in_data,
      sel      => sel,
      out_data => out_data
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
  begin
    test_runner_setup(runner, runner_cfg);

    -- Initialize inputs using integer constants converted to std_logic_vector
    in_data(7 downto 0)     <= std_logic_vector(to_unsigned(INPUT0_INT, DATA_WIDTH)); -- Input 0
    in_data(15 downto 8)    <= std_logic_vector(to_unsigned(INPUT1_INT, DATA_WIDTH)); -- Input 1
    in_data(23 downto 16)   <= std_logic_vector(to_unsigned(INPUT2_INT, DATA_WIDTH)); -- Input 2
    in_data(31 downto 24)   <= std_logic_vector(to_unsigned(INPUT3_INT, DATA_WIDTH)); -- Input 3

    -- Reset the design
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';
    wait for CLK_PERIOD;

    if run("test_select_input_0") then
      sel <= std_logic_vector(to_unsigned(0, SEL_WIDTH));
      wait for CLK_PERIOD;
      check_equal(out_data, std_logic_vector(to_unsigned(INPUT0_INT, DATA_WIDTH)), "MUX output mismatch for input 0");

    elsif run("test_select_input_1") then
      sel <= std_logic_vector(to_unsigned(1, SEL_WIDTH));
      wait for CLK_PERIOD;
      check_equal(out_data, std_logic_vector(to_unsigned(INPUT1_INT, DATA_WIDTH)), "MUX output mismatch for input 1");

    elsif run("test_select_input_2") then
      sel <= std_logic_vector(to_unsigned(2, SEL_WIDTH));
      wait for CLK_PERIOD;
      check_equal(out_data, std_logic_vector(to_unsigned(INPUT2_INT, DATA_WIDTH)), "MUX output mismatch for input 2");

    elsif run("test_select_input_3") then
      sel <= std_logic_vector(to_unsigned(3, SEL_WIDTH));
      wait for CLK_PERIOD;
      check_equal(out_data, std_logic_vector(to_unsigned(INPUT3_INT, DATA_WIDTH)), "MUX output mismatch for input 3");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
