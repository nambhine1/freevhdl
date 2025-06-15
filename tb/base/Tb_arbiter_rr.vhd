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

  -- Helper function to convert std_logic_vector to string (for messages)
  function to_string(slv: std_logic_vector) return string is
    variable result : string(1 to slv'length);
  begin
    for i in slv'range loop
      result(i - slv'low + 1) := character'VALUE(std_ulogic'IMAGE(slv(i)));
    end loop;
    return result;
  end;

  -- Opcode constants and test vectors could be here if needed
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
    variable runner : vunit_lib.test_runner_t;
  begin
    test_runner_setup(runner, runner_cfg);

    -- Reset pulse
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';
    wait for CLK_PERIOD;

    if run("test_no_requests") then
      request <= "0000";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "0000", "Grant mismatch on no requests");
      check_equal(runner, valid_grant, '0', "Valid grant mismatch on no requests");

    elsif run("test_single_request_0") then
      request <= "1000";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "1000", "Grant mismatch on request 0");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch on request 0");

    elsif run("test_single_request_1") then
      request <= "0100";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "0100", "Grant mismatch on request 1");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch on request 1");

    elsif run("test_multiple_requests") then
      -- Example sequence for multiple requests showing round-robin rotation
      request <= "1100";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "1000", "Grant mismatch step 1");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch step 1");

      request <= "1100";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "0100", "Grant mismatch step 2");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch step 2");

      request <= "0010";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "0010", "Grant mismatch step 3");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch step 3");

      request <= "1010";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "1000", "Grant mismatch step 4");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch step 4");

      request <= "0001";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "0001", "Grant mismatch step 5");
      check_equal(runner, valid_grant, '1', "Valid grant mismatch step 5");

      request <= "0000";
      wait for CLK_PERIOD;
      check_equal(runner, grant, "0000", "Grant mismatch step 6");
      check_equal(runner, valid_grant, '0', "Valid grant mismatch step 6");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
