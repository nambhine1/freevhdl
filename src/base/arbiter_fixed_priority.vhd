library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity arbiter_fixed_priority is
  generic (
    REQUEST_WIDTH : integer := 3
  );
  port (
    clk         : in  std_logic;
    rst         : in  std_logic; 
    request     : in  std_logic_vector(REQUEST_WIDTH - 1 downto 0);
    grant       : out std_logic_vector(REQUEST_WIDTH - 1 downto 0);
    valid_grant : out std_logic
  );
end arbiter_fixed_priority;

architecture Behavioral of arbiter_fixed_priority is

  -- Internal signals
  signal grant_reg       : std_logic_vector(REQUEST_WIDTH - 1 downto 0) := (others => '0');
  signal valid_grant_reg : std_logic := '0';

begin

  -- Output assignments
  grant       <= grant_reg;
  valid_grant <= valid_grant_reg;

  -- Assert REQUEST_WIDTH at elaboration time
  assert (REQUEST_WIDTH > 0)
    report "REQUEST_WIDTH must be greater than 0."
    severity failure;

  -- Arbitration logic: fixed priority
  process(clk)
    variable priority_given : boolean := false;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        grant_reg       <= (others => '0');
        valid_grant_reg <= '0';
      else
        grant_reg       <= (others => '0');
        valid_grant_reg <= '0';
        priority_given  := false;

        for i in 0 to REQUEST_WIDTH - 1 loop
          if request(i) = '1' and not priority_given then
            grant_reg(i)       <= '1';
            valid_grant_reg    <= '1';
            priority_given     := true;
          end if;
        end loop;
      end if;
    end if;
  end process;

end Behavioral;
