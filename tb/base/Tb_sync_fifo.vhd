------------------------------------------------------------------
-- Testbench for updated sync_fifo (with rd_en)
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_utils.ALL;

entity tb_sync_fifo is
end tb_sync_fifo;

architecture Behavioral of tb_sync_fifo is
    -- Match DUT generics but reduce depth for simulation
    constant DATA_WIDTH        : integer := 16;
    constant FIFO_DEPTH        : integer := 8;
    constant ALMOST_FULL_VAL   : integer := 6;
    constant ALMOST_EMPTY_VAL  : integer := 2;
    constant CLK_PERIOD        : time    := 10 ns;

    -- Signals
    signal clk               : std_logic := '0';
    signal rst               : std_logic := '1';
    signal we                : std_logic := '0';
    signal rd_en             : std_logic := '0';
    signal data_in           : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_full         : std_logic;
    signal fifo_empty        : std_logic;
    signal fifo_almost_full  : std_logic;
    signal fifo_almost_empty : std_logic;
    signal valid_out         : std_logic;

begin
    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Instantiate DUT
    uut: entity work.sync_fifo
        generic map (
            DATA_WIDTH             => DATA_WIDTH,
            FIFO_DEPTH             => FIFO_DEPTH,
            FIFO_ALMOST_FULL_VAL   => ALMOST_FULL_VAL,
            FIFO_ALMOST_EMPTY_VAL  => ALMOST_EMPTY_VAL
        )
        port map (
            clk                => clk,
            rst                => rst,
            we                 => we,
            data_in            => data_in,
            rd_en              => rd_en,
            data_out           => data_out,
            valid_out          => valid_out,
            fifo_full          => fifo_full,
            fifo_empty         => fifo_empty,
            fifo_almost_full   => fifo_almost_full,
            fifo_almost_empty  => fifo_almost_empty
        );

    -- Stimulus process
    stimulus: process
        variable i : integer;
    begin
        -- Reset FIFO
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Idle check
        assert fifo_empty = '1'
            report "FIFO not empty after reset" severity error;

        -- Write entries
        for i in 0 to FIFO_DEPTH-1 loop
            data_in <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            we <= '1';
            wait for CLK_PERIOD;
            we <= '0';
            wait for CLK_PERIOD;

            if i = FIFO_DEPTH-1 then
                assert fifo_full = '1'
                    report "FIFO should be full" severity error;
            elsif i >= ALMOST_FULL_VAL-1 then
                assert fifo_almost_full = '1'
                    report "Almost full not asserted" severity warning;
            end if;
        end loop;

        -- Attempt write when full
        data_in <= X"AAAA";
        we <= '1'; wait for CLK_PERIOD; we <= '0'; wait for CLK_PERIOD;

        -- Read entries
        for i in 0 to FIFO_DEPTH-1 loop
            rd_en <= '1';
            wait for CLK_PERIOD;
            rd_en <= '0';
            wait for CLK_PERIOD;

            assert data_out = std_logic_vector(to_unsigned(i, DATA_WIDTH))
                report "Data mismatch: got " & integer'image(to_integer(unsigned(data_out))) severity error;

            if (FIFO_DEPTH-1 - i) <= ALMOST_EMPTY_VAL then
                assert fifo_almost_empty = '1'
                    report "Almost empty not asserted" severity warning;
            end if;
        end loop;
        
        
             -- Write entries
        for i in 0 to FIFO_DEPTH-1 loop
            data_in <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            we <= '1';
            wait for CLK_PERIOD;
            we <= '0';
            wait for CLK_PERIOD;

            if i = FIFO_DEPTH-1 then
                assert fifo_full = '1'
                    report "FIFO should be full" severity error;
            elsif i >= ALMOST_FULL_VAL-1 then
                assert fifo_almost_full = '1'
                    report "Almost full not asserted" severity warning;
            end if;
        end loop;
        
        -- Read entries
        for i in 0 to FIFO_DEPTH-1 loop
            rd_en <= '1';
            wait for CLK_PERIOD;
            rd_en <= '0';
            wait for CLK_PERIOD;

            assert data_out = std_logic_vector(to_unsigned(i, DATA_WIDTH))
                report "Data mismatch: got " & integer'image(to_integer(unsigned(data_out))) severity error;

            if (FIFO_DEPTH-1 - i) <= ALMOST_EMPTY_VAL then
                assert fifo_almost_empty = '1'
                    report "Almost empty not asserted" severity warning;
            end if;
        end loop;
        

        -- Final empty check
        assert fifo_empty = '1'
            report "FIFO not empty after reads" severity error;

        report "Testbench completed successfully" severity note;
        wait;
    end process;
end Behavioral;