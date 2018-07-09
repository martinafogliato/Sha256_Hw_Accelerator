-- MASTER-ONLY: DO NOT MODIFY THIS FILE
library ieee;
use ieee.std_logic_1164.all;

package axi_pkg is

	constant axi_resp_okay:		std_ulogic_vector(1 downto 0) :=	"00";
	constant axi_resp_exokay:	std_ulogic_vector(1 downto 0) :=	"01";
	constant axi_resp_slverr:	std_ulogic_vector(1 downto 0) :=	"10";
	constant axi_resp_decerr:	std_ulogic_vector(1 downto 0) :=	"11";

end package axi_pkg;

