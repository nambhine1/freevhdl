library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_watchdog_timer_reset is
end tb_watchdog_timer_reset;

architecture Behavioral of tb_watchdog_timer_reset is

    -- Component Declaration
    component watchdog_timer_reset
        generic (
            Granularity_counter : integer := 10; -- Reduced for simulation
            Time_to_reset_counter : integer := 5 -- Reduced for quick test
        );
        Port (
            clk : in std_logic;
            reset_system : out std_logic;
            reset_system_inv : out std_logic
        );
    end component;

    -- Signals to connect to DUT
    signal clk_tb : std_logic := '0';
    signal reset_system_tb : std_logic;
    signal reset_system_inv_tb : std_logic;

    constant CLK_PERIOD : time := 10 ns; -- 100 MHz simulated clock

begin

    -- Instantiate the DUT (Design Under Test)
    uut: watchdog_timer_reset
        generic map (
            Granularity_counter => 10,
            Time_to_reset_counter => 5
        )
        port map (
            clk => clk_tb,
            reset_system => reset_system_tb,
            reset_system_inv => reset_system_inv_tb
        );

    -- Clock generation process
    clk_process : process
    begin
        while now < 12000 ns loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

end Behavioral;
