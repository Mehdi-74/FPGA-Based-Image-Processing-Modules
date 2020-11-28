library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sliding_window_pkg is
	
	type t_matrix is array(natural range <>, natural range <>) of INTEGER;
	
	component sliding_window is
	generic(
		COL_LB : natural := 7;
		BWIDTH : natural := 8
		);
	port(
		CLK          : in  STD_LOGIC;
		pixel_stream : in  STD_LOGIC_VECTOR(BWIDTH-1 downto 0);
		o1,o2,o3,o4,o5,o6,o7,o8,o9 : out STD_LOGIC_VECTOR(BWIDTH-1 downto 0)
		);
	end component;
	
	component line_buffer is
		generic(
			col  : natural := 2;
			wid  : natural := 32
		);
		Port(
			CLK    : in  STD_LOGIC;
			input  : in  STD_LOGIC_VECTOR(wid-1 downto 0);
			output : out STD_LOGIC_VECTOR(wid-1 downto 0)
		);
	end component;

end package;