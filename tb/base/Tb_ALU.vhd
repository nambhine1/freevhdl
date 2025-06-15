library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_ALU is
  generic (runner_cfg : string);
end tb_ALU;

architecture Behavioral of tb_ALU is

  constant DATA_WIDTH : integer := 4;

  signal A, B       : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal opcode     : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal result     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal zero       : std_logic;
  signal carry      : std_logic;

  -- Opcode constants
  constant OPCODE_ADD  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0000";
  constant OPCODE_SUB  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0001";
  constant OPCODE_AND  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0010";
  constant OPCODE_OR   : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0011";
  constant OPCODE_XOR  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0100";
  constant OPCODE_NOT  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0101";
  constant OPCODE_SHL  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0110";
  constant OPCODE_SHR  : std_logic_vector(DATA_WIDTH - 1 downto 0) := "0111";

begin

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

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    if run("test_add") then
      A <= "0111"; B <= "0011"; opcode <= OPCODE_ADD; wait for 10 ns;
      check_equal(result, 2#1010#, "ADD result mismatch");
      check_equal(carry, '0', "ADD carry mismatch");
      check_equal(zero,  '0', "ADD zero flag mismatch");

    elsif run("test_sub") then
      A <= "0101"; B <= "0101"; opcode <= OPCODE_SUB; wait for 10 ns;
      check_equal(result, 2#0000#, "SUB result mismatch");
      check_equal(carry, '0', "SUB carry mismatch");
      check_equal(zero,  '1', "SUB zero flag mismatch");

    elsif run("test_and") then
      A <= "1111"; B <= "1000"; opcode <= OPCODE_AND; wait for 10 ns;
      check_equal(result, 2#1000#, "AND result mismatch");

    elsif run("test_or") then
      A <= "1010"; B <= "0101"; opcode <= OPCODE_OR; wait for 10 ns;
      check_equal(result, 2#1111#, "OR result mismatch");

    elsif run("test_xor") then
      A <= "1100"; B <= "1010"; opcode <= OPCODE_XOR; wait for 10 ns;
      check_equal(result, 2#0110#, "XOR result mismatch");

    elsif run("test_not") then
      A <= "1010"; opcode <= OPCODE_NOT; wait for 10 ns;
      check_equal(result, 2#0101#, "NOT result mismatch");

    elsif run("test_shl") then
      A <= "0011"; opcode <= OPCODE_SHL; wait for 10 ns;
      check_equal(result, 2#0110#, "SHL result mismatch");

    elsif run("test_shr") then
      A <= "1000"; opcode <= OPCODE_SHR; wait for 10 ns;
      check_equal(result, 2#0100#, "SHR result mismatch");

    end if;

    test_runner_cleanup(runner);
    wait;
  end process;

end Behavioral;
