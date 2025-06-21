library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library vunit_lib;
context vunit_lib.vunit_context;

use work.math_utils.all;

entity tb_math_utils is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_math_utils is
begin
  main : process
    constant test_vals : integer_vector := (0, 1, 2, 3, 4, 5, 6, 7, 15, 31, 127, 128, 255);
    variable bin_vec    : std_logic_vector(31 downto 0);
    variable gray_vec   : std_logic_vector(31 downto 0);
    variable round_trip : std_logic_vector(31 downto 0);
  begin
    test_runner_setup(runner, runner_cfg);

    if run("Testing clog2") then
      check_equal(clog2(1), 0);
      check_equal(clog2(2), 1);
      check_equal(clog2(3), 2);
      check_equal(clog2(4), 2);
      check_equal(clog2(5), 3);
      check_equal(clog2(16), 4);
      check_equal(clog2(32), 5);
      check_equal(clog2(1024), 10);

    elsif run("Testing max_value") then
      check_equal(max_value(5, 10), 10);
      check_equal(max_value(-5, 10), 10);
      check_equal(max_value(100, 100), 100);
      check_equal(max_value(-10, -5), -5);
      check_equal(max_value(0, 0), 0);

    elsif run("Testing min") then
      check_equal(min_value(5, 10), 5);
      check_equal(min_value(8, 10), 8);

    elsif run("Testing ispowerof2") then
      check_true(ispowerof2(1));
      check_true(ispowerof2(2));
      check_true(ispowerof2(4));
      check_true(ispowerof2(1024));
      check_false(ispowerof2(0));
      check_false(ispowerof2(3));
      check_false(ispowerof2(5));
      check_false(ispowerof2(6));
      check_false(ispowerof2(1023));
      check_false(ispowerof2(-1));
      check_false(ispowerof2(-4));

    elsif run("Test binary to gray") then
      for i in test_vals'range loop
        bin_vec := std_logic_vector(to_unsigned(test_vals(i), 32));
        gray_vec := binarytogray(bin_vec);
        round_trip := graytobinary(gray_vec);
        check_equal(round_trip, bin_vec, "binary_to_gray round-trip failed at i=" & integer'image(i));
      end loop;

    elsif run("Test gray to binary") then
      for i in test_vals'range loop
        bin_vec := std_logic_vector(to_unsigned(test_vals(i), 32));
        gray_vec := binarytogray(bin_vec);
        check_equal(graytobinary(gray_vec), bin_vec, "gray_to_binary failed at i=" & integer'image(i));
      end loop;

    end if;

    test_runner_cleanup(runner);
  end process;
end architecture;
