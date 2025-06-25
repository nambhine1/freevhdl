library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_debounce is
  generic (runner_cfg : string);
end tb_debounce;

architecture testbench of tb_debounce is
  constant clk_period     : time := 10 ns;
  constant counter_bounce : integer := 4;

  signal clk           : std_logic := '0';
  signal rst           : std_logic := '0';
  signal button        : std_logic := '0';
  signal button_stable : std_logic;

  -- DUT Component Declaration
  component debounce
    generic (
      counter_bounce : integer := 10
    );
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      button        : in  std_logic;
      button_stable : out std_logic
    );
  end component;

begin

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

  -- DUT instantiation
  uut: debounce
    generic map (
      counter_bounce => counter_bounce
    )
    port map (
      clk           => clk,
      rst           => rst,
      button        => button,
      button_stable => button_stable
    );

  -- Test process
  test_proc : process
  begin
    test_runner_setup(runner, runner_cfg);

    if run("reset and initial state") then
      wait for 3 * clk_period;
      rst <= '0';
      wait until rising_edge(clk);
      check_equal(button_stable, '0', "Button should be stable low after reset");

    elsif run("noisy press is ignored") then
      button <= '1';
      wait for clk_period;
      button <= '0';
      wait for clk_period;
      button <= '1';
      wait for clk_period;
      button <= '0';
      wait for clk_period;
      check_equal(button_stable, '0', "Noisy press should not affect output");

    elsif run("stable press is accepted") then
      button <= '1';
      wait for (counter_bounce + 1) * clk_period;
      check_equal(button_stable, '1', "Stable press should set output high");

    elsif run("noisy release is ignored") then
      button <= '0';
      wait for clk_period;
      button <= '1';
      wait for clk_period;
      button <= '0';
      wait for clk_period *5;
      check_equal(button_stable, '0', "Noisy release should not affect output");

    elsif run("stable release is accepted") then
      button <= '0';
      wait for (counter_bounce + 1) * clk_period;
      check_equal(button_stable, '0', "Stable release should set output low");
    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end architecture;
