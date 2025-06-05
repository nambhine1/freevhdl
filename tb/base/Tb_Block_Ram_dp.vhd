library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.all;  -- Use the same math_utils as DUT

entity tb_Block_Ram_dp is
end entity;

architecture Behavioral of tb_Block_Ram_dp is

  constant DATA_WIDTH : integer := 32;
  constant RAM_DEPTH  : integer := 32;

  -- Signals for DUT
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

begin

  -- Clock generation 10ns period
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
  end process;

  -- Instantiate DUT
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
  test_process : process
  begin
    -- Reset RAM
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait for 10 ns;

    -- Write different data to different addresses simultaneously on both ports
    we_A <= '1'; add_A <= std_logic_vector(to_unsigned(1, add_A'length)); din_A <= x"AAAAAAAA";  -- Address 1
    we_B <= '1'; add_B <= std_logic_vector(to_unsigned(2, add_B'length)); din_B <= x"55555555";  -- Address 2
    wait for 10 ns; -- Rising edge, write occurs

    -- Disable writes, read back data
    we_A <= '0'; we_B <= '0';
    wait for 10 ns; -- read data output updated

    -- Check data read from both ports
    assert dout_A = x"AAAAAAAA"
      report "Test failed: Port A did not read expected data after write."
      severity error;
    assert dout_B = x"55555555"
      report "Test failed: Port B did not read expected data after write."
      severity error;

    -- Now write different data to the SAME address on both ports simultaneously
    we_A <= '1'; add_A <= std_logic_vector(to_unsigned(3, add_A'length)); din_A <= x"12345678";  -- Address 3
    we_B <= '1'; add_B <= std_logic_vector(to_unsigned(3, add_B'length)); din_B <= x"87654321";  -- Same Address 3
    wait for 10 ns; -- rising edge

    -- Disable writes, read back
    we_A <= '0'; we_B <= '0';
    wait for 10 ns;

    -- According to code, Port A write has priority, so RAM content at address 3 should be din_A
    assert dout_A = x"12345678"
      report "Test failed: Port A read incorrect data after simultaneous write collision."
      severity error;
    assert dout_B = x"12345678"
      report "Test failed: Port B read incorrect data after simultaneous write collision."
      severity error;

    -- Finish simulation
    report "All tests passed.";
    wait;
  end process;

end Behavioral;
