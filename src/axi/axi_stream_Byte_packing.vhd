library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Byte_packing is
    generic (
        DATA_WIDTH_g  : integer := 8;
        NUMB_OUTPUT_g : integer := 3
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;

        -- Input stream interface
        s_valid  : in  std_logic;
        s_ready  : out std_logic;
        s_data   : in  std_logic_vector(DATA_WIDTH_g - 1 downto 0);

        -- Output stream interface
        m_valid  : out std_logic;
        m_ready  : in  std_logic;
        m_data   : out std_logic_vector(NUMB_OUTPUT_g * DATA_WIDTH_g - 1 downto 0)
    );
end Byte_packing;

architecture Behavioral of Byte_packing is

    -- Internal storage of incoming bytes
    type byte_array_t is array(0 to NUMB_OUTPUT_g - 1) of std_logic_vector(DATA_WIDTH_g - 1 downto 0);
    signal byte_store  : byte_array_t := (others => (others => '0'));

    -- Position index for byte_store
    signal index_pos   : integer range 0 to NUMB_OUTPUT_g - 1 := 0;

    -- Output valid flag
    signal m_valid_s   : std_logic := '0';

begin

    -- Ready/valid handshake logic
    s_ready <= m_ready or not m_valid_s;
    m_valid <= m_valid_s;

    -- Pack bytes into output bus
    map_data_s : for i in 0 to NUMB_OUTPUT_g - 1 generate
        m_data((i + 1) * DATA_WIDTH_g - 1 downto i * DATA_WIDTH_g) <= byte_store(i);
    end generate;

    byte_pack_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                index_pos  <= 0;
                m_valid_s  <= '0';
                byte_store <= (others => (others => '0'));
            else
                if s_valid = '1' and s_ready = '1' then
                    byte_store(index_pos) <= s_data;

                    if index_pos = NUMB_OUTPUT_g - 1 then
                        m_valid_s <= '1';
                        index_pos <= 0;
                    else
                        index_pos <= index_pos + 1;
                    end if;

                elsif m_ready = '1' then
                    m_valid_s <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
