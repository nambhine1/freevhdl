library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.all;  -- Assumes clog2 function is defined here

entity axi_stream_fifo is
    generic (
        FIFO_DEPTH : integer := 32;
        DATA_WIDTH : integer := 32
    );
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- Stream input
        s_valid : in  std_logic;
        s_data  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        s_ready : out std_logic;

        -- Stream output
        m_valid : out std_logic;
        m_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        m_ready : in  std_logic
    );
end axi_stream_fifo;

architecture Behavioral of axi_stream_fifo is

    -- FIFO memory type and signal
    type fifo_type is array (0 to FIFO_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal fifo_mem : fifo_type := (others => (others => '0'));

    -- FIFO status flags
    signal fifo_full  : std_logic := '0';
    signal fifo_empty : std_logic := '1';

    -- Write and read pointers
    signal wr_indx : unsigned(clog2(FIFO_DEPTH) - 1 downto 0) := (others => '0');
    signal rd_indx : unsigned(clog2(FIFO_DEPTH) - 1 downto 0) := (others => '0');

    -- Element count in FIFO
    signal count : unsigned(clog2(FIFO_DEPTH) downto 0) := (others => '0');

    -- Output registers
    signal m_valid_reg : std_logic := '0';
    signal m_data_reg  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    -- Control signals
    signal do_write : std_logic;
    signal do_read  : std_logic;
    signal rw_state : std_logic_vector(1 downto 0);

begin

    -- FIFO status
    fifo_full  <= '1' when (to_integer(count) = FIFO_DEPTH) else '0';
    fifo_empty <= '1' when (to_integer(count) = 0)          else '0';

    -- Control logic
    do_write <= '1' when (s_valid = '1' and s_ready = '1') else '0';
    do_read  <= '1' when (m_ready = '1' and fifo_empty = '0') else '0';
    rw_state <= do_write & do_read;

    -- Handshake outputs
    s_ready <= not fifo_full;
    m_valid <= m_valid_reg;
    m_data  <= m_data_reg;

    -- Main FIFO process
    fifo_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                count       <= (others => '0');
                wr_indx     <= (others => '0');
                rd_indx     <= (others => '0');
                m_valid_reg <= '0';
                m_data_reg  <= (others => '0');
                fifo_mem    <= (others => (others => '0'));

            else
                -- Default: clear output valid
                m_valid_reg <= '0';

                -- Write
                if do_write = '1' then
                    fifo_mem(to_integer(wr_indx)) <= s_data;
                    wr_indx <= to_unsigned((to_integer(wr_indx) + 1) mod FIFO_DEPTH, wr_indx'length);
                end if;

                -- Read
                if do_read = '1' then
                    m_data_reg  <= fifo_mem(to_integer(rd_indx));
                    m_valid_reg <= '1';
                    rd_indx <= to_unsigned((to_integer(rd_indx) + 1) mod FIFO_DEPTH, rd_indx'length);
                end if;

                -- Update count
                case rw_state is
                    when "10" => count <= count + 1;  -- Write only
                    when "01" => count <= count - 1;  -- Read only
                    when others => null;              -- Both or neither
                end case;
            end if;
        end if;
    end process;

end Behavioral;
