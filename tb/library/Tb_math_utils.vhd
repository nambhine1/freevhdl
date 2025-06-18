library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library VUnit;
use VUnit.TestRunner.all;
use work.math_utils.all;

entity tb_math_utils is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_math_utils is
begin
  main : process
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

    elsif run("Testing max") then
      check_equal(max(5, 10), 10, "max(5,10)");
      check_equal(max(-5, 10), 10, "max(-5,10)");
      check_equal(max(100, 100), 100, "max(100,100)");
      check_equal(max(-10, -5), -5, "max(-10,-5)");
      check_equal(max(0, 0), 0, "max(0,0)");

    elsif run("Testing min") then
      check_equal(min(5, 10), 5, "min(5,10)");
      check_equal(min(-5, 10), -5, "min(-5,10)");
      check_equal(min(100, 100), 100, "min(100,100)");
      check_equal(min(-10, -5), -10, "min(-10,-5)");
      check_equal(min(0, 0), 0, "min(0,0)");

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
    end if;

    test_runner_cleanup(runner);
  end process;
end architecture;
