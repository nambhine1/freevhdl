library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_stream_fifo_tb is
end axi_stream_fifo_tb;

architecture behavior of axi_stream_fifo_tb is

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : integer := 32;
    constant FIFO_DEPTH : integer := 8;

    -- Signals
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';

    signal s_valid  : std_logic := '0';
    signal s_data   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_ready  : std_logic;

    signal m_valid  : std_logic;
    signal m_data   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal m_ready  : std_logic := '0';

begin

    -- Instantiate the FIFO under test
    uut: entity work.axi_stream_fifo
        generic map (
            FIFO_DEPTH => FIFO_DEPTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk      => clk,
            rst      => rst,
            s_valid  => s_valid,
            s_data   => s_data,
            s_ready  => s_ready,
            m_valid  => m_valid,
            m_data   => m_data,
            m_ready  => m_ready
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
        variable input_count : integer := 0;
        variable read_count  : integer := 0;
        variable wait_cycles : integer;
    begin
        -- Reset sequence
        rst <= '1';
        s_valid <= '0';
        m_ready <= '0';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- === NORMAL WRITE PHASE ===
        report "Starting normal write phase at " & time'image(now);
        input_count := 0;
        while input_count < FIFO_DEPTH loop
            s_valid <= '1';
            s_data <= std_logic_vector(to_unsigned(input_count + 1, DATA_WIDTH));
            wait until rising_edge(clk);
            if s_ready = '1' then
                report "Written value: " & integer'image(input_count + 1) & " at " & time'image(now);
                input_count := input_count + 1;
            else
                report "FIFO full, write stalled at " & time'image(now);
            end if;
        end loop;
        s_valid <= '0';

        wait for 3 * CLK_PERIOD;

        -- === READ PHASE ===
        report "Starting read phase at " & time'image(now);
        m_ready <= '1';
        read_count := 0;
        wait_cycles := 0;

        -- Read all available data, wait max 2 * FIFO_DEPTH cycles to avoid infinite wait
        while (read_count < FIFO_DEPTH) and (wait_cycles < 2 * FIFO_DEPTH) loop
            wait until rising_edge(clk);
            if m_valid = '1' then
                report "Read value: " & integer'image(to_integer(unsigned(m_data))) & " at " & time'image(now);
                read_count := read_count + 1;
            end if;
            wait_cycles := wait_cycles + 1;
        end loop;
        m_ready <= '0';

        wait for 3 * CLK_PERIOD;

        -- === OVERFLOW TEST PHASE ===
        report "Starting overflow test phase at " & time'image(now);
        s_valid <= '1';
        for i in 0 to FIFO_DEPTH + 2 loop  -- Try to write more than FIFO_DEPTH items
            s_data <= std_logic_vector(to_unsigned(100 + i, DATA_WIDTH));
            wait until rising_edge(clk);
            if s_ready = '1' then
                report "Overflow test write accepted: " & integer'image(100 + i) & " at " & time'image(now);
            else
                report "Overflow test write rejected (FIFO full): " & integer'image(100 + i) & " at " & time'image(now);
            end if;
        end loop;
        s_valid <= '0';

        wait for 3 * CLK_PERIOD;

        -- === DRAIN FIFO PHASE ===
        report "Draining FIFO after overflow test at " & time'image(now);
        m_ready <= '1';
        read_count := 0;
        wait_cycles := 0;
        -- Drain until no more data or max cycles
        while (wait_cycles < 2 * FIFO_DEPTH) loop
            wait until rising_edge(clk);
            if m_valid = '1' then
                report "Drained value: " & integer'image(to_integer(unsigned(m_data))) & " at " & time'image(now);
                read_count := read_count + 1;
                wait_cycles := 0; -- Reset wait_cycles when data received
            else
                wait_cycles := wait_cycles + 1;
            end if;
        end loop;
        m_ready <= '0';

        -- Finish simulation
        report "Testbench completed at " & time'image(now);
        wait;
    end process;

end behavior;
