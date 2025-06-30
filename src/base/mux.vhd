library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.math_utils.all;

entity mux is
  generic (
    SYNC_MODE_g : string := "SYNC"; -- SYNC; ASYNC
    DATA_WIDTH_g : integer := 32;
    NUMBER_INPUT_g : integer := 3
  );
  Port ( 
      clk : in std_logic;
      rst : in std_logic;
      
      -- input 
      in_data : in std_logic_vector (NUMBER_INPUT_g * DATA_WIDTH_g -1 downto 0);
      sel : in std_logic_vector (clog2(NUMBER_INPUT_g)-1 downto 0);
      
      out_data : out std_logic_vector (DATA_WIDTH_g -1 downto 0)
  );
end mux;

architecture Behavioral of mux is
    type array_data is array (0 to NUMBER_INPUT_g -1) of std_logic_vector (DATA_WIDTH_g -1 downto 0);
    signal array_in_data : array_data := (others => (others => '0'));
    signal out_data_s : std_Logic_vector (DATA_WIDTH_g -1 downto 0) := (others => '0'); 
begin

    --*** check synchronous mode***
    assert SYNC_MODE_g = "SYNC" or SYNC_MODE_g = "ASYNC"
           report "synchronous mode shall be only sync or async"
           severity error;
           
    --*** split input data to array***
    split_proc : process (all)
      begin
        for i in 0 to NUMBER_INPUT_g -1 loop 
            array_in_data(i) <= in_data ( ((i+1) * DATA_WIDTH_g) -1 downto i* DATA_WIDTH_g);
        end loop;
      end process split_proc;
      
    --*** SYNCHRONOUS MUX***  
    synchronous_mux : if SYNC_MODE_g = "SYNC" generate 
        mux_proc : process (clk)
          begin
              if rising_edge (clk) then
                if rst = '1' then
                    out_data_s <= (others => '0');
                else
                    out_data_s <= array_in_data(to_integer(unsigned (sel)));
                end if;
              end if;
          end process;
    end generate synchronous_mux;
    
        --*** ASYNCHRONOUS MUX**   
    Asynchronous_mux : if SYNC_MODE_g = "ASYNC" generate 
        mux_proc : process (all)
          begin
             out_data_s <= array_in_data(to_integer(unsigned (sel)));
          end process;
    end generate Asynchronous_mux;
    
    out_data <= out_data_s;

end Behavioral;
