library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_tb is
end pwm_tb;

architecture Behavioral of pwm_tb is

    -- Constants
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock

    -- DUT signals
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal pwm_out  : std_logic_vector(4 downto 0);  -- Match COUNTER_WIDTH = 5

begin


    uut: entity work.pwm
        generic map (
            COUNTER_WIDTH => 5
        )
        port map (
            clk      => clk,
            rst      => rst,
            pwm_out  => pwm_out
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
        -- Hold reset for 3 clock cycles
        wait for 3 * CLK_PERIOD;
        rst <= '0';

        -- Run simulation for some time
        wait for 3000 ns;

        -- Finish simulation
        wait;
    end process;

end Behavioral;
