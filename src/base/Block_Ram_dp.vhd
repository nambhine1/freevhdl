library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.math_utils.all;
use IEEE.NUMERIC_STD.ALL;

entity Block_Ram_dp is
  generic (
    DATA_WIDTH : integer := 32;
    RAM_DEPTH  : integer := 32
  );
  Port(
    clk   : in std_logic;
    rst   : in std_logic;
    
    -- Port A
    we_A  : in std_logic;
    add_A : in std_logic_vector (clog2(RAM_DEPTH)-1 downto 0);
    din_A : in std_logic_vector (DATA_WIDTH -1 downto 0);
    dout_A: out std_logic_vector (DATA_WIDTH -1 downto 0);
    
    -- Port B
    we_B  : in std_logic;
    add_B : in std_logic_vector (clog2(RAM_DEPTH) -1 downto 0);
    din_B : in std_logic_vector (DATA_WIDTH -1 downto 0);
    dout_B: out std_logic_vector (DATA_WIDTH -1 downto 0)
  );
end Block_Ram_dp;

architecture Behavioral of Block_Ram_dp is
  signal dout_A_reg : std_logic_vector (DATA_WIDTH -1 downto 0) := (others => '0');
  signal dout_B_reg : std_logic_vector (DATA_WIDTH -1 downto 0) := (others => '0');

  type ram_type is array (0 to RAM_DEPTH -1) of std_logic_vector (DATA_WIDTH -1 downto 0);
  signal ram : ram_type := (others => (others => '0'));

  -- Port B write enable adjusted for collision (Port A has priority)
  signal active_we_B : std_logic;
begin

  active_we_B <= '0' when (we_A = '1' and add_A = add_B and we_B = '1') else we_B;

  dout_A <= dout_A_reg;
  dout_B <= dout_B_reg;

process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      dout_A_reg <= (others => '0');
      dout_B_reg <= (others => '0');
    else
      -- Write logic
      if we_A = '1' then
        ram(to_integer(unsigned(add_A))) <= din_A;
      end if;

      if active_we_B = '1' then
        ram(to_integer(unsigned(add_B))) <= din_B;
      end if;

      -- Read logic
      dout_A_reg <= ram(to_integer(unsigned(add_A)));
      dout_B_reg <= ram(to_integer(unsigned(add_B)));
    end if;
  end if;
end process;


end Behavioral;
