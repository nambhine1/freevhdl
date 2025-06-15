library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- VUnit
library vunit_lib;
context vunit_lib.vunit_context;

use work.math_utils.all;

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

  clk_process : process
  begin
    while true loop
      clk <= '0'; wait for CLK_PERIOD / 2;
      clk <= '1'; wait for CLK_PERIOD / 2;
    end loop;
  end process;

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

  main : process
    constant EXPECTED_A1 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"AAAAAAAA";
    constant EXPECTED_B2 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"55555555";
    constant EXPECTED_COLLISION : std_logic_vector(DATA_WIDTH-1 downto 0) := x"12345678";
  begin
    test_runner_setup(runner, runner_cfg);
    
    while test_suite loop
      if run("write_and_read_separate_addresses") then
        rst <= '1'; wait for CLK_PERIOD * 2;
        rst <= '0'; wait for CLK_PERIOD;

        we_A <= '1'; add_A <= std_logic_vector(to_unsigned(1, add_A'length)); din_A <= EXPECTED_A1;
        we_B <= '1'; add_B <= std_logic_vector(to_unsigned(2, add_B'length)); din_B <= EXPECTED_B2;
        wait for CLK_PERIOD;

        we_A <= '0'; we_B <= '0'; wait for CLK_PERIOD;

        check_equal(dout_A, EXPECTED_A1, "Port A did not read expected data at addr 1.");
        check_equal(dout_B, EXPECTED_B2, "Port B did not read expected data at addr 2.");

      elsif run("simultaneous_write_collision_same_address") then
        rst <= '1'; wait for CLK_PERIOD * 2;
        rst <= '0'; wait for CLK_PERIOD;

        we_A <= '1'; add_A <= std_logic_vector(to_unsigned(3, add_A'length)); din_A <= EXPECTED_COLLISION;
        we_B <= '1'; add_B <= std_logic_vector(to_unsigned(3, add_B'length)); din_B <= x"87654321";
        wait for CLK_PERIOD;

        we_A <= '0'; we_B <= '0'; wait for CLK_PERIOD;

        check_equal(dout_A, EXPECTED_COLLISION, "Port A read incorrect data after write collision at addr 3.");
        check_equal(dout_B, EXPECTED_COLLISION, "Port B read incorrect data after write collision at addr 3.");
      end if;
    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
