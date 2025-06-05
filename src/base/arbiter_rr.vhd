library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity arbiter_rr is
  generic (
    REQUEST_WIDTH : integer := 4
  );
  Port (
    clk         : in  std_logic;
    rst         : in  std_logic;  -- Synchronous reset (active high)
    request     : in  std_logic_vector (REQUEST_WIDTH - 1 downto 0);
    grant       : out std_logic_vector (REQUEST_WIDTH - 1 downto 0);
    valid_grant : out std_logic
  );
end arbiter_rr;

architecture Behavioral of arbiter_rr is
    signal grant_reg   : std_logic_vector(grant'range) := (others => '0');
    signal valid_reg   : std_logic := '0';
    signal last_granted_index : integer range 0 to REQUEST_WIDTH - 1 := 0;
begin

    grant <= grant_reg;
    valid_grant <= valid_reg;
    
    round_robin : process (clk) 
      variable found : boolean := true;
      variable i : integer := 0;
      begin
         if rising_edge (clk) then
           if rst = '1' then
            grant_reg <= (others => '0');
            valid_reg <= '0';
            found := false;
            i := 0;
         else
            found := false;
            grant_reg <= (others => '0');
            valid_reg <= '0';
            for index in 0 to REQUEST_WIDTH -1 loop
                i := (last_granted_index + index + 1) mod REQUEST_WIDTH;
                if (request(i) = '1' and found = false) then
                    grant_reg(i) <= '1';
                    valid_reg <= '1';
                    found := true;
                    last_granted_index <= i;
                end if;
            end loop;
         end if;
         end if;
      end process round_robin;

end Behavioral;
