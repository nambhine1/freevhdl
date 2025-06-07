library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cdc_data_buffer is
end tb_cdc_data_buffer;

architecture Behavioral of tb_cdc_data_buffer is

  constant Latency    : integer := 3;
  constant DATA_WIDTH : integer := 8;

  -- Component Declaration
  component cdc_data_buffer is
    generic (
      Latency    : integer := 3;
      DATA_WIDTH : integer := 8
    );
    port (
      clk_A  : in  std_logic;
      rst_A  : in  std_logic;
      data_A : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      clk_B  : in  std_logic;
      rst_B  : in  std_logic;
      data_B : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component;

  -- Signals
  signal clk    : std_logic := '0';
  signal rst_A  : std_logic := '1';
  signal rst_B  : std_logic := '1';
  signal data_A : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal data_B : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

  -- DUT instantiation
  uut: cdc_data_buffer
    generic map (
      Latency    => Latency,
      DATA_WIDTH => DATA_WIDTH
    )
    port map (
      clk_A  => clk,
      rst_A  => rst_A,
      data_A => data_A,
      clk_B  => clk,
      rst_B  => rst_B,
      data_B => data_B
    );

  -- Clock generation
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
  end process;

  -- Stimulus and assertions
  stim_proc: process
  begin
    -- Reset
    wait for 20 ns;
    rst_A <= '0';
    rst_B <= '0';

    -- Apply test values
    wait for 10 ns; data_A <= x"55";  -- T0
    wait for 10 ns; data_A <= x"AA";  -- T1
    wait for 10 ns; data_A <= x"FF";  -- T2
    wait for 10 ns; data_A <= x"00";  -- T3
  end process;

end Behavioral;
