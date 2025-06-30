library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.math_utils.all;  -- Make sure clog2 is correctly defined here

entity mux is
  generic (
    SYNC_MODE_g    : string := "SYNC"; -- "SYNC" or "ASYNC"
    DATA_WIDTH_g   : integer := 32;
    NUMBER_INPUT_g : integer := 3
  );
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;

    -- Concatenated input vector of NUMBER_INPUT_g inputs
    in_data  : in  std_logic_vector(NUMBER_INPUT_g * DATA_WIDTH_g - 1 downto 0);

    -- Selector signal width calculated by clog2(NUMBER_INPUT_g)
    sel      : in  std_logic_vector(clog2(NUMBER_INPUT_g) - 1 downto 0);

    -- Mux output
    out_data : out std_logic_vector(DATA_WIDTH_g - 1 downto 0)
  );
end mux;

architecture Behavioral of mux is
  -- Define an array type to index the inputs easily
  type array_data is array (0 to NUMBER_INPUT_g - 1) of std_logic_vector(DATA_WIDTH_g - 1 downto 0);
  
  signal array_in_data : array_data := (others => (others => '0'));
  signal out_data_s    : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');

begin

  -- Assert that SYNC_MODE_g is valid at elaboration time
  assert (SYNC_MODE_g = "SYNC") or (SYNC_MODE_g = "ASYNC")
    report "SYNC_MODE_g must be either SYNC or ASYNC"
    severity error;

  -- Split the concatenated input vector into the array
  split_proc : process(in_data)
  begin
    for i in 0 to NUMBER_INPUT_g - 1 loop
      array_in_data(i) <= in_data(((i + 1) * DATA_WIDTH_g) - 1 downto i * DATA_WIDTH_g);
    end loop;
  end process split_proc;

  -- Synchronous mux (registered output)
  synchronous_mux : if SYNC_MODE_g = "SYNC" generate
    mux_proc : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          out_data_s <= (others => '0');
        else
          -- Range check for sel
          if to_integer(unsigned(sel)) < NUMBER_INPUT_g then
            out_data_s <= array_in_data(to_integer(unsigned(sel)));
          else
            out_data_s <= (others => '0');
            assert false
              report "sel input out of range in synchronous mux"
              severity warning;
          end if;
        end if;
      end if;
    end process mux_proc;
  end generate synchronous_mux;

  -- Asynchronous mux (combinational output)
  asynchronous_mux : if SYNC_MODE_g = "ASYNC" generate
    async_mux_proc : process(all)
    begin
      if to_integer(unsigned(sel)) < NUMBER_INPUT_g then
        out_data_s <= array_in_data(to_integer(unsigned(sel)));
      else
        out_data_s <= (others => '0');
        assert false
          report "sel input out of range in asynchronous mux"
          severity warning;
      end if;
    end process async_mux_proc;
  end generate asynchronous_mux;

  -- Connect internal registered signal to output port
  out_data <= out_data_s;

end Behavioral;
