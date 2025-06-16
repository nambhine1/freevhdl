library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_arbiter_fixed_priority is
    generic (runner_cfg : string);
end entity;

architecture vunit_arch of tb_arbiter_fixed_priority is

    constant REQUEST_WIDTH : integer := 3;

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal request     : std_logic_vector(REQUEST_WIDTH - 1 downto 0) := (others => '0');
    signal grant       : std_logic_vector(REQUEST_WIDTH - 1 downto 0);
    signal valid_grant : std_logic;

begin

    -- Clock generation
    clk <= not clk after 5 ns;

    -- DUT instantiation
    DUT: entity work.arbiter_fixed_priority
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

    -- VUnit test process
    main : process
    begin
        test_runner_setup(runner, runner_cfg);

        if run("No_Request") then
            rst <= '1';
            wait for 10 ns;
            rst <= '0';
            wait for 10 ns;

            request <= "000";
            wait for 10 ns;
            check_equal(grant, 2#000#, "Grant should be none when no requests");
            check_equal(valid_grant, '0', "Valid_grant should be 0 when no requests");

        elsif run("Request_0") then
            request <= "001";
            wait for 10 ns;
            check_equal(grant, 2#001#, "Grant should be request(0)");
            check_equal(valid_grant, '1', "Valid_grant should be 1");

        elsif run("Request_1") then
            request <= "010";
            wait for 10 ns;
            check_equal(grant, 2#010#, "Grant should be request(1)");
            check_equal(valid_grant, '1');

        elsif run("Request_2") then
            request <= "100";
            wait for 10 ns;
            check_equal(grant, 2#100#, "Grant should be request(2)");
            check_equal(valid_grant, '1');

        elsif run("Request_0_and_2") then
            request <= "101";
            wait for 10 ns;
            check_equal(grant, 2#001#, "Grant should be request(0) due to priority");
            check_equal(valid_grant, '1');

        elsif run("All_Requests") then
            request <= "111";
            wait for 10 ns;
            check_equal(grant, 2#001#, "Grant should be request(0) due to highest priority");
            check_equal(valid_grant, '1');

        elsif run("Reset_Test") then
            rst <= '1';
            wait for 10 ns;
            rst <= '0';
            request <= "111";
            wait for 10 ns;
            rst <= '1';
            wait for 10 ns;
            check_equal(grant, 2#000#, "Grant should be cleared on reset");
            check_equal(valid_grant, '0', "Valid_grant should be 0 after reset");

        end if;

        test_runner_cleanup(runner);
    end process;

end architecture;
