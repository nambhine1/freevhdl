library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity image_inversion is
  generic (
    DATA_WIDTH : integer := 32;
    BIT_PER_DATA : integer := 8
  );
  Port (
    clk : in std_logic;
    rst : in std_logic;
    
    -- axi stream from master 
    s_valid : in std_logic;
    s_ready : out std_logic;
    s_data : in std_logic_vector (DATA_WIDTH -1 downto 0); 
    
    -- axi stream to slave
    m_valid : out std_logic;
    m_ready : in std_logic;
    m_data : out std_logic_vector (DATA_WIDTH -1 downto 0)
  );
end image_inversion;

architecture Behavioral of image_inversion is
     constant Number_of_data : integer := DATA_WIDTH/BIT_PER_DATA;
     signal m_valid_reg : std_logic;
     signal m_data_reg : std_logic_vector (DATA_WIDTH -1 downto 0);
begin

    assert (DATA_WIDTH mod BIT_PER_DATA = 0)
    report "DATA_WIDTH must be a multiple of BIT_PER_DATA" severity failure;
    
     m_valid <= m_valid_reg;
     m_data <= m_data_reg;
     s_ready <= m_ready or not m_valid_reg;
     process_image_inv : process (clk)
       begin
            if rising_edge (clk) then
                if rst = '0' then
                    m_valid_reg <= '0';
                    m_data_reg <= (others => '0');
                else
                    if (s_valid = '1' and s_ready = '1') then
                        for i in 0 to Number_of_data -1 loop
                            m_data_reg((((i+1)*BIT_PER_DATA) - 1) downto i*BIT_PER_DATA) <=
                            std_logic_vector(to_unsigned(
                            (2 ** BIT_PER_DATA - 1) - to_integer(unsigned(s_data((((i+1)*BIT_PER_DATA) - 1) downto i*BIT_PER_DATA))),
                             BIT_PER_DATA));
                        end loop;
                        m_valid_reg <= '1';
                    elsif (m_ready = '1') then  
                         m_valid_reg <= '0';
                    end if; 
                end if;
            end if;
       end process;

end Behavioral;
