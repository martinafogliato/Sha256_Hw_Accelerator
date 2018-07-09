--carry save adder

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;

entity csa is 
	port (	A:	in	word;
			B:	in	word;
			C:	in	word;
			S:	out	word;
			Cout:	out	word
	);
end csa; 

architecture struct of csa is

begin

GEN_ADD : for i in 0 to 30 generate
	FullAdd : entity work.fa(behav) port map (A(i), B(i), C(i), S(i), Cout(i+1));
end generate GEN_ADD;

LastFA : entity work.fa(behav) port map (A(31), B(31), C(31), S(31), open);

Cout(0) <= '0';

end struct;
