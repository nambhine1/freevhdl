library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Streching_pulse is
  generic (
    COUNTER_STRETCH : integer := 5  -- Number of clock cycles to stretch
  );
  Port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    Data_in   : in  std_logic;
    Data_out  : out std_logic
  );
end Streching_pulse;

architecture Behavioral of Streching_pulse is
  signal counter      : integer range 0 to COUNTER_STRETCH := 0;
  signal Data_out_reg : std_logic := '0';
begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        counter      <= 0;
        Data_out_reg <= '0';

      elsif Data_in = '1' then
        -- Detected new pulse, start or restart stretch
        counter      <= COUNTER_STRETCH;
        Data_out_reg <= '1';

      elsif counter > 0 then
        counter <= counter - 1;

        if counter = 1 then
          Data_out_reg <= '0';  -- Deassert output on final cycle
        end if;

      end if;
    end if;
  end process;

  Data_out <= Data_out_reg;

end Behavioral;
