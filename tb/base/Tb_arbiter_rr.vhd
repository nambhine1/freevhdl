library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_arbiter_rr is
  generic (runner_cfg : string);
end tb_arbiter_rr;

architecture Behavioral of tb_arbiter_rr is

  constant REQUEST_WIDTH : integer := 4;

  signal clk         : std_logic := '0';
  signal rst         : std_logic := '0';
  signal request     : std_logic_vector(REQUEST_WIDTH - 1 downto 0) := (others => '0');
  signal grant       : std_logic_vector(REQUEST_WIDTH - 1 downto 0);
  signal valid_grant : std_logic;

  constant CLK_PERIOD : time := 10 ns;

begin

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

  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  main : process
  begin
    test_runner_setup(runner_cfg);

    -- Reset
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';
    wait for CLK_PERIOD;

    if run("test_no_requests") then
      request <= "0000";
      wait for CLK_PERIOD;
      check_equal(grant, 2#0000# , "Grant mismatch on no requests");
      check_equal(valid_grant, '0', "Valid mismatch on no requests");

    elsif run("test_single_request_0") then
      request <= "1000";
      wait for CLK_PERIOD;
      check_equal(grant, 2#1000#, "Grant mismatch on request 0");
      check_equal(valid_grant, '1', "Valid mismatch on request 0");

    elsif run("test_single_request_1") then
      request <= "0100";
      wait for CLK_PERIOD;
      check_equal(grant, 2#0100#, "Grant mismatch on request 1");
      check_equal(valid_grant, '1', "Valid mismatch on request 1");

    elsif run("test_multiple_requests") then
      request <= "1100";
      wait for CLK_PERIOD;
      check_equal(grant,2#1000#, "Step 1: Grant mismatch");
      check_equal(valid_grant, '1', "Step 1: Valid mismatch");

      request <= "1100";
      wait for CLK_PERIOD;
      check_equal(grant, 2#0100#, "Step 2: Grant mismatch");
      check_equal(valid_grant, '1', "Step 2: Valid mismatch");

      request <= "0010";
      wait for CLK_PERIOD;
      check_equal(grant, 2#0010#, "Step 3: Grant mismatch");
      check_equal(valid_grant, '1', "Step 3: Valid mismatch");

      request <= "1010";
      wait for CLK_PERIOD;
      check_equal(grant, 2#1000#, "Step 4: Grant mismatch");
      check_equal(valid_grant, '1', "Step 4: Valid mismatch");

      request <= "0001";
      wait for CLK_PERIOD;
      check_equal(grant, 2#0001#, "Step 5: Grant mismatch");
      check_equal(valid_grant, '1', "Step 5: Valid mismatch");

      request <= "0000";
      wait for CLK_PERIOD;
      check_equal(grant, 2#0000#, "Step 6: Grant mismatch");
      check_equal(valid_grant, '0', "Step 6: Valid mismatch");
    end if;

    test_runner_cleanup;
    wait;
  end process;

end Behavioral;
