--sha256 core datapath

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;

entity sha256_core is
	port(
		clk	:		in	std_ulogic;
		rst	:		in	std_ulogic;
		rst_AE :	in	std_ulogic;
		rst_DM :	in	std_ulogic;
		mux_sel :	in	std_ulogic;
		mux_sel_AE:	in	std_ulogic;
		word_sel :	in	std_ulogic;
		mux_sel_H :	in	std_ulogic_vector(1 downto 0);
		K_index:	in	natural range 0 to 64;
		msg_word :	in	word;
		en :		in	std_ulogic;
		en_AE :		in	std_ulogic;
		en_DM :		in	std_ulogic;
		en_DM_AE :		in	std_ulogic;
		en_delta :		in std_ulogic;
		hash :		out	sha_hash
	);
end entity sha256_core;

architecture arch of sha256_core is
	signal mux_out_array : word_vector(7 downto 0);
	signal A, B, C, D, E, F, G, H : word;
	signal DM : word_vector(7 downto 0);
	signal DM1_tmp, DM5_tmp, CA, SA, CE, SE : word;
	signal a_sum, e_sum, carry_csa_delta0, sum_csa_delta0, carry_rst_delta0, sum_rst_delta0, sum_csa_delta1, carry_csa_delta1, sum_csa_delta2, carry_csa_delta2 : word;
	signal wi : word;
	-- to solve "not globally static" error
	signal csa_delta0_in, Maj_a0_out, Ch_out, sigmaa, sigmae: word;

	begin

		--muxes to select B, C, D, F, G, H

		mux_out_array(1) <= A when (mux_sel='1') else DM(1);
		mux_out_array(2) <= B when (mux_sel='1') else DM(2);
		mux_out_array(3) <= C when (mux_sel='1') else DM(3);
		mux_out_array(5) <= E when (mux_sel='1') else DM(5);
		mux_out_array(6) <= F when (mux_sel='1') else DM(6);
		
		with mux_sel_H select mux_out_array(7) <=
			F when "10",
			DM(6) when "01",
			DM(7) when "00",
			DM(5) when "11",
			(others => '0') when others;

		--muxes to init A and E and sum H0 and H4 at the end

		mux_out_array(0) <= DM(0) when (mux_sel_AE='0') else (others => '0');
		mux_out_array(4) <= DM(4) when (mux_sel_AE='0') else (others => '0');
		
		--muxes to set to 0 the output of the first CSA during initialization

		sum_rst_delta0 <= sum_csa_delta0 when rst_AE = '0' else (others => '0');
		carry_rst_delta0 <= carry_csa_delta0 when rst_AE = '0' else (others => '0');

		--registers A, B, C, D, E, F, G, H

		reg_proc: process(clk)
			begin
				if(clk='1' and clk'event) then
					if(rst_AE='1' or rst='1') then
						A <= (others => '0');
						E <= (others => '0');
						B <= (others => '0');
						C <= (others => '0');
						D <= (others => '0');
						F <= (others => '0');
						G <= (others => '0');
						H <= H_init(7);
					else
						if (en='1') then
							B <= mux_out_array(1);
							C <= mux_out_array(2);
							D <= mux_out_array(3);
							F <= mux_out_array(5);
							G <= mux_out_array(6);
							H <= mux_out_array(7);
						end if;
						if (en_AE = '1') then
							A <= a_sum;
							E <= e_sum;
						end if;
					end if;
				end if;
		end process reg_proc;
	
		-- csa and expansion unit to compute delta in the previous clock cycle

		exp_unit: entity work.sha256_exp_unit(arch) port map(clk, rst, en_delta, msg_word, word_sel, wi);
		csa_delta0_in <= K_constants(K_index);
		csa_delta0: entity work.csa(struct) port map(csa_delta0_in, wi, H, sum_csa_delta0, carry_csa_delta0);
		csa_delta1: entity work.csa(struct) port map(carry_rst_delta0, sum_rst_delta0, mux_out_array(0), sum_csa_delta1, carry_csa_delta1);
		csa_delta2: entity work.csa(struct) port map(carry_rst_delta0, sum_rst_delta0, mux_out_array(4), sum_csa_delta2, carry_csa_delta2);

		-- register CA, SA, CE, SE

		reg_csa : process(clk)
			begin
				if(clk='1' and clk'event) then
					if(rst='1') then
						CA <= (others => '0');
						SA <= (others => '0');
						CE <= (others => '0');
						SE <= (others => '0');
					elsif(en_delta='1') then
						CA <= carry_csa_delta1;
						SA <= sum_csa_delta1;
						CE <= carry_csa_delta2;
						SE <= sum_csa_delta2;
					end if;
				end if;
		end process reg_csa;

		-- cpa to compute next values of A and E
		-- intermediate signals to solve "not globally static error"
		Maj_a0_out <= Maj(A, B, C);
		Ch_out <= Ch(E, F, G);
		sigmaa <= sigma_upper0(A);
		sigmae <= sigma_upper1(E);

		a_sum <= std_ulogic_vector(unsigned(sigma_upper0(A)) + unsigned(Maj_a0_out) + unsigned(SA) + unsigned(CA) + unsigned(Ch_out) + unsigned(sigma_upper1(E)));
		
		e_sum <= std_ulogic_vector(unsigned(CE) + unsigned(Ch_out) + unsigned(sigma_upper1(E)) + unsigned(SE) + unsigned(D));


		-- round logic
		
		reg_round_logic : process(clk)
			begin
				if(clk='1' and clk'event) then
					if(rst='1' or rst_DM = '1') then 
						-- initialization to the constant hash initial values
						DM(0) <= H_init(0);
						DM(1) <= H_init(1);
						DM(2) <= H_init(2);
						DM(3) <= H_init(3);
						DM(4) <= H_init(4);
						DM(5) <= H_init(5);
						DM(6) <= H_init(6);
						DM(7) <= H_init(7);
					else
						-- shift registers
						if (en_DM='1') then
							DM(1) <= DM1_tmp;
							DM(2) <= DM(1);
							DM(3) <= DM(2);
							DM(5) <= DM5_tmp;
							DM(6) <= DM(5);
							DM(7) <= DM(6);
						end if;
						-- different enable for A and E
						if(en_DM_AE = '1') then
							DM(0) <= A;
							DM(4) <= E;
						end if;

					end if;
				end if;
		end process reg_round_logic;

		DM1_tmp <= word(unsigned(DM(3)) + unsigned(A));
		DM5_tmp <= word(unsigned(DM(7)) + unsigned(E));


		--output

		hash <= DM(0) & DM(1) & DM(2) & DM(3) & DM(4) & DM(5) & DM(6) & DM(7);

end architecture arch;
