library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_stream_delta is
  generic (
    DATA_WIDTH : integer := 32;
    DIFF       : std_logic_vector (1 downto 0) := "01" -- "01" = SUBTRACT, "10" = ADD
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;

    -- AXI Stream Slave
    s_valid : in  std_logic;
    s_ready : out std_logic;
    s_data  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- AXI Stream Master
    m_valid : out std_logic;
    m_ready : in  std_logic;
    m_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end axi_stream_delta;

architecture Behavioral of axi_stream_delta is

    constant DIFF_SUB : std_logic_vector(1 downto 0) := "01";
    constant DIFF_ADD : std_logic_vector(1 downto 0) := "10";

    signal m_valid_reg    : std_logic := '0';
    signal m_data_reg     : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal previous_data  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    

begin

    -- Output assignments
    m_data  <= m_data_reg;
    m_valid <= m_valid_reg;
    s_ready <= not m_valid_reg or m_ready;

    diff_data : process (clk)
      variable first_data     : boolean := true;
    begin
        if rising_edge(clk) then
            if rst = '0' then
                m_data_reg    <= (others => '0');
                m_valid_reg   <= '0';
                previous_data <= (others => '0');
                first_data    := true;

            else
                if s_valid = '1' and s_ready = '1' then
                    if first_data then
                        m_data_reg <= s_data;
                        first_data := false;
                    else
                        if DIFF = DIFF_SUB then
                            m_data_reg <= std_logic_vector(unsigned(s_data) - unsigned(previous_data));
                        elsif DIFF = DIFF_ADD then
                            m_data_reg <= std_logic_vector(unsigned(s_data) + unsigned(previous_data));
                        else
                            m_data_reg <= s_data;
                        end if;
                    end if;
                    m_valid_reg   <= '1';
                    previous_data <= s_data;

                elsif m_ready = '1' then
                    m_valid_reg <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
