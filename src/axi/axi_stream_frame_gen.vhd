library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi_stream_frame_gen is
    generic (
        TUSER_WIDTH  : integer := 5;
        TDATA_WIDTH  : integer := 32;
        IMAGE_WIDTH  : integer := 2560;
        IMAGE_HEIGHT : integer := 1440;
        SOF_USER_POS : integer := 0;
        EOF_USER_POS : integer := 4
    );
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        
        -- Input stream
        s_valid : in  std_logic;
        s_ready : out std_logic;
        s_data  : in  std_logic_vector (TDATA_WIDTH - 1 downto 0);
        s_user  : in  std_logic_vector (TUSER_WIDTH - 1 downto 0);
        s_last  : in  std_logic;
        
        -- Output stream
        m_valid : out std_logic; 
        m_ready : in  std_logic;
        m_data  : out std_logic_vector (TDATA_WIDTH - 1 downto 0);
        m_user  : out std_logic_vector (TUSER_WIDTH - 1 downto 0);
        m_last  : out std_logic
    );
end axi_stream_frame_gen;

architecture Behavioral of axi_stream_frame_gen is
    signal data_reg      : std_logic_vector(TDATA_WIDTH-1 downto 0) := (others => '0');
    signal user_reg      : std_logic_vector(TUSER_WIDTH-1 downto 0) := (others => '0');
    signal last_reg      : std_logic := '0';
    signal valid_reg     : std_logic := '0';
    signal counter_width : integer range 0 to IMAGE_WIDTH - 1 := 0;
    signal counter_height: integer range 0 to IMAGE_HEIGHT - 1 := 0;
begin
   assert SOF_USER_POS < TUSER_WIDTH and EOF_USER_POS < TUSER_WIDTH
        report "SOF_USER_POS , and EOF_USER_POS shall be less than TUSER_WIDTH "
        severity failure;
    -- Output assignments
    m_valid <= valid_reg;
    m_data  <= data_reg;
    m_user  <= user_reg;
    m_last  <= last_reg;

    -- Ready when data is not valid or was accepted
    s_ready <= not valid_reg or m_ready;
    

    process(clk)
        variable temp_user : std_logic_vector(TUSER_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '0' then
                valid_reg      <= '0';
                data_reg       <= (others => '0');
                user_reg       <= (others => '0');
                last_reg       <= '0';
                counter_width  <= 0;
                counter_height <= 0;

            else
                -- Clear valid if current output accepted by downstream
                if m_valid_reg = '1' and m_ready = '1' then
                    m_valid_reg <= '0';
                end if;
                    
                if (s_valid = '1' and s_ready = '1') then
                    -- Load new data
                    data_reg <= s_data;

                    -- Default user and last signals
                    temp_user := (others => '0');
                    last_reg  <= '0';

                    -- Check SOF
                    if (counter_width = 0 and counter_height = 0) then
                        temp_user(SOF_USER_POS) := '1';  -- Start of Frame
                    end if;

                    -- Check EOF and update counters
                    if (counter_width = IMAGE_WIDTH - 1) then
                        counter_width <= 0;
                        if (counter_height = IMAGE_HEIGHT - 1) then
                            counter_height <= 0;
                            temp_user(EOF_USER_POS) := '1'; -- End of Frame
                        else
                            counter_height <= counter_height + 1;
                        end if;
                        last_reg <= '1';  -- End of line
                    else
                        counter_width <= counter_width + 1;
                    end if;

                    user_reg  <= temp_user;
                    valid_reg <= '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;

