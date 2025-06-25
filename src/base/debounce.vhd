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
