library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  generic (
    DATA_WIDTH : integer := 4  -- width of data inputs/outputs
  );
  port (
    A      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    B      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    opcode : in  std_logic_vector(3 downto 0);  -- fixed width 4 bits for opcode
    result : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    zero   : out std_logic;
    carry  : out std_logic
  );
end ALU;

architecture Behavioral of ALU is

  constant OPCODE_WIDTH : integer := 4;  -- fixed opcode width (can be used internally)

  signal result_reg : unsigned(DATA_WIDTH downto 0); -- one extra bit for carry

begin

  alu_calculations : process(A, B, opcode)
    variable A_u : unsigned(DATA_WIDTH - 1 downto 0);
    variable B_u : unsigned(DATA_WIDTH - 1 downto 0);
  begin
    A_u := unsigned(A);
    B_u := unsigned(B);

    if opcode = "0000" then  -- ADD
      result_reg <= ('0' & A_u) + ('0' & B_u);

    elsif opcode = "0001" then  -- SUB
      result_reg <= ('0' & A_u) - ('0' & B_u);

    elsif opcode = "0010" then  -- AND
      result_reg(DATA_WIDTH - 1 downto 0) <= A_u and B_u;
      result_reg(DATA_WIDTH) <= '0';

    elsif opcode = "0011" then  -- OR
      result_reg(DATA_WIDTH - 1 downto 0) <= A_u or B_u;
      result_reg(DATA_WIDTH) <= '0';

    elsif opcode = "0100" then  -- XOR
      result_reg(DATA_WIDTH - 1 downto 0) <= A_u xor B_u;
      result_reg(DATA_WIDTH) <= '0';

    elsif opcode = "0101" then  -- NOT (only A)
      result_reg(DATA_WIDTH - 1 downto 0) <= not A_u;
      result_reg(DATA_WIDTH) <= '0';

    elsif opcode = "0110" then  -- SHL (shift left)
      result_reg(DATA_WIDTH - 1 downto 0) <= shift_left(A_u, 1);
      result_reg(DATA_WIDTH) <= '0';

    elsif opcode = "0111" then  -- SHR (shift right)
      result_reg(DATA_WIDTH - 1 downto 0) <= shift_right(A_u, 1);
      result_reg(DATA_WIDTH) <= '0';

    else
      result_reg <= (others => '0');
    end if;
  end process;

  -- Outputs
  result <= std_logic_vector(result_reg(DATA_WIDTH - 1 downto 0));
  zero   <= '1' when result_reg(DATA_WIDTH - 1 downto 0) = x"00000000" else '0';
  carry  <= result_reg(DATA_WIDTH);

end Behavioral;
