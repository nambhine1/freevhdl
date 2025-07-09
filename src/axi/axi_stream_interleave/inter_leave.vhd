library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity interleave_yuv is
  generic (
      DATA_WIDTH_g : integer := 24  -- Width of each data word (Y, U, V)
  );
  port (
       clk       : in  std_logic;                                  -- Clock input
       rst       : in  std_logic;                                  -- Synchronous active-high reset
       
       -- Input stream for Y component
       s_valid_y : in  std_logic;                                  -- Valid signal from Y input
       s_ready_y : out std_logic;                                  -- Ready signal to Y input
       s_data_y  : in  std_logic_vector(DATA_WIDTH_g - 1 downto 0); -- Y data bus
       
       -- Input stream for U component
       s_valid_u : in  std_logic;
       s_ready_u : out std_logic;
       s_data_u  : in  std_logic_vector(DATA_WIDTH_g - 1 downto 0);
       
       -- Input stream for V component
       s_valid_v : in  std_logic;
       s_ready_v : out std_logic;
       s_data_v  : in  std_logic_vector(DATA_WIDTH_g - 1 downto 0);
       
       -- Output interleaved YUV stream
       m_valid   : out std_logic;
       m_ready   : in  std_logic;
       m_data    : out std_logic_vector(DATA_WIDTH_g - 1 downto 0)
   );
end interleave_yuv;

architecture Behavioral of interleave_yuv is
    -- Signals for output stream control
    signal m_valid_int : std_logic := '0';
    signal m_data_int  : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');
    
    -- FIFO interface signals for Y channel
    signal fifo_y_valid : std_logic := '0';
    signal fifo_y_ready : std_logic := '0';
    signal fifo_y_data  : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');
    
    -- FIFO interface signals for U channel
    signal fifo_u_valid : std_logic := '0';
    signal fifo_u_ready : std_logic := '0';
    signal fifo_u_data  : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');
    
    -- FIFO interface signals for V channel
    signal fifo_v_valid : std_logic := '0';
    signal fifo_v_ready : std_logic := '0';
    signal fifo_v_data  : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');
    
    -- State machine type and state signal
    type state_t is (IDLE, SEND_Y, SEND_U, SEND_V);
    signal state : state_t := IDLE;
    
    -- Registered outputs for backpressure handling
    signal m_valid_reg : std_logic := '0';
    signal m_data_reg  : std_logic_vector(DATA_WIDTH_g - 1 downto 0) := (others => '0');

begin

  -- Assign registered outputs to ports
  m_data  <= m_data_reg;
  m_valid <= m_valid_reg;

  -- Process to handle interleaving data from FIFOs
  interleave_proc: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        m_valid_int <= '0';
        m_data_int  <= (others => '0');
        state       <= IDLE;
        fifo_y_ready <= '0';
        fifo_u_ready <= '0';
        fifo_v_ready <= '0';
      else
        -- Default values for ready and output signals
        m_valid_int <= '0';
        m_data_int  <= (others => '0');
        fifo_y_ready <= '0';
        fifo_u_ready <= '0';
        fifo_v_ready <= '0';

        case state is
          when IDLE =>
            fifo_y_ready <= m_ready;
            fifo_u_ready <= '0';
            fifo_v_ready <= '0';
            state <= SEND_Y;

          when SEND_Y =>
            if fifo_y_valid = '1' then
              m_data_int  <= fifo_y_data;
              m_valid_int <= '1';
              fifo_y_ready <= '0';
              fifo_u_ready <= m_ready;
              fifo_v_ready <= '0';
              state <= SEND_U;
            else
              fifo_y_ready <= m_ready;
              m_valid_int <= '0';
            end if;

          when SEND_U =>
            if fifo_u_valid = '1' then
              m_data_int  <= fifo_u_data;
              m_valid_int <= '1';
              fifo_y_ready <= '0';
              fifo_u_ready <= '0';
              fifo_v_ready <= m_ready;
              state <= SEND_V;
            else
              fifo_u_ready <= m_ready;
              m_valid_int <= '0';
            end if;

          when SEND_V =>
            if fifo_v_valid = '1' then
              m_data_int  <= fifo_v_data;
              m_valid_int <= '1';
              fifo_y_ready <= m_ready;
              fifo_u_ready <= '0';
              fifo_v_ready <= '0';
              state <= SEND_Y;
            else
              fifo_v_ready <= m_ready;
              m_valid_int <= '0';
            end if;

          when others =>
            null;
        end case;
      end if;
    end if;
  end process;

  -- Process for backpressure and output register update
  backpressure_proc: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        m_valid_reg <= '0';
        m_data_reg  <= (others => '0');
      else
        if m_valid_int = '1' then
          m_data_reg  <= m_data_int;
          m_valid_reg <= m_valid_int;
        elsif m_valid_reg = '1' and m_ready = '1' then
          m_valid_reg <= '0';
        end if;
      end if;
    end if;
  end process;

  -- FIFO instantiation for Y channel
  fifo_inst_y: entity work.axi_stream_fifo
    generic map (
      FIFO_DEPTH => 5,
      DATA_WIDTH => DATA_WIDTH_g
    )
    port map (
      clk     => clk,
      rst     => rst,
      s_valid => s_valid_y,
      s_data  => s_data_y,
      s_ready => s_ready_y,
      m_valid => fifo_y_valid,
      m_data  => fifo_y_data,
      m_ready => fifo_y_ready
    );

  -- FIFO instantiation for U channel
  fifo_inst_u: entity work.axi_stream_fifo
    generic map (
      FIFO_DEPTH => 5,
      DATA_WIDTH => DATA_WIDTH_g
    )
    port map (
      clk     => clk,
      rst     => rst,
      s_valid => s_valid_u,
      s_data  => s_data_u,
      s_ready => s_ready_u,
      m_valid => fifo_u_valid,
      m_data  => fifo_u_data,
      m_ready => fifo_u_ready
    );

  -- FIFO instantiation for V channel
  fifo_inst_v: entity work.axi_stream_fifo
    generic map (
      FIFO_DEPTH => 5,
      DATA_WIDTH => DATA_WIDTH_g
    )
    port map (
      clk     => clk,
      rst     => rst,
      s_valid => s_valid_v,
      s_data  => s_data_v,
      s_ready => s_ready_v,
      m_valid => fifo_v_valid,
      m_data  => fifo_v_data,
      m_ready => fifo_v_ready
    );

end Behavioral;