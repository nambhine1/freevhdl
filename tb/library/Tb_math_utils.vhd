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
    variable runner : runner_t;
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
      check_equal(max_value(5, 10), 10, "max_value(5,10)");
      check_equal(max_value(-5, 10), 10, "max_value(-5,10)");
      check_equal(max_value(100, 100), 100, "max_value(100,100)");
      check_equal(max_value(-10, -5), -5, "max_value(-10,-5)");
      check_equal(max_value(0, 0), 0, "max_value(0,0)");

    elsif run("Testing min_value") then
      check_equal(min_value(5, 10), 5, "min_value(5,10)");
      check_equal(min_value(8, 10), 8, "min_value(8,10)");

    elsif run("Testing ispowerof2") then
      check_true(ispowerof2(1), "ispowerof2(1)");
      check_true(ispowerof2(2), "ispowerof2(2)");
      check_true(ispowerof2(4), "ispowerof2(4)");
      check_true(ispowerof2(1024), "ispowerof2(1024)");
      check_false(ispowerof2(0), "ispowerof2(0)");
      check_false(ispowerof2(3), "ispowerof2(3)");
      check_false(ispowerof2(5), "ispowerof2(5)");
      check_false(ispowerof2(6), "ispowerof2(6)");
      check_false(ispowerof2(1023), "ispowerof2(1023)");
      check_false(ispowerof2(-1), "ispowerof2(-1)");
      check_false(ispowerof2(-4), "ispowerof2(-4)");

    elsif run("Test binary to gray") then
      -- Test values and their expected Gray codes
      constant test_vals : integer_vector := (0, 1, 2, 3, 4, 7, 15, 31, 255);
      constant expected_grays : integer_vector := (
        0, 1, 3, 2, 6, 4, 8, 16, 383
      );
      variable bin_vec : std_logic_vector(31 downto 0);
      variable gray_vec : std_logic_vector(31 downto 0);
      variable expected_gray_vec : std_logic_vector(31 downto 0);

      for i in test_vals'range loop
        bin_vec := std_logic_vector(to_unsigned(test_vals(i), 32));
        expected_gray_vec := std_logic_vector(to_unsigned(expected_grays(i), 32));

        gray_vec := binary_to_gray(bin_vec);

        check_equal(gray_vec, expected_gray_vec,
          "binary_to_gray failed for input " & integer'image(test_vals(i)));

        -- Round-trip: gray_to_binary(binary_to_gray(x)) = x
        check_equal(gray_to_binary(gray_vec), bin_vec,
          "round-trip binary_to_gray->gray_to_binary failed for input " & integer'image(test_vals(i)));
      end loop;

    elsif run("Test gray to binary") then
      -- Test values and their Gray codes for gray_to_binary
      constant gray_vals : integer_vector := (0, 1, 3, 2, 6, 4, 8, 16, 383);
      constant expected_bins : integer_vector := (
        0, 1, 2, 3, 4, 7, 15, 31, 255
      );
      variable gray_vec : std_logic_vector(31 downto 0);
      variable bin_vec : std_logic_vector(31 downto 0);
      variable expected_bin_vec : std_logic_vector(31 downto 0);

      for i in gray_vals'range loop
        gray_vec := std_logic_vector(to_unsigned(gray_vals(i), 32));
        expected_bin_vec := std_logic_vector(to_unsigned(expected_bins(i), 32));

        bin_vec := gray_to_binary(gray_vec);

        check_equal(bin_vec, expected_bin_vec,
          "gray_to_binary failed for input " & integer'image(gray_vals(i)));

        -- Round-trip: binary_to_gray(gray_to_binary(x)) = x
        check_equal(binary_to_gray(bin_vec), gray_vec,
          "round-trip gray_to_binary->binary_to_gray failed for input " & integer'image(gray_vals(i)));
      end loop;

    end if;

    test_runner_cleanup(runner);
  end process;
end architecture;
