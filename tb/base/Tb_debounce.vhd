library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_debounce is
  generic (runner_cfg : string);
end entity;

architecture Behavioral of tb_debounce is

  constant CLOCK_PERIOD : time := 10 ns;
  constant COUNTER_BOUNCE : integer := 10;

  signal clk          : std_logic := '0';
  signal rst          : std_logic := '0';
  signal buton        : std_logic := '0';
  signal buton_stable : std_logic;


begin

  clk_gen : process
  begin
    clk <= '0';
    wait for CLOCK_PERIOD/2;
    clk <= '1';
    wait for CLOCK_PERIOD/2;
  end process;

  uut: entity work.debounce
    generic map (
      counter_bounce => COUNTER_BOUNCE
    )
    port map (
      clk          => clk,
      rst          => rst,
      buton        => buton,
      buton_stable => buton_stable
    );

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    if run("test_reset") then
      rst <= '1';
      buton <= '0';
      wait for 2*CLOCK_PERIOD;
      check_equal(buton_stable, '0', "After reset, buton_stable should be '0'");
      rst <= '0';
      wait for CLOCK_PERIOD;
    end if;

    if run("test_stable_press") then
      rst <= '0';
      buton <= '0';
      wait for CLOCK_PERIOD;
      buton <= '1';
      wait for CLOCK_PERIOD * (COUNTER_BOUNCE + 2);
      check_equal(buton_stable, '1', "Debounce failed to detect stable press");

      buton <= '0';
      wait for CLOCK_PERIOD * (COUNTER_BOUNCE + 2);
      check_equal(buton_stable, '0', "Debounce failed to detect stable release");
    end if;

    if run("test_bounce") then
      rst <= '0';
      buton <= '0';
      wait for CLOCK_PERIOD;

      for i in 0 to COUNTER_BOUNCE - 3 loop
        buton <= not buton;
        wait for CLOCK_PERIOD;
      end loop;

      check_equal(buton_stable, '0', "Debounce incorrectly changed output during bounce");

      buton <= '1';
      wait for CLOCK_PERIOD * (COUNTER_BOUNCE + 1);
      check_equal(buton_stable, '1', "Debounce failed to detect stable press after bounce");
    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
