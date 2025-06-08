library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_axi_stream_frame_gen is
end entity;

architecture sim of tb_axi_stream_frame_gen is

    -- Constants
    constant TUSER_WIDTH  : integer := 5;
    constant TDATA_WIDTH  : integer := 32;
    constant IMAGE_WIDTH  : integer := 4; -- Reduced for simulation
    constant IMAGE_HEIGHT : integer := 3;

    -- DUT signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    
    signal s_valid : std_logic := '0';
    signal s_ready : std_logic;
    signal s_data  : std_logic_vector(TDATA_WIDTH-1 downto 0) := (others => '0');
    signal s_user  : std_logic_vector(TUSER_WIDTH-1 downto 0) := (others => '0');
    signal s_last  : std_logic := '0';
    
    signal m_valid : std_logic;
    signal m_ready : std_logic := '1';
    signal m_data  : std_logic_vector(TDATA_WIDTH-1 downto 0);
    signal m_user  : std_logic_vector(TUSER_WIDTH-1 downto 0);
    signal m_last  : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate DUT
    uut: entity work.axi_stream_frame_gen
        generic map (
            TUSER_WIDTH => TUSER_WIDTH,
            TDATA_WIDTH => TDATA_WIDTH,
            IMAGE_WIDTH => IMAGE_WIDTH,
            IMAGE_HEIGHT => IMAGE_HEIGHT
        )
        port map (
            clk     => clk,
            rst     => rst,
            s_valid => s_valid,
            s_ready => s_ready,
            s_data  => s_data,
            s_user  => s_user,
            s_last  => s_last,
            m_valid => m_valid,
            m_ready => m_ready,
            m_data  => m_data,
            m_user  => m_user,
            m_last  => m_last
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
        variable pixel_count : integer := 0;
    begin
        -- Reset
        rst <= '1';
        wait for 2*clk_period;
        rst <= '0';
        wait for clk_period;

        -- Send IMAGE_WIDTH * IMAGE_HEIGHT samples
        for row in 0 to IMAGE_HEIGHT - 1 loop
            for col in 0 to IMAGE_WIDTH - 1 loop
                wait until rising_edge(clk);
                s_valid <= '1';
                s_data <= std_logic_vector(to_unsigned(pixel_count, TDATA_WIDTH));
                pixel_count := pixel_count + 1;
            end loop;
        end loop;

        report "Simulation completed successfully." severity note;
        wait;
    end process;

end architecture;
