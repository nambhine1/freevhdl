-- File: math_utils.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package math_utils is
  function clog2(n : integer) return integer;
end package;

package body math_utils is
  function clog2(n : integer) return integer is
    variable res : integer := 0;
    variable val : integer := n - 1;
  begin
    while val > 0 loop
      val := val / 2;
      res := res + 1;
    end loop;
    return res;
  end function;
end package body;