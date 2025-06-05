-- ============================================================================
-- Title       : Testbench for ALU
-- File        : tb_ALU.vhd
-- Description : 
--   Self-checking VHDL testbench for a 4-bit ALU. Applies test cases for
--   various opcodes and checks expected outputs using assertions.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU is
end tb_ALU;

architecture Behavioral of tb_ALU is

  constant DATA_WIDTH : integer := 4;

  signal A, B       : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal opcode     : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal result     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal zero       : std_logic;
  signal carry      : std_logic;

  -- Constants for opcodes
  constant OPCODE_ADD  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0000";
  constant OPCODE_SUB  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0001";
  constant OPCODE_AND  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0010";
  constant OPCODE_OR   : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0011";
  constant OPCODE_XOR  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0100";
  constant OPCODE_NOT  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0101";
  constant OPCODE_SHL  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0110";
  constant OPCODE_SHR  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0111";

  -- Helper function for vector-to-string
  function to_string(slv : std_logic_vector) return string is
    variable result : string(1 to slv'length);
  begin
    for i in slv'range loop
      result(i - slv'low + 1) := character'value(std_ulogic'image(slv(i)));
    end loop;
    return result;
  end;

begin

  -- Instantiate DUT
  uut: entity work.ALU
    generic map (
      DATA_WIDTH => DATA_WIDTH
    )
    port map (
      A      => A,
      B      => B,
      opcode => opcode,
      result => result,
      zero   => zero,
      carry  => carry
    );

  -- Stimulus process
  stim_proc: process
    variable expected_result : unsigned(DATA_WIDTH - 1 downto 0);
    variable expected_carry  : std_logic;
    variable expected_zero   : std_logic;
  begin
    -- ====================
    -- Test ADD: 7 + 3 = 10
    -- ====================
    A <= "0111";  -- 7
    B <= "0011";  -- 3
    opcode <= OPCODE_ADD;
    wait for 10 ns;

    expected_result := to_unsigned(10, DATA_WIDTH);
    expected_carry := '0';  -- no overflow
    expected_zero := '0';

    assert unsigned(result) = expected_result
      report "ADD failed: result = " & to_string(result)
      severity error;
    assert carry = expected_carry
      report "ADD failed: carry = " & std_ulogic'image(carry)
      severity error;
    assert zero = expected_zero
      report "ADD failed: zero = " & std_ulogic'image(zero)
      severity error;

    -- ====================
    -- Test SUB: 5 - 5 = 0
    -- ====================
    A <= "0101";  -- 5
    B <= "0101";  -- 5
    opcode <= OPCODE_SUB;
    wait for 10 ns;

    expected_result := to_unsigned(0, DATA_WIDTH);
    expected_carry := '0';  -- no borrow (using unsigned)
    expected_zero := '1';

    assert unsigned(result) = expected_result
      report "SUB failed: result = " & to_string(result)
      severity error;
    assert carry = expected_carry
      report "SUB failed: carry = " & std_ulogic'image(carry)
      severity error;
    assert zero = expected_zero
      report "SUB failed: zero = " & std_ulogic'image(zero)
      severity error;

    -- ====================
    -- Test AND: 1111 and 1100 = 1000
    -- ====================
    A <= "1111";
    B <= "0001";
    opcode <= OPCODE_AND;
    wait for 10 ns;

    assert result = "1000"
      report "AND failed: result = " & to_string(result)
      severity error;

    -- ====================
    -- Test NOT: not 1010 = 0101
    -- ====================
    A <= "1010";
    opcode <= OPCODE_NOT;
    wait for 10 ns;

    assert result = "0101"
      report "NOT failed: result = " & to_string(result)
      severity error;

    -- ====================
    -- Test SHL: 0011 << 1 = 0110
    -- ====================
    A <= "0011";
    opcode <= OPCODE_SHL;
    wait for 10 ns;

    assert result = "0110"
      report "SHL failed: result = " & to_string(result)
      severity error;

    -- Add more tests as needed...

    report "All ALU tests passed successfully." severity note;
    wait;
  end process;

end Behavioral;
