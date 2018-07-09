----------------------------------
--SHA256 functions package
--sha256_pkg.vhd
--Martina Fogliato
----------------------------------


library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_textio.all;

library std;
	use std.textio.all;


----------------------------------
--types and subtypes definitions
----------------------------------

package sha256_pkg is

	subtype word is std_ulogic_vector(31 downto 0);
	type word_vector is array(integer range <>) of word;
	subtype sha_msg is std_ulogic_vector(511 downto 0);
	subtype sha_hash is std_ulogic_vector(255 downto 0);
	type sha_array is array(integer range <>) of sha_msg;

----------------------------------
--array of round constants
----------------------------------

	constant K_constants :  word_vector(0 to 63) := (
		x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
		x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
		x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
		x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
		x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
		x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
		x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
		x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
	);

----------------------------------
--array of initial hash values
----------------------------------
	constant H_init : word_vector(0 to 7) := (
		x"6a09e667",
		x"bb67ae85",
		x"3c6ef372",
		x"a54ff53a",
		x"510e527f",
		x"9b05688c",
		x"1f83d9ab",
		x"5be0cd19"
	);


----------------------------------
--function definitions
----------------------------------

function shr(x : word; n : natural) return word;
function rotr(x : word; n : natural) return word;
function rotl(x : word; n : natural) return word;
function Ch(x,y,z : word) return word;
function Maj(x,y,z : word) return word;
function sigma_lower0(x : word) return std_ulogic_vector;
function sigma_lower1(x : word) return std_ulogic_vector;
function sigma_upper0(x : word) return std_ulogic_vector;
function sigma_upper1(x : word) return std_ulogic_vector;
function expand_msg_blocks(w : word_vector(15 downto 0)) return word_vector;
function break_chunks(msg : sha_msg) return word_vector;
function return_chunk(msg : sha_msg; i : natural) return std_ulogic_vector;
procedure compression(variable a, b, c, d, e, f, g, h, t1, t2, exp_w : inout word; i : in natural);

--function sha256 for debug purposes
procedure sha256_onechunk(msg : in sha_msg; variable h0, h1, h2, h3, h4, h5, h6, h7 : inout word);
function sha256(blocks : sha_array; length : natural) return std_ulogic_vector;

end sha256_pkg;

package body sha256_pkg is
	
----------------------------------
--function implementations
----------------------------------

	function shr(x : word; n : natural) return word is
		begin
			return std_ulogic_vector(shift_right(unsigned(x), n));
	end function;

	function rotr(x : word; n : natural) return word is
		begin
			return std_ulogic_vector(rotate_right(unsigned(x), n));
	end function;

	function rotl(x : word; n : natural) return word is
		begin
			return std_ulogic_vector(rotate_left(unsigned(x), n));
	end function;


	function Ch(x,y,z : word) return std_ulogic_vector is
		begin	
			return (x and y) xor (not(x) and z);
	end function;

	function Maj(x,y,z : word) return std_ulogic_vector is
		begin
			return (x and y) xor (x and z) xor (y and z);
	end function;

	function sigma_lower0(x : word) return std_ulogic_vector is
		begin
			return rotr(x, 7) xor rotr(x, 18) xor shr(x, 3);
	end function;

	function sigma_lower1(x : word) return std_ulogic_vector is
		begin
			return rotr(x, 17) xor rotr(x, 19) xor shr(x, 10);
	end function;

	function sigma_upper0(x : word) return std_ulogic_vector is
		begin
			return rotr(x, 2) xor rotr(x, 13) xor rotr(x, 22);
	end function;

	function sigma_upper1(x : word) return std_ulogic_vector is
		begin
			return rotr(x, 6) xor rotr(x, 11) xor rotr(x, 25);
	end function;

	function expand_msg_blocks(w : word_vector(15 downto 0)) return word_vector is
		variable exp_w : word_vector(63 downto 0);

		begin
			for i in 0 to 63 loop 
				if i < 16 then
					exp_w(i) := w(i);
				else
					exp_w(i) := std_ulogic_vector(unsigned(exp_w(i-16)) + unsigned(sigma_lower0(exp_w(i-15))) + unsigned(exp_w(i-7)) + unsigned(sigma_lower1(exp_w(i-2))));
				end if;
			end loop;
			return exp_w;
	end function;

	function break_chunks(msg : sha_msg) return word_vector is
		variable w : word_vector(15 downto 0);

		begin
			for i in 0 to 15 loop
				w(i) := msg(512-(i*32+1) downto 512-(i*32+32));
			end loop;
			return w;
	end function;

	function return_chunk(msg : sha_msg; i : natural) return std_ulogic_vector is
		begin
			return msg(512-(i*32+1) downto 512-(i*32+32));
	end function;

	procedure compression(variable a, b, c, d, e, f, g, h, t1, t2, exp_w : inout word; i : in natural) is	
			begin
				t2 := std_ulogic_vector(unsigned(sigma_upper0(a)) + unsigned(Maj(a, b, c)));
				t1 := std_ulogic_vector(unsigned(h) + unsigned(sigma_upper1(e)) + unsigned(Ch(e, f, g)) + unsigned(K_constants(i)) + unsigned(exp_w));
				h := g;
				g := f;
				f := e;
				e := std_ulogic_vector(unsigned(d) + unsigned(t1));
				d := c;
				c := b;
				b := a;
				a := std_ulogic_vector(unsigned(t1) + unsigned(t2));
	end procedure;
		
			
--full sha256 implementation for debug purposes

	procedure sha256_onechunk(msg : in sha_msg; variable h0, h1, h2, h3, h4, h5, h6, h7 : inout word) is
		variable w : word_vector(15 downto 0);
		variable exp_w : word_vector(63 downto 0);
		variable a, b, c, d, e, f, g, h, t1, t2 : word;
		--variable myline : line;
		--file myfile: text open WRITE_MODE is "/dev/stdout";

		begin
			w := break_chunks(msg);
			exp_w := expand_msg_blocks(w);

			a := h0;
			b := h1;
			c := h2;
			d := h3;
			e := h4;
			f := h5;
			g := h6;
			h := h7;


			for i in 0 to 63 loop
				-- useful debug prints
				--write(myline,string'(" sigma_upper(a) 0x"));
				--write(myline,sigma_upper0(a));
				--rite(myline,string'(" Maj 0x"));
				--write(myline,Maj(a,b,c));
				--rite(myline,string'(" sigma_upper(e) 0x"));
				--write(myline,sigma_upper1(e));
				--rite(myline,string'(" Ch 0x"));
				--write(myline,Ch(e,f,g));
				--rite(myline,string'(" K 0x"));
				--write(myline,K_constants(i));
				--rite(myline,string'(" W 0x"));
				--write(myline,exp_w(i));
				
				compression(a, b, c, d, e, f, g, h, t1, t2, exp_w(i), i);
				
				--rite(myline,string'(" a 0x"));
				--write(myline,a);
				--rite(myline,string'(" b 0x"));
				--write(myline,b);
				--rite(myline,string'(" c 0x"));
				--write(myline,c);
				--rite(myline,string'(" d 0x"));
				--write(myline,d);
				--rite(myline,string'(" e 0x"));
				--write(myline,e);
				--rite(myline,string'(" f 0x"));
				--write(myline,f);
				--rite(myline,string'(" g 0x"));
				--write(myline,g);
				--rite(myline,string'(" h 0x"));
				--write(myline,h);
				--riteline(myfile,myline);
			end loop;

			h0 := std_ulogic_vector(unsigned(h0) + unsigned(a));
			h1 := std_ulogic_vector(unsigned(h1) + unsigned(b));
			h2 := std_ulogic_vector(unsigned(h2) + unsigned(c));
			h3 := std_ulogic_vector(unsigned(h3) + unsigned(d));
			h4 := std_ulogic_vector(unsigned(h4) + unsigned(e));
			h5 := std_ulogic_vector(unsigned(h5) + unsigned(f));
			h6 := std_ulogic_vector(unsigned(h6) + unsigned(g));
			h7 := std_ulogic_vector(unsigned(h7) + unsigned(h));

	end procedure;

	function sha256(blocks : sha_array; length : natural) return std_ulogic_vector is
		variable h0, h1, h2, h3, h4, h5, h6, h7 : word;
		--variable myline : line;
		--file myfile: text open WRITE_MODE is "/dev/stdout";
		begin
			h0 := H_init(0);
			h1 := H_init(1);
			h2 := H_init(2);
			h3 := H_init(3);
			h4 := H_init(4);
			h5 := H_init(5);
			h6 := H_init(6);
			h7 := H_init(7);

			for i in length-1 downto 0 loop
				--rite(myline,string'(" h0 0x"));
				--write(myline,h0);
				--rite(myline,string'(" h1 0x"));
				--write(myline,h1);
				--rite(myline,string'(" h2 0x"));
				--write(myline,h2);
				--rite(myline,string'(" h3 0x"));
				--write(myline,h3);
				--rite(myline,string'(" h4 0x"));
				--write(myline,h4);
				--rite(myline,string'(" h5 0x"));
				--write(myline,h5);
				--rite(myline,string'(" h6 0x"));
				--write(myline,h6);
				--rite(myline,string'(" h7 0x"));
				--write(myline,h7);
				--riteline(myfile,myline);

				sha256_onechunk(blocks(i), h0, h1, h2, h3, h4, h5, h6, h7);
				--rite(myline,string'(" h0 0x"));
				--write(myline,h0);
				--rite(myline,string'(" h1 0x"));
				--write(myline,h1);
				--rite(myline,string'(" h2 0x"));
				--write(myline,h2);
				--rite(myline,string'(" h3 0x"));
				--write(myline,h3);
				--rite(myline,string'(" h4 0x"));
				--write(myline,h4);
				--rite(myline,string'(" h5 0x"));
				--write(myline,h5);
				--rite(myline,string'(" h6 0x"));
				--write(myline,h6);
				--rite(myline,string'(" h7 0x"));
				--write(myline,h7);
				--riteline(myfile,myline);
			end loop;

			return h0 & h1 & h2 & h3 & h4 & h5 & h6 & h7;
	end function sha256;
end package body sha256_pkg;




