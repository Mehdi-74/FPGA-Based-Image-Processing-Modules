library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity line_buffer is
	generic(
		col  : natural := 2;
		wid  : natural := 8
	);
    Port(
		CLK    : in  STD_LOGIC;
		input  : in  STD_LOGIC_VECTOR(wid-1 downto 0);
		output : out STD_LOGIC_VECTOR(wid-1 downto 0)
	);
end line_buffer;

architecture RTL of line_buffer is
	type t_Shift_Register is array (0 to col-1) of std_logic_vector(wid-1 downto 0);
	signal SR : t_Shift_Register;
begin

	process(CLK)
	begin	
		if (rising_edge(CLK)) then
			SR(0) <=  input;
			for i in 1 to col-1	loop
				SR(i) <= SR(i-1);
			end loop;
		end if;
	end process;
	
	output <= SR(col-1);
	
end RTL;

