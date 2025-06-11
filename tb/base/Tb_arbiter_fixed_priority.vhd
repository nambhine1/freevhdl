library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_arbiter_fixed_priority is
end tb_arbiter_fixed_priority;

architecture Behavioral of tb_arbiter_fixed_priority is

    constant REQUEST_WIDTH : integer := 3;

    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal request      : std_logic_vector(REQUEST_WIDTH - 1 downto 0) := (others => '0');
    signal grant        : std_logic_vector(REQUEST_WIDTH - 1 downto 0);
    signal valid_grant  : std_logic;

    component arbiter_fixed_priority
        generic (
            REQUEST_WIDTH : integer := 3
        );
        Port (
            clk         : in std_logic;
            rst         : in std_logic;
            request     : in std_logic_vector (REQUEST_WIDTH -1 downto 0);
            grant       : out std_logic_vector (REQUEST_WIDTH -1 downto 0);
            valid_grant : out std_logic
        );
    end component;

begin

    -- Clock generation
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
    DUT: arbiter_fixed_priority
        generic map (
            REQUEST_WIDTH => REQUEST_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            request => request,
            grant => grant,
            valid_grant => valid_grant
        );

    -- Stimulus process
    stimulus: process
    begin
        -- Apply reset
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait for 10 ns;

        -- Test 1: No request
        request <= "000";
        wait for 10 ns;
        assert grant = "000" and valid_grant = '0'
        report "Test 1 Failed: Expected no grant"
        severity error;

        -- Test 2: Only request(0) is high (highest priority)
        request <= "001";
        wait for 10 ns;
        assert grant = "001" and valid_grant = '1'
        report "Test 2 Failed: Expected grant(0)"
        severity error;

        -- Test 3: Only request(1) is high
        request <= "010";
        wait for 10 ns;
        assert grant = "010" and valid_grant = '1'
        report "Test 3 Failed: Expected grant(1)"
        severity error;

        -- Test 4: Only request(2) is high
        request <= "100";
        wait for 10 ns;
        assert grant = "100" and valid_grant = '1'
        report "Test 4 Failed: Expected grant(2)"
        severity error;

        -- Test 5: Multiple requests (0 and 2) – should grant 0
        request <= "101";
        wait for 10 ns;
        assert grant = "001" and valid_grant = '1'
        report "Test 5 Failed: Expected grant(0) as highest priority"
        severity error;

        -- Test 6: All requests active – should grant 0
        request <= "111";
        wait for 10 ns;
        assert grant = "001" and valid_grant = '1'
        report "Test 6 Failed: Expected grant(0) as highest priority"
        severity error;

        -- Test 7: Reset again and check outputs clear
        rst <= '1';
        wait for 10 ns;
        assert grant = "000" and valid_grant = '0'
        report "Test 7 Failed: Expected outputs to reset"
        severity error;

        report "All tests passed." severity note;
        wait;

    end process;

end Behavioral;
