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

  -- Configuration constants
  constant RAM_DEPTH  : integer := 8;
  constant DATA_WIDTH : integer := 8;
  constant ADDR_WIDTH : integer := clog2(RAM_DEPTH);
  constant CLK_PERIOD : time := 10 ns;
  constant RAM_MODE   : string := "RBW";  -- Change to "WBR" to test other mode

  -- Signals
  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal we    : std_logic := '0';
  signal addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(0, ADDR_WIDTH));
  signal din   : std_logic_vector(DATA_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(0, DATA_WIDTH));
  signal dout  : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

  -- DUT instantiation
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
    while true loop
      clk <= '0'; wait for CLK_PERIOD / 2;
      clk <= '1'; wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Test process
  main: process
    variable expected : std_logic_vector(DATA_WIDTH - 1 downto 0);
  begin
    test_runner_setup(runner, runner_cfg);

    -- Reset
    rst <= '1'; wait for 2 * CLK_PERIOD;
    rst <= '0'; wait for CLK_PERIOD;

    if run("read memory without write") then
      addr <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
      wait for CLK_PERIOD;
      check_equal(dout, std_logic_vector(to_unsigned(0, DATA_WIDTH)), "Reading uninitialized memory should return 0");

    elsif run("write and immediate read") then
      addr <= std_logic_vector(to_unsigned(2, ADDR_WIDTH));
      din  <= std_logic_vector(to_unsigned(50, DATA_WIDTH));
      we   <= '1'; wait for CLK_PERIOD;
      we   <= '0'; wait for CLK_PERIOD;
      check_equal(dout, std_logic_vector(to_unsigned(50, DATA_WIDTH)), "Immediate read after write failed");

    elsif run("write all locations and verify") then
      for i in 0 to RAM_DEPTH - 1 loop
        addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
        din  <= std_logic_vector(to_unsigned(i * 10, DATA_WIDTH));
        we   <= '1';
        wait for CLK_PERIOD;
      end loop;
      we <= '0';

      for i in 0 to RAM_DEPTH - 1 loop
        addr <= std_logic_vector(to_unsigned(i, ADDR_WIDTH));
        wait for CLK_PERIOD;
        expected := std_logic_vector(to_unsigned(i * 10, DATA_WIDTH));
        check_equal(dout, expected, "Mismatch at address " & integer'image(i));
      end loop;

    elsif run("overwrite and verify") then
      addr <= std_logic_vector(to_unsigned(3, ADDR_WIDTH));
      din  <= std_logic_vector(to_unsigned(50, DATA_WIDTH)); we <= '1'; wait for CLK_PERIOD;
      din  <= std_logic_vector(to_unsigned(54, DATA_WIDTH)); wait for CLK_PERIOD;
      we   <= '0'; wait for CLK_PERIOD;
      check_equal(dout, std_logic_vector(to_unsigned(54, DATA_WIDTH)), "Overwrite failed at address 3");

    elsif run("write then read with we='0'") then
      addr <= std_logic_vector(to_unsigned(4, ADDR_WIDTH));
      din  <= std_logic_vector(to_unsigned(67, DATA_WIDTH)); we <= '1'; wait for CLK_PERIOD;
      we   <= '0'; wait for CLK_PERIOD;
      addr <= std_logic_vector(to_unsigned(4, ADDR_WIDTH)); wait for CLK_PERIOD;
      check_equal(dout, std_logic_vector(to_unsigned(67, DATA_WIDTH)), "Data lost after WE set to 0");

    elsif run("prevent write when WE=0") then
      addr <= std_logic_vector(to_unsigned(6, ADDR_WIDTH));
      din  <= std_logic_vector(to_unsigned(123, DATA_WIDTH));
      we   <= '0';  -- Intentionally disabled
      wait for CLK_PERIOD;
      addr <= std_logic_vector(to_unsigned(6, ADDR_WIDTH));
      wait for CLK_PERIOD;
      check_equal(dout, std_logic_vector(to_unsigned(0, DATA_WIDTH)), "Data written even though WE=0");

    elsif run("reset clears RAM (if applicable)") then
      addr <= std_logic_vector(to_unsigned(5, ADDR_WIDTH));
      din  <= std_logic_vector(to_unsigned(99, DATA_WIDTH)); we <= '1'; wait for CLK_PERIOD;
      we   <= '0';
      rst  <= '1'; wait for 2 * CLK_PERIOD; rst <= '0'; wait for CLK_PERIOD;
      addr <= std_logic_vector(to_unsigned(5, ADDR_WIDTH)); wait for CLK_PERIOD;
      check_equal(dout, std_logic_vector(to_unsigned(99, DATA_WIDTH)), "RAM not cleared on reset");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end architecture;
