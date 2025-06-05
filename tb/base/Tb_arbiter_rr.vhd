-- ============================================================================
-- Title       : Testbench for Round-Robin Arbiter
-- File        : tb_arbiter_rr.vhd
-- Author      : Rakotojaona Nambinina
-- Description : 
--   This self-checking VHDL testbench verifies the functionality of a 
--   round-robin arbiter with 4 request lines. It applies a sequence of 
--   request vectors and checks that the arbiter grants access fairly 
--   and in a rotating manner. Expected outputs are compared with actual 
--   outputs and failures are reported using assertions.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_arbiter_rr is
end tb_arbiter_rr;

architecture Behavioral of tb_arbiter_rr is

  constant REQUEST_WIDTH : integer := 4;

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '0';
  signal request     : std_logic_vector(REQUEST_WIDTH - 1 downto 0) := (others => '0');
  signal grant       : std_logic_vector(REQUEST_WIDTH - 1 downto 0);
  signal valid_grant : std_logic;

  constant CLK_PERIOD : time := 10 ns;

  -- Helper function to convert std_logic_vector to string
  function to_string(slv: std_logic_vector) return string is
    variable result : string(1 to slv'length);
  begin
    for i in slv'range loop
      result(i - slv'low + 1) := character'VALUE(std_ulogic'IMAGE(slv(i)));
    end loop;
    return result;
  end;

  -- Test vectors
  type request_array is array (natural range <>) of std_logic_vector(REQUEST_WIDTH - 1 downto 0);
  type grant_array   is array (natural range <>) of std_logic_vector(REQUEST_WIDTH - 1 downto 0);
  type valid_array   is array (natural range <>) of std_logic;

  constant test_requests : request_array := (
    "0000", -- No requests
    "1000", -- Grant 0
    "1100", -- Grant 1
    "0010", -- Grant 2
    "1010", -- Grant 0 (after 2)
    "0001", -- Grant 3
    "0000"  -- No requests
  );

  constant expected_grants : grant_array := (
    "0000",
    "1000",
    "0100",
    "0010",
    "1000",
    "0001",
    "0000"
  );

  constant expected_valids : valid_array := (
    '0',
    '1',
    '1',
    '1',
    '1',
    '1',
    '0'
  );

begin

  -- Instantiate DUT
  uut: entity work.arbiter_rr
    generic map (
      REQUEST_WIDTH => REQUEST_WIDTH
    )
    port map (
      clk         => clk,
      rst         => rst,
      request     => request,
      grant       => grant,
      valid_grant => valid_grant
    );

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

  -- Stimulus process
  stim_proc: process
  begin
    -- Apply synchronous reset
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    -- Apply test vectors
    for i in test_requests'range loop
      request <= test_requests(i);
      wait for CLK_PERIOD;

      assert grant = expected_grants(i)
        report "Test failed at step " & integer'image(i) &
               ": expected grant = " & to_string(expected_grants(i)) &
               ", got " & to_string(grant)
        severity error;

      assert valid_grant = expected_valids(i)
        report "Test failed at step " & integer'image(i) &
               ": expected valid_grant = " & std_ulogic'image(expected_valids(i)) &
               ", got " & std_ulogic'image(valid_grant)
        severity error;
    end loop;

    report "All tests passed successfully." severity note;
    wait;
  end process;

end Behavioral;
