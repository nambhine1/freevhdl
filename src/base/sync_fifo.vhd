------------------------------------------------------------------
-- Synchronous FIFO (sync_fifo)
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.ALL;

entity sync_fifo is
    generic (
        DATA_WIDTH             : integer := 32;
        FIFO_DEPTH             : integer := 32;
        FIFO_ALMOST_FULL_VAL   : integer := 25;
        FIFO_ALMOST_EMPTY_VAL  : integer := 3
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        we                  : in  std_logic;
        data_in             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rd_en               : in  std_logic;  -- renamed from 're'
        data_out            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_out           : out std_logic;
        fifo_full           : out std_logic;
        fifo_empty          : out std_logic;
        fifo_almost_full    : out std_logic;
        fifo_almost_empty   : out std_logic
    );
end entity;

architecture Behavioral of sync_fifo is
    -- Memory array
    type fifo_type is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_mem    : fifo_type := (others => (others => '0'));

    -- Address width based on depth
    constant ADDR_WIDTH : integer := clog2(FIFO_DEPTH);

    -- Pointers and counter
    signal wr_indx    : unsigned(ADDR_WIDTH-1 downto 0)    := (others => '0');
    signal rd_indx    : unsigned(ADDR_WIDTH-1 downto 0)    := (others => '0');
    signal fifo_count : unsigned(ADDR_WIDTH downto 0)      := (others => '0');
    signal dout_reg   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal valid_out_reg : std_logic := '0';
	signal do_write : std_logic := '0';
	signal do_read : std_logic := '0';
	signal handle_counter_fifo : std_logic_vector (1 downto 0) := "00";
begin
    -- Status flags
    fifo_full  <= '1' when fifo_count = to_unsigned(FIFO_DEPTH, fifo_count'length) else '0';
    fifo_empty <= '1' when fifo_count = 0                                 else '0';
	do_write <= '1' when we = '1' and fifo_full = '0' else '0';
	do_read <= '1' when rd_en = '1' and fifo_empty = '0' else '0';
	handle_counter_fifo <= do_write & do_read;
	
    fifo_almost_full  <= '1' when fifo_count > to_unsigned(FIFO_ALMOST_FULL_VAL, fifo_count'length) else '0';
    fifo_almost_empty <= '1' when fifo_count < to_unsigned(FIFO_ALMOST_EMPTY_VAL, fifo_count'length) else '0';

    -- Output assignment
    data_out <= dout_reg;
    valid_out <= valid_out_reg;

    -- FIFO process
    fifo_process : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                wr_indx    <= (others => '0');
                rd_indx    <= (others => '0');
                fifo_count <= (others => '0');
                dout_reg   <= (others => '0');
                valid_out_reg <= '0';
            else
                -- Write
                valid_out_reg <= '0';
                if (do_write = '1') then
                    fifo_mem(to_integer(wr_indx)) <= data_in;
                    wr_indx <= to_unsigned(
                                 (to_integer(wr_indx) + 1) mod FIFO_DEPTH,
                                 wr_indx'length
                               );
                end if;

                -- Read
                if (do_read = '1') then
                    dout_reg <= fifo_mem(to_integer(rd_indx));
                    valid_out_reg <= '1';
                    rd_indx <= to_unsigned(
                                 (to_integer(rd_indx) + 1) mod FIFO_DEPTH,
                                 rd_indx'length
                               );
                end if;
				
				-- handle the counter fifo used for fifo status
				case (handle_counter_fifo) is 
					when "10" =>
						fifo_count <= fifo_count +1;
					when "01" =>
						fifo_count <= fifo_count -1;
					when others => 
						null; -- keep counter value
				end case;
				
            end if;
        end if;
    end process fifo_process;

end architecture;
