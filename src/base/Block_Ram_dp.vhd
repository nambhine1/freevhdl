library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use vunit_lib.com_types_pkg.all;
use vunit_lib.string_ops_pkg.all;
use vunit_lib.checker_pkg.all;
use vunit_lib.com_pkg.all;
use work.math_utils.all;

entity Block_Ram_dp_tb is
    generic (
        runner_cfg : string
    );
end Block_Ram_dp_tb;

architecture tb of Block_Ram_dp_tb is
    constant DATA_WIDTH : integer := 32;
    constant RAM_DEPTH : integer := 32;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal we_A : std_logic := '0';
    signal add_A : std_logic_vector(clog2(RAM_DEPTH)-1 downto 0) := (others => '0');
    signal din_A : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal dout_A : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal we_B : std_logic := '0';
    signal add_B : std_logic_vector(clog2(RAM_DEPTH)-1 downto 0) := (others => '0');
    signal din_B : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal dout_B : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    clk <= not clk after 5 ns;

    dut : entity work.Block_Ram_dp
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            RAM_DEPTH => RAM_DEPTH
        )
        port map (
            clk => clk,
            rst => rst,
            we_A => we_A,
            add_A => add_A,
            din_A => din_A,
            dout_A => dout_A,
            we_B => we_B,
            add_B => add_B,
            din_B => din_B,
            dout_B => dout_B
        );

    test_runner : process
    begin
        test_runner_setup(runner, runner_cfg);

        if run("test_write_and_read_from_port_a") then
            rst <= '1';
            wait for 10 ns;
            rst <= '0';
            wait for 10 ns;

            we_A <= '1';
            add_A <= std_logic_vector(to_unsigned(0, add_A'length));
            din_A <= X"00000001";
            wait for 10 ns;

            we_A <= '0';
            wait for 10 ns;

            check_equal(dout_A, X"00000001", "Port A read failed");

        elsif run("test_write_and_read_from_port_b") then
            rst <= '1';
            wait for 10 ns;
            rst <= '0';
            wait for 10 ns;

            we_B <= '1';
            add_B <= std_logic_vector(to_unsigned(1, add_B'length));
            din_B <= X"00000002";
            wait for 10 ns;

            we_B <= '0';
            wait for 10 ns;

            check_equal(dout_B, X"00000002", "Port B read failed");

        elsif run("test_write_collision") then
            rst <= '1';
            wait for 10 ns;
            rst <= '0';
            wait for 10 ns;

            we_A <= '1';
            add_A <= std_logic_vector(to_unsigned(2, add_A'length));
            din_A <= X"00000003";
            we_B <= '1';
            add_B <= std_logic_vector(to_unsigned(2, add_B'length));
            din_B <= X"00000004";
            wait for 10 ns;

            we_A <= '0';
            we_B <= '0';
            wait for 10 ns;

            check_equal(dout_A, X"00000003", "Port A write failed during collision");
            add_A <= std_logic_vector(to_unsigned(2, add_A'length));
            wait for 10 ns;
            check_equal(dout_A, X"00000003", "Port A value incorrect after collision");
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;
end tb;
