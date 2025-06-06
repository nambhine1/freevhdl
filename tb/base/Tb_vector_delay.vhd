library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_vector_delay is
end tb_vector_delay;

architecture behavior of tb_vector_delay is

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant DELAY      : integer := 3;
    constant DATA_WIDTH : integer := 32;

    -- DUT Signals
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal data_in  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    -- Instantiate DUT
    uut: entity work.vector_delay
        generic map (
            DELAY => DELAY,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    -- Clock generation process
    clk_process: process
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
    begin
        -- Apply reset
        wait for 2 * CLK_PERIOD;
        rst <= '0';

        -- Send input values 0 to 9
        for i in 0 to 9 loop
            wait until rising_edge(clk);
            data_in <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
        end loop;

        -- Hold input constant after feeding values
        for i in 0 to 5 loop
            wait until rising_edge(clk);
            data_in <= (others => '0');
        end loop;

        -- End simulation
        wait for 5 * CLK_PERIOD;
        report "Simulation finished." severity note;
        wait;
    end process;

end behavior;
