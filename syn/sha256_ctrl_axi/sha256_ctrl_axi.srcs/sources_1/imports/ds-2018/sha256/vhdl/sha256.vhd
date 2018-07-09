--sha256 wrapper

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;

entity sha256 is
	port(
			clk :		in std_ulogic;
			arstn :		in std_ulogic;
			msg_valid :	in std_ulogic;
			msg_last :	in std_ulogic;
			hash_ack :	in std_ulogic;
			msg_word :	in word;
			msg_ready :	out std_ulogic;
			hash_valid :out std_ulogic;
			hash :		out	sha_hash
	);
			
end entity sha256;

architecture struct of sha256 is

signal mux_sel, mux_sel_AE, word_sel, en, en_AE, en_DM, en_DM_AE, en_delta, rst_AE, rst_DM : std_ulogic;
signal mux_sel_H : std_ulogic_vector(1 downto 0);
signal K_index : natural range 0 to 64;
signal rst : std_ulogic;

	begin

	rst_proc : process(clk)
		begin
			if(clk='1' and clk'event) then
				rst <= not(arstn);
			end if;
	end process rst_proc;

	cu : entity work.sha256_cu(fsm) port map (clk, rst, msg_valid, msg_last, hash_ack, hash_valid, mux_sel, mux_sel_AE, word_sel, mux_sel_H, K_index, msg_ready, en, en_AE, en_DM, en_DM_AE, en_delta, rst_AE, rst_DM);
	dp : entity work.sha256_core(arch) port map (clk, rst, rst_AE, rst_DM, mux_sel, mux_sel_AE, word_sel,  mux_sel_H, K_index, msg_word, en, en_AE , en_DM, en_DM_AE, en_delta, hash);

end architecture struct;
