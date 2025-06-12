library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_watchdog_timer_reset is
end tb_watchdog_timer_reset;

architecture Behavioral of tb_watchdog_timer_reset is

    -- DUT Signals
    signal clk_tb : std_logic := '0';
    signal reset_system_tb : std_logic;
    signal reset_system_inv_tb : std_logic;

    constant CLK_PERIOD : time := 10 ns; -- Simulated 100 MHz clock

begin

    -- Direct Entity Instantiation (VHDL-2008 style)
    uut: entity work.watchdog_timer_reset
        generic map (
            Granularity_counter => 10,
            Time_to_reset_counter => 5
        )
        port map (
            clk => clk_tb,
            reset_system => reset_system_tb,
            reset_system_inv => reset_system_inv_tb
        );

    -- Clock Generation
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

    -- Optional Monitor Process
    monitor_proc : process
    begin
        wait for 0 ns;
        report "Simulation started";
        wait for 10 ns;
        while now < 12000 ns loop
            wait until rising_edge(clk_tb);
            report "reset_system: " & std_logic'image(reset_system_tb) &
                   ", reset_system_inv: " & std_logic'image(reset_system_inv_tb);
        end loop;
        wait;
    end process;

end Behavioral;
