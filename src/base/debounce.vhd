library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    generic (
        counter_bounce : integer := 10  -- number of stable cycles before accepting a change
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        buton : in std_logic;
        buton_stable : out std_logic
    );
end debounce;

architecture Behavioral of debounce is
    signal buton_stable_s : std_logic := '0';
    signal counter : integer range 0 to counter_bounce := 0;
    signal prev_buton : std_logic := '0';
    signal synchron_data_1 : std_logic := '0';
    signal synchron_data : std_logic := '0';

begin
    -- Synchronize asynchronous input to clock domain
    synchronize_data : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                synchron_data_1 <= '0';
                synchron_data <= '0';
            else
                synchron_data_1 <= buton;
                synchron_data <= synchron_data_1;
            end if;
        end if;
    end process;

    remove_noise : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
                prev_buton <= '0';
                buton_stable_s <= '0';
            else
                if synchron_data = prev_buton then
                    if counter < counter_bounce then
                        counter <= counter + 1;
                    end if;
                else
                    counter <= 0;
                    prev_buton <= synchron_data;
                end if;

                -- Update output when counter reaches threshold
                if counter = counter_bounce - 1 then
                    buton_stable_s <= prev_buton;
                end if;
            end if;
        end if;
    end process;

    -- Output assignment
    buton_stable <= buton_stable_s;
end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2025 11:11:09
-- Design Name: 
-- Module Name: debounce - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Debounce circuit for mechanical button input.
-- 
-- Dependencies: None
-- 
-- Revision:
-- Revision 0.04 - Finalized and corrected debounce logic
-- Additional Comments:
--   - Active-high reset
--   - 2-stage synchronizer
--   - Stable, bounded debounce counter
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
  generic (
    counter_bounce : integer := 10  -- number of stable cycles before accepting a change
  );
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    button         : in  std_logic;
    button_stable  : out std_logic
  );
end debounce;

architecture Behavioral of debounce is
    signal button_stable_s    : std_logic := '0';
    signal counter            : integer range 0 to counter_bounce + 1 := 0;
    signal prev_button        : std_logic := '0';
    signal sync_stage1        : std_logic := '0';
    signal sync_stage2        : std_logic := '0';
begin

    -- 2-stage synchronizer to bring button input into clock domain
    sync_process : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync_stage1 <= '0';
                sync_stage2 <= '0';
            else
                sync_stage1 <= button;
                sync_stage2 <= sync_stage1;
            end if;
        end if;
    end process;

    -- Debounce logic: detect stable button state over consecutive cycles
    debounce_process : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter         <= 0;
                prev_button     <= '0';
                button_stable_s <= '0';
            else
                if sync_stage2 = prev_button then
                    if counter < counter_bounce then
                        counter <= counter + 1;
                    end if;

                    if counter = counter_bounce then
                        if sync_stage2 /= button_stable_s then
                            button_stable_s <= sync_stage2;
                        end if;
                    end if;
                else
                    counter      <= 0;
                    prev_button  <= sync_stage2;
                end if;
            end if;
        end if;
    end process;

    -- Drive output
    button_stable <= button_stable_s;

end Behavioral;
