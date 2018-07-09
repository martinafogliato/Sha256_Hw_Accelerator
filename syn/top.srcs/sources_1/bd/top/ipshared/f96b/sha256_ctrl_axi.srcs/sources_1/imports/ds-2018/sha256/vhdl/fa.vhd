--full adder

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

entity fa is
	port (	A:	in	std_logic;
			B:	in	std_logic;
			Ci:	in	std_logic;
			S:	out	std_logic;
			Co:	out	std_logic);
end FA; 

architecture behav of fa is

begin

  S <= A xor B xor Ci;
  Co <= (A and B) or (B and Ci) or (A and Ci);
  
end behav;
