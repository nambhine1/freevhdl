library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
  generic (
    DATA_WIDTH : integer := 4
  );
  Port (
    A      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    B      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    opcode : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    result : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    zero   : out std_logic;
    carry  : out std_logic
  );
end ALU;

architecture Behavioral of ALU is

  -- Constants for opcodes
  constant OPCODE_ADD  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0000";
  constant OPCODE_SUB  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0001";
  constant OPCODE_AND  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0010";
  constant OPCODE_OR   : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0011";
  constant OPCODE_XOR  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0100";
  constant OPCODE_NOT  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0101";
  constant OPCODE_SHL  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0110";
  constant OPCODE_SHR  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0111";

  -- Internal signals
  signal result_reg : unsigned(DATA_WIDTH downto 0); -- one extra bit for carry
begin

  alu_calculations : process(A, B, opcode)
    variable A_u : unsigned(DATA_WIDTH - 1 downto 0);
    variable B_u : unsigned(DATA_WIDTH - 1 downto 0);
  begin
    A_u := unsigned(A);
    B_u := unsigned(B);

    case opcode is
      when OPCODE_ADD =>
        result_reg <= ('0' & A_u) + ('0' & B_u);

      when OPCODE_SUB =>
        result_reg <= ('0' & A_u) - ('0' & B_u);

      when OPCODE_AND =>
        result_reg(DATA_WIDTH - 1 downto 0) <= A_u and B_u;
        result_reg(DATA_WIDTH) <= '0';

      when OPCODE_OR =>
        result_reg(DATA_WIDTH - 1 downto 0) <= A_u or B_u;
        result_reg(DATA_WIDTH) <= '0';

      when OPCODE_XOR =>
        result_reg(DATA_WIDTH - 1 downto 0) <= A_u xor B_u;
        result_reg(DATA_WIDTH) <= '0';

      when OPCODE_NOT =>
        result_reg(DATA_WIDTH - 1 downto 0) <= not A_u;
        result_reg(DATA_WIDTH) <= '0';

      when OPCODE_SHL =>
        result_reg(DATA_WIDTH - 1 downto 0) <= shift_left(A_u, 1);
        result_reg(DATA_WIDTH) <= '0';

      when OPCODE_SHR =>
        result_reg(DATA_WIDTH - 1 downto 0) <= shift_right(A_u, 1);
        result_reg(DATA_WIDTH) <= '0';

      when others =>
        result_reg <= (others => '0');
    end case;
  end process;

  -- Output assignments
  result <= std_logic_vector(result_reg(DATA_WIDTH - 1 downto 0));
  zero   <= '1' when result_reg(DATA_WIDTH - 1 downto 0) = "0000" else '0';
  carry  <= result_reg(DATA_WIDTH);  -- only used for ADD/SUB

end Behavioral;
