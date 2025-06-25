library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
  generic (
    counter_bounce : integer := 10  -- number of stable cycles before accepting a change
  );
  Port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    buton         : in  std_logic;
    buton_stable  : out std_logic
  );
end debounce;

architecture Behavioral of debounce is
    signal buton_stable_s     : std_logic := '0';
    signal counter            : integer range 0 to counter_bounce := 0;
    signal prev_buton         : std_logic := '0';
    signal synchron_data_1    : std_logic := '0';
    signal synchron_data      : std_logic := '0';
begin

    -- Synchronize asynchronous input to clock domain
    synchronize_data : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                synchron_data_1 <= '0';
                synchron_data   <= '0';
            else
                synchron_data_1 <= buton;
                synchron_data   <= synchron_data_1;
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

        if counter >= counter_bounce then
          if buton_stable_s /= synchron_data then
            buton_stable_s <= synchron_data;
          end if;
        end if;
      else
        counter <= 0;
      end if;
      prev_buton <= synchron_data;
    end if;
  end if;
end process;



    -- Output assignment
    buton_stable <= buton_stable_s;

end Behavioral;
