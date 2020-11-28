library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.sliding_window_pkg.ALL;

entity sliding_window is
	generic(
		COL_LB : natural := 10;
		BWIDTH : natural := 8
		);
	port(
		CLK          : in  STD_LOGIC;
		pixel_stream : in  STD_LOGIC_VECTOR(BWIDTH-1 downto 0);
		o1,o2,o3,o4,o5,o6,o7,o8,o9 : out STD_LOGIC_VECTOR(BWIDTH-1 downto 0)
		);
end sliding_window;

architecture Behavioral of sliding_window is
	signal r_p4,r_p7 : STD_LOGIC_VECTOR(7 downto 0);
	
	signal p1,p2,p3,p4,p5,p6,p7,p8,p9 : STD_LOGIC_VECTOR(BWIDTH-1 downto 0);

begin
	Inst_line_buffer0: line_buffer generic map(col => (COL_LB - 3), wid => 8) port map(CLK => CLK, input => p4, output => r_p4);
	Inst_line_buffer1: line_buffer generic map(col => (COL_LB - 3), wid => 8) port map(CLK => CLK, input => p7, output => r_p7);

	p_reg :process(CLK)
	begin
		if rising_edge(CLK) then	
			p9	<= pixel_stream	;
			p8	<= p9;
			p7	<= p8;
			p6	<= r_p7;
			p5	<= p6;
			p4	<= p5;
			p3	<= r_p4;
			p2	<= p3;
			p1	<= p2;
		end if;
	end process;
	
	o9 <= p9;
	o8 <= p8;
	o7 <= p7;
	o6 <= p6;
	o5 <= p5;
	o4 <= p4;
	o3 <= p3;
	o2 <= p2;
	o1 <= p1;
	
end Behavioral;

