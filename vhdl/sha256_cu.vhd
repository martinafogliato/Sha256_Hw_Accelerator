--sha256 control unit, fsm form

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use work.sha256_pkg.all;

entity sha256_cu is
	port (	
			clk :			in std_ulogic;
			rst :			in std_ulogic;
			msg_valid :		in std_ulogic;
			msg_last :		in std_ulogic;
			hash_ack :		in std_ulogic;
			hash_valid :	out	std_ulogic;
			mux_sel :		out std_ulogic;
			mux_sel_AE :	out	std_ulogic;
			word_sel :		out std_ulogic;
			mux_sel_H :		out std_ulogic_vector(1 downto 0);
			K_index :		out natural range 0 to 64;
			msg_ready :		out std_ulogic;
			en :			out std_ulogic;
			en_AE :			out std_ulogic;
			en_DM :			out std_ulogic;
			en_DM_AE :		out std_ulogic;
			en_delta :		out std_ulogic;
			rst_AE :		out std_ulogic;
			rst_DM :		out	std_ulogic
	);
end entity sha256_cu;

architecture fsm of sha256_cu is

	---------------SHA256 Control FSM-------------------------------------------
	-- IDLE : waits for incoming words to hash
	-- INIT : initialize A to H to DM0 to DM7
	-- COMPRESSION1 : compression algorithm for W0..W15
	-- COMPRESSION2 : compression algorithm for W16..W63
	-- WAIT_HASH1 : start_K computing the new DM1, DM2, DM3, DM5, DM6, DM7
	-- WAIT_HASH2 : compute DM0, DM4 and get ready for the next chunck (if any)
	-- HASH_READY : signal the hash is valid

	----------------------------------------------------------------------------

	type state_type is (IDLE, INIT, COMPRESSION1, COMPRESSION2, WAIT_HASH1, WAIT_HASH2, HASH_READY);
	signal current_state, next_state: state_type;
	signal K_index_sig : natural range 0 to 64;
	signal mux_sel_H_sig : natural range 0 to 3;
	signal start_K, rst_K : std_ulogic;

	begin

		en_delta <= '1' when (current_state = IDLE or current_state = COMPRESSION2 or current_state = WAIT_HASH1 or msg_valid = '1') else
					'0';

		sync_proc : process(clk)
			begin
				if(clk='1' and clk'event) then
					if(rst='1') then
						current_state <= IDLE;
					else
						current_state <= next_state;
					end if;
				end if;
		end process sync_proc;

		-- process to create a counter to index K constants
		K_index_proc : process(clk)
			begin
				if(clk='1' and clk'event) then
					if(rst='1' or rst_K='1') then
						K_index_sig <= 0;
					else
						if(start_K = '1') then
							K_index_sig <= K_index_sig + 1;

							if(K_index_sig = 63) then
								K_index_sig <= 0;
							end if;
						end if;
					end if;
				end if;
		end process K_index_proc;
		
		K_index <= K_index_sig;
		mux_sel_H <= std_ulogic_vector(to_unsigned(mux_sel_H_sig, 2));

		output_proc : process(current_state, K_index_sig, msg_valid)
			begin
				--default values
				hash_valid <= '0';
				mux_sel <= '1';
				mux_sel_AE <= '0';
				word_sel <= '1';
				mux_sel_H_sig <= 2;
				msg_ready <= '1';
				en <= '1';
				en_AE <= '1';
				en_DM <= '0';
				en_DM_AE <= '0';
				rst_AE <= '0';
				start_K <= '0';
				rst_K <= '0';
				rst_DM <= '0';

				case(current_state) is
					when IDLE =>
						word_sel <= '0';
						mux_sel_H_sig <= 0;
						rst_DM <= '1';
						if(msg_valid = '0') then
							en <= '0';
							rst_AE <= '1';
							en_AE <= '0';
							mux_sel <= '1';
							rst_K <= '1';
						else
							en <= '1';
							rst_AE <= '0';
							en_AE <= '1';
							mux_sel_AE <= '1';
							mux_sel <= '0';
							mux_sel_H_sig <= 1;
							start_K <= '1';
						end if;

					when INIT =>
							mux_sel_AE <= '1';
							word_sel <= '0';
							mux_sel_H_sig <= 2;
							start_K <= '1';
						if(msg_valid = '0') then
							en <= '0';
							en_AE <= '0';
							start_K <= '0';
						end if;

					when COMPRESSION1 =>
							mux_sel_AE <= '1';
							word_sel <= '0';
							start_K <= '1';
						if(msg_valid = '0') then
							en <= '0';
							en_AE <= '0';
							start_K <= '0';
						end if;

					when COMPRESSION2 =>
						mux_sel_AE <= '1';
						msg_ready <= '0';
						start_K <= '1';
						if(K_index_sig > 61) then
							en_DM <= '1';
							if(K_index_sig = 63) then
								mux_sel_AE <= '0';
								mux_sel_H_sig <= 3;
							end if;
						end if;
					
					when WAIT_HASH1 =>
						msg_ready <= '0';
						mux_sel <= '0';
						word_sel <= '0';
						mux_sel_AE <= '1';
						mux_sel_H_sig <= 1;
						en_DM <= '1';
					
					when WAIT_HASH2 =>
						word_sel <= '0';
						mux_sel_H_sig <= 0;
						mux_sel_AE <= '1';
						if(msg_valid = '0') then
							en_DM_AE <= '1';
							en <= '0';
							en_AE <= '0';
							mux_sel <= '1';
							rst_K <= '1';
						else
							en <= '1';
							en_AE <= '0';
							mux_sel <= '0';
							mux_sel_H_sig <= 1;
							start_K <= '1';
						end if;

					when HASH_READY =>
						hash_valid <= '1';
						word_sel <= '0';
						mux_sel_H_sig <= 0;
						--rst_DM <= '1';
						if(msg_valid = '0') then
							en <= '0';
							rst_AE <= '1';
							en_AE <= '0';
							mux_sel <= '1';
							rst_K <= '1';
						else
							en <= '1';
							rst_AE <= '0';
							en_AE <= '1';
							mux_sel_AE <= '1';
							mux_sel <= '0';
							mux_sel_H_sig <= 1;
							start_K <= '1';
							rst_DM <= '1';
						end if;

					when others =>
				end case;
				
		end process output_proc;

		next_state_proc: process(current_state, K_index_sig, msg_valid, hash_ack, msg_last)
			begin
				case(current_state) is
					when IDLE =>
						if(msg_valid = '1') then
							next_state <= INIT;
						else
							next_state <= IDLE;
						end if;

					when INIT =>
							next_state <= COMPRESSION1;

					when COMPRESSION1 =>
						if(K_index_sig = 16) then					
							next_state <= COMPRESSION2;
						else
							next_state <= COMPRESSION1;
						end if;
				
					when COMPRESSION2 =>
						if(K_index_sig = 63) then					
							next_state <= WAIT_HASH1;
						else
							next_state <= COMPRESSION2;
						end if;
					
					when WAIT_HASH1 =>
						next_state <= WAIT_HASH2;

					when WAIT_HASH2 =>
						if(msg_last = '1') then
							next_state <= HASH_READY;
						elsif(msg_valid = '1') then
							next_state <= INIT;
						else
							next_state <= WAIT_HASH2;
						end if;

					when HASH_READY =>
						if(hash_ack = '1') then
							if(msg_valid = '1') then
								next_state <= INIT;
							else
								next_state <= IDLE;
							end if;
						else
							next_state <= HASH_READY;
						end if;

					when others =>
						next_state <= IDLE;
				end case;

		end process next_state_proc;

		
end architecture fsm;
