library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- VUnit
library vunit_lib;
context vunit_lib.vunit_context;

use work.math_utils.all;

entity tb_Block_Ram_dp is
  generic (runner_cfg : string);
end entity;

architecture Behavioral of tb_Block_Ram_dp is
  constant DATA_WIDTH : integer := 32;
  constant RAM_DEPTH  : integer := 32;

  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';
  signal we_A   : std_logic := '0';
  signal add_A  : std_logic_vector(clog2(RAM_DEPTH)-1 downto 0) := (others => '0');
  signal din_A  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal dout_A : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal we_B   : std_logic := '0';
  signal add_B  : std_logic_vector(clog2(RAM_DEPTH)-1 downto 0) := (others => '0');
  signal din_B  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal dout_B : std_logic_vector(DATA_WIDTH-1 downto 0);

  constant CLK_PERIOD : time := 10 ns;
begin

  clk_process : process
  begin
    while true loop
      clk <= '0'; wait for CLK_PERIOD / 2;
      clk <= '1'; wait for CLK_PERIOD / 2;
    end loop;
  end process;

  DUT: entity work.Block_Ram_dp
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      RAM_DEPTH  => RAM_DEPTH
    )
    port map (
      clk    => clk,
      rst    => rst,
      we_A   => we_A,
      add_A  => add_A,
      din_A  => din_A,
      dout_A => dout_A,
      we_B   => we_B,
      add_B  => add_B,
      din_B  => din_B,
      dout_B => dout_B
    );

  main : process
    constant TEST_DATA1 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"AAAAAAAA";
    constant TEST_DATA2 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"55555555";
    constant TEST_DATA3 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"12345678";
    constant TEST_DATA4 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"9ABCDEF0";
    constant TEST_DATA5 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"11111111";
  begin
    test_runner_setup(runner_cfg);

    -- Common initialization
    rst <= '1';
    we_A <= '0';
    we_B <= '0';
    add_A <= (others => '0');
    add_B <= (others => '0');
    din_A <= (others => '0');
    din_B <= (others => '0');
    wait for CLK_PERIOD * 2;
    rst <= '0';
    wait for CLK_PERIOD;

    -- Test 1: Basic write and read on separate addresses
    if run("write_and_read_separate_addresses") then
      -- Write to different addresses on both ports
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(1, add_A'length)); din_A <= TEST_DATA1;
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(2, add_B'length)); din_B <= TEST_DATA2;
      wait for CLK_PERIOD;

      we_A <= '0'; we_B <= '0'; 
      add_A <= std_logic_vector(to_unsigned(1, add_A'length));
      add_B <= std_logic_vector(to_unsigned(2, add_B'length));
      wait for CLK_PERIOD;

      check_equal(dout_A, TEST_DATA1, "Port A did not read expected data at addr 1");
      check_equal(dout_B, TEST_DATA2, "Port B did not read expected data at addr 2");

    -- Test 2: Write collision on same address
    elsif run("simultaneous_write_collision_same_address") then
      -- Write to same address from both ports
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(3, add_A'length)); din_A <= TEST_DATA3;
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(3, add_B'length)); din_B <= TEST_DATA4;
      wait for CLK_PERIOD;

      we_A <= '0'; we_B <= '0'; 
      add_A <= std_logic_vector(to_unsigned(3, add_A'length));
      add_B <= std_logic_vector(to_unsigned(3, add_B'length));
      wait for CLK_PERIOD;

      -- Check which port wins (implementation-dependent)
      check_equal(dout_A, dout_B, "Port A and B outputs differ after write collision");
      
    -- Test 3: Reset functionality
    elsif run("reset_functionality") then
      -- Write to multiple locations
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(4, add_A'length)); din_A <= TEST_DATA1;
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(5, add_B'length)); din_B <= TEST_DATA2;
      wait for CLK_PERIOD;
      
      -- Apply reset
      rst <= '1';
      we_A <= '0';
      we_B <= '0';
      wait for CLK_PERIOD;
      
      -- Check outputs during reset (should be zeros if reset clears outputs)
      check_equal(dout_A, std_logic_vector'(DATA_WIDTH-1 downto 0 => '0'), "Port A not reset");
      check_equal(dout_B, std_logic_vector'(DATA_WIDTH-1 downto 0 => '0'), "Port B not reset");
      
      -- Release reset and verify memory retained values
      rst <= '0';
      wait for CLK_PERIOD;
      
      add_A <= std_logic_vector(to_unsigned(4, add_A'length));
      add_B <= std_logic_vector(to_unsigned(5, add_B'length));
      wait for CLK_PERIOD;
      
      check_equal(dout_A, TEST_DATA1, "Port A lost data after reset");
      check_equal(dout_B, TEST_DATA2, "Port B lost data after reset");

    -- Test 4: Read after write same address
    elsif run("read_after_write_same_address") then
      -- Write and read same address on port A
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(6, add_A'length)); din_A <= TEST_DATA3;
      wait for CLK_PERIOD;
      
      we_A <= '0';
      add_A <= std_logic_vector(to_unsigned(6, add_A'length));
      wait for CLK_PERIOD;
      
      check_equal(dout_A, TEST_DATA3, "Port A read-after-write failed");
      
      -- Write and read same address on port B
      we_B <= '1'; add_B <= std_logic_vector(to_unsigned(7, add_B'length)); din_B <= TEST_DATA4;
      wait for CLK_PERIOD;
      
      we_B <= '0';
      add_B <= std_logic_vector(to_unsigned(7, add_B'length));
      wait for CLK_PERIOD;
      
      check_equal(dout_B, TEST_DATA4, "Port B read-after-write failed");

    -- Test 5: Concurrent read/write on different ports
    elsif run("concurrent_read_write") then
      -- Initialize memory location
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(8, add_A'length)); din_A <= TEST_DATA5;
      wait for CLK_PERIOD;
      we_A <= '0';
      
      -- Concurrent operations:
      -- Port A writes new value to address 8
      -- Port B reads previous value from address 8
      we_A <= '1'; add_A <= std_logic_vector(to_unsigned(8, add_A'length)); din_A <= TEST_DATA1;
      add_B <= std_logic_vector(to_unsigned(8, add_B'length));
      wait for CLK_PERIOD;
      
      we_A <= '0';
      wait for CLK_PERIOD;
      
      -- Verify port B read old value during write
      check_equal(dout_B, TEST_DATA5, "Port B read incorrect value during concurrent write");
      
      -- Verify port A now shows new value
      add_A <= std_logic_vector(to_unsigned(8, add_A'length));
      wait for CLK_PERIOD;
      check_equal(dout_A, TEST_DATA1, "Port A did not store new value");
    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
