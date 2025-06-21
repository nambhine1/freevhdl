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
    -- Place constants and variables *before* `begin` to avoid declaration errors
    constant test_vals : integer_vector := (0, 1, 2, 3, 4, 5, 6, 7, 15, 31, 255);
    constant expected_grays : integer_vector := (
      0, 1, 3, 2, 6, 7, 5, 4, 8, 16, 384
    );

    constant gray_vals : integer_vector := expected_grays;
    constant expected_bins : integer_vector := test_vals;

    variable bin_vec : std_logic_vector(31 downto 0);
    variable gray_vec : std_logic_vector(31 downto 0);
    variable expected_vec : std_logic_vector(31 downto 0);
  begin
    test_runner_setup(runner, runner_cfg);

    if run("Testing clog2") then
      check_equal(clog2(1), 0, "clog2(1)");
      check_equal(clog2(2), 1, "clog2(2)");
      check_equal(clog2(3), 2, "clog2(3)");
      check_equal(clog2(4), 2, "clog2(4)");
      check_equal(clog2(5), 3, "clog2(5)");
      check_equal(clog2(16), 4, "clog2(16)");
      check_equal(clog2(32), 5, "clog2(32)");
      check_equal(clog2(1024), 10, "clog2(1024)");

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
        expected_vec := std_logic_vector(to_unsigned(expected_grays(i), 32));
        gray_vec := binarytogray(bin_vec);
        check_equal(gray_vec, expected_vec, "binary_to_gray failed at i=" & integer'image(i));
      end loop;

    elsif run("Test gray to binary") then
      for i in gray_vals'range loop
        gray_vec := std_logic_vector(to_unsigned(gray_vals(i), 32));
        expected_vec := std_logic_vector(to_unsigned(expected_bins(i), 32));
        bin_vec := graytobinary(gray_vec);
        check_equal(bin_vec, expected_vec, "gray_to_binary failed at i=" & integer'image(i));
      end loop;
    end if;

    test_runner_cleanup(runner);
  end process;
end architecture;
