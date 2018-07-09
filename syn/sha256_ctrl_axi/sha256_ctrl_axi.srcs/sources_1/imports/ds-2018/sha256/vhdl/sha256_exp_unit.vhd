-- expansion unit to generate 64 Wi from 16 Mi

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;

entity sha256_exp_unit is
	port(
		clk :		in	std_ulogic;
		rst :		in	std_ulogic;
		en	:		in std_ulogic;
		mi	:		in	word;
		sel :		in std_ulogic;
		wi	:		out word
	);

end entity sha256_exp_unit;

architecture arch of sha256_exp_unit is

type wi_array is array(15 downto 0) of word;
signal wi_ff : wi_array;
signal wi_ff_0, sum_out : word;

begin 
	with sel select wi_ff_0 <=
		mi when '0',
		wi_ff(15) when '1',
		(others => '0') when others;

	sum_out <= std_ulogic_vector(unsigned(wi_ff(14)) + unsigned(sigma_lower0(wi_ff(13))) + unsigned(wi_ff(5)) + unsigned(sigma_lower1(wi_ff(0)))); --can be optimized
	wi <= wi_ff_0;

	proc_fifo : process(clk, wi_ff_0)
		begin
			if clk = '1' and clk'event then
				if rst = '1' then
					for i in 0 to 15 loop
						wi_ff(i) <= (others => '0');
					end loop;
				elsif(en='1') then
					wi_ff(0) <= wi_ff_0;
					for i in 1 to 15 loop
						if i = 15 then
							wi_ff(i) <= sum_out;
						else
							wi_ff(i) <= wi_ff(i-1);
						end if;
					end loop;
				end if;
			end if;
	end process;
					
end architecture arch;


