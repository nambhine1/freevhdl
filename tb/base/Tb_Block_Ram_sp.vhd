library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.math_utils.all;

entity Block_Ram_tb is
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
  stim_proc: process
    variable expected : std_logic_vector(DATA_WIDTH - 1 downto 0);
  begin
    -- Reset
    wait for 10 ns;
    rst <= '0';
    wait for 10 ns;

    -------------------------------------------------
    -- Write to address 1, then read from address 1
    -------------------------------------------------
    addr <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
    din  <= x"AB";
    we   <= '1';
    wait for 10 ns;

    -- In "WBR", value should appear on dout in same cycle
    -- In "RBW", value appears in next read
    we   <= '0';
    din  <= (others => '0');  -- clear input

    wait for 10 ns;

    if RAM_MODE = "WBR" then
      expected := x"AB";
      assert dout = expected
        report "WBR: Write not reflected correctly on dout" severity error;

    elsif RAM_MODE = "RBW" then
      expected := (others => '0');
      assert dout = expected
        report "RBW: Unexpected data on dout immediately after write" severity error;

      wait for 10 ns;
      expected := x"AB";
      assert dout = expected
        report "RBW: Read after write failed" severity error;
    end if;

    -------------------------------------------------
    -- Write new data to same address and verify again
    -------------------------------------------------
    addr <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
    din  <= x"CD";
    we   <= '1';
    wait for 10 ns;
    we   <= '0';
    din  <= (others => '0');
    wait for 10 ns;

    if RAM_MODE = "WBR" then
      expected := x"CD";
      assert dout = expected
        report "WBR: Second write not reflected immediately" severity error;
    elsif RAM_MODE = "RBW" then
      expected := x"AB";
      assert dout = expected
        report "RBW: Second write read-before incorrect" severity error;
      wait for 10 ns;
      expected := x"CD";
      assert dout = expected
        report "RBW: Second write data not available after read" severity error;
    end if;

    -------------------------------------------------
    -- Finish simulation
    -------------------------------------------------
    report "Test completed successfully." severity note;
    wait;
  end process;

end architecture;
