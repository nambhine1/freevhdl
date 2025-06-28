library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.math_utils.all;

entity decode_first_bit is
  generic (
    DATA_WIDTH_g : positive := 32
  );
  Port (
    clk       : in std_logic;
    rst       : in std_logic;

    -- input data
    valid     : in std_logic;
    data      : in std_logic_vector(DATA_WIDTH_g - 1 downto 0);

    out_valid : out std_logic;
    out_data  : out std_logic_vector(clog2(DATA_WIDTH_g) - 1 downto 0);
    out_found : out std_logic
  );
end decode_first_bit;

architecture Behavioral of decode_first_bit is
  constant ZERO_VECTOR : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');
  signal out_valid_s : std_logic;
  signal out_data_s  : std_logic_vector(out_data'range);
  signal out_found_s : std_logic;
begin

  out_valid <= out_valid_s;
  out_data  <= out_data_s;
  out_found <= out_found_s;

  decode_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        out_valid_s <= '0';
        out_data_s  <= (others => '0');
        out_found_s <= '0';
      else
        -- default value
        out_valid_s <= '0';
        out_data_s <= (others => '0');
        out_found_s <= '0';
        
        if valid = '1' then
          if data /= ZERO_VECTOR then
            for i in 0 to DATA_WIDTH_g - 1 loop
              if data(i) = '1' then
                out_valid_s <= '1';
                out_data_s <= std_logic_vector(to_unsigned(i, out_data'length));
                out_found_s <= '1';
                exit;
              end if;
            end loop;
          else
            out_valid_s <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

end Behavioral;
