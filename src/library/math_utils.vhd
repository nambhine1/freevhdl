-- File: math_utils.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package math_utils is
  function clog2(n : integer) return integer;
  function max(a, b : integer) return integer;
  function min(a, b : integer) return integer;
  function ispowerof2(a : integer) return boolean;
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

  function max(a, b : integer) return integer is 
  begin
    if (a > b) then
      return a;
    else
      return b;
    end if;
  end function;

  function min(a, b : integer) return integer is
  begin
    if (a < b) then
      return a;
    else 
      return b;
    end if;
  end function;

  function ispowerof2(a : integer) return boolean is
  begin
    if a < 1 then
      return false;
    else
      return ( 
        to_integer( 
          unsigned( 
            std_logic_vector( to_unsigned(a, 32) and 
            std_logic_vector( to_unsigned(a-1, 32) )
          ) 
        ) = 0 
      );
    end if;
  end function;
end package body;
