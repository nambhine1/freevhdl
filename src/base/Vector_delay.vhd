library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vector_delay is
  generic (
    DELAY : integer := 3;
    DATA_WIDTH : integer := 32
  );
  Port (
    clk : in std_logic;  
    rst : in std_logic;
    data_in : in std_logic_vector (DATA_WIDTH -1 downto 0);
    data_out : out std_logic_vector (DATA_WIDTH -1 downto 0)
  );
end vector_delay;

architecture Behavioral of vector_delay is
    type data_array is array (0 to DELAY -1) of std_logic_vector (data_in'range); 
    signal data_store : data_array := (others => (others => '0'));
begin

    -- FIXED: Reference correct index
    data_out <= data_store(DELAY - 1);

    delay_proc: process (clk)
    begin
        if rising_edge (clk) then
            if rst = '1' then
                data_store <= (others => (others => '0'));
            else
                data_store(0) <= data_in;
                for i in 1 to DELAY-1 loop
                    data_store(i) <= data_store(i-1);
                end loop;
            end if;
        end if;
    end process delay_proc;

end Behavioral;
