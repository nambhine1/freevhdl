library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.math_utils.all; -- Assumes `clog2` is defined here

entity decode_first_bit is
  generic (
    DATA_WIDTH_g : positive := 32;
    SPLIT_DATA_g : positive := 2
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    valid     : in  std_logic;
    data      : in  std_logic_vector(DATA_WIDTH_g - 1 downto 0);
    out_valid : out std_logic;
    out_data  : out std_logic_vector(clog2(DATA_WIDTH_g) - 1 downto 0);
    out_found : out std_logic
  );
end decode_first_bit;

architecture Behavioral of decode_first_bit is

  constant DATA_WIDTH_SPLIT_c   : integer := DATA_WIDTH_g / SPLIT_DATA_g;
  constant DATA_WIDTH_OUTPUT_c : integer := clog2(DATA_WIDTH_SPLIT_c);
  constant ZERO_SPLIT_DATA_c   : std_logic_vector(DATA_WIDTH_SPLIT_c - 1 downto 0) := (others => '0');

  -- Internal types
  type data_array       is array (0 to SPLIT_DATA_g - 1) of std_logic_vector(DATA_WIDTH_SPLIT_c - 1 downto 0);
  type data_array_out   is array (0 to SPLIT_DATA_g - 1) of std_logic_vector(DATA_WIDTH_OUTPUT_c - 1 downto 0);
  type valid_array      is array (0 to SPLIT_DATA_g - 1) of std_logic;

  -- Internal signals
  signal in_data_array   : data_array      := (others => (others => '0'));
  signal out_data_array  : data_array_out  := (others => (others => '0'));
  signal out_valid_array : valid_array     := (others => '0');
  signal out_found_array : valid_array     := (others => '0');
  signal out_data_s      : std_logic_vector(out_data'range);
  signal out_valid_s     : std_logic;
  signal out_found_s     : std_logic;

begin


  assert (DATA_WIDTH_g mod SPLIT_DATA_g = 0)
    report "DATA_WIDTH_g must be divisible by SPLIT_DATA_g"
    severity failure;


  -- Output assignments
  out_data  <= out_data_s;
  out_valid <= out_valid_s;
  out_found <= out_found_s;

  -- Input splitting
  split_data : process(data)
  begin
    for i in 0 to SPLIT_DATA_g - 1 loop
      in_data_array(i) <= data(((i + 1) * DATA_WIDTH_SPLIT_c) - 1 downto i * DATA_WIDTH_SPLIT_c);
    end loop;
  end process;

  -- Parallel decoding of each split
  decode_process : for i in 0 to SPLIT_DATA_g - 1 generate
    process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          out_data_array(i)  <= (others => '0');
          out_valid_array(i) <= '0';
          out_found_array(i) <= '0';
        else
          out_valid_array(i) <= '0';
          out_found_array(i) <= '0';
          out_data_array(i)  <= (others => '0');

          if valid = '1' then
            if in_data_array(i) /= ZERO_SPLIT_DATA_c then
              for j in 0 to DATA_WIDTH_SPLIT_c - 1 loop
                if in_data_array(i)(j) = '1' then
                  out_data_array(i)  <= std_logic_vector(to_unsigned(j, DATA_WIDTH_OUTPUT_c));
                  out_valid_array(i) <= '1';
                  out_found_array(i) <= '1';
                  exit;
                end if;
              end loop;
            else
              out_valid_array(i) <= '1'; -- Still valid, but no '1' found
              out_found_array(i) <= '0';
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate;

  -- Select the first found '1' across splits
  select_output : process(clk)
    variable temp_index : unsigned(out_data_s'range);
    variable found      : boolean := false;
  begin
    if rising_edge(clk) then
      out_data_s  <= (others => '0');
      out_valid_s <= '0';
      out_found_s <= '0';
      found       := false;

      for i in 0 to SPLIT_DATA_g - 1 loop
        if out_valid_array(i) = '1' then
          out_valid_s <= '1';
        end if;

        if (not found) and (out_found_array(i) = '1') then
          temp_index := to_unsigned(i * DATA_WIDTH_SPLIT_c, out_data_s'length) +
                        unsigned(out_data_array(i));
          out_data_s  <= std_logic_vector(temp_index);
          out_found_s <= '1';
          found       := true;
        end if;
      end loop;
    end if;
  end process;

end Behavioral;
