----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.06.2025 22:11:00
-- Design Name: 
-- Module Name: time_bomb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity watchdog_timer_reset is
    generic (
        Granularity_counter : integer := 1000000000; -- 1 second for input frequency 100 MHZ
        Time_to_reset_counter : integer := 3600  -- 8H       
    );
  Port (
    clk : in std_logic;
    reset_system : out std_logic;
    reset_system_inv : out std_logic
   );
end watchdog_timer_reset;

architecture Behavioral of watchdog_timer_reset is
    signal reset_system_reg : std_logic := '0';
    signal reset_system_inv_reg : std_logic := '1';
    signal counter_granularity : integer range 0 to Granularity_counter := 0;
    signal counter_time_to_reset : integer range 0 to Time_to_reset_counter := 0;
begin

    reset_proc: process (clk)
    begin
        if rising_edge(clk) then
            if counter_granularity = Granularity_counter then
                counter_granularity <= 0;

                if counter_time_to_reset = Time_to_reset_counter then
                    reset_system_reg <= '1';
                else
                    counter_time_to_reset <= counter_time_to_reset + 1;
                    reset_system_reg <= '0';
                end if;

            else
                counter_granularity <= counter_granularity + 1;
            end if;

            reset_system_inv_reg <= not reset_system_reg;
        end if;
    end process;

    -- Output assignments
    reset_system <= reset_system_reg;
    reset_system_inv <= reset_system_inv_reg;

end Behavioral;
