-- Unsharpen Filter VHDL Code
-- Author : Mehdi Sadeghi
-- Date : 24 Nov 2020
-- Entity Name : unsharpen_filter
-- Input/Output Type : Stream
-- Do Not ALTER this Code

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity unsharpen_filter is
	generic(
		row : natural := 64;
		col : natural := 64;
		wid : natural := 8
		);
	port(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		stream_in : in  std_logic_vector(wid-1 downto 0);
		busy : out std_logic;
		valid : out std_logic;
		stream_out : out  std_logic_vector(wid-1 downto 0)
		);
end unsharpen_filter;

architecture behave of unsharpen_filter is
	type t_LB_SR is array (0 to col-4) of std_logic_vector(wid-1 downto 0);
	signal LB_SR_1 : t_LB_SR;
	signal LB_SR_2 : t_LB_SR;

	type t_MAT_REG is array (0 to 2, 0 to 2) of std_logic_vector(wid-1 downto 0);
	signal MAT_REG : t_MAT_REG;
	
	signal wire_0 : std_logic_vector(wid-1 downto 0);
	signal wire_1 : std_logic_vector(wid-1 downto 0);
	
	signal count : integer;
	signal en : std_logic;
	signal Areg  : integer range 0 to (2**(wid+2)-1);
	signal Breg  : integer range 0 to (2**(wid+3)-1);
	signal State : std_logic_vector(1 downto 0);
	
	signal ibusy : std_logic := '0';
	signal ivalid : std_logic := '0';
begin

	Reg : process(clk, rst)
	begin
		if(rst = '1') then
			en <= '0';
		elsif rising_edge(clk) then
			en <= start or ibusy;
		end if;
	end process;
	
	process(clk, rst)
	begin
		if(rst = '1') then
			State <= "00";
		elsif rising_edge(clk) then
			State(1) <= (not(start) and ((State(1) and not(State(0))) or (ivalid and not(State(1)) and State(0))));
			State(0) <= (start) or (not(ivalid) and (State(1) xor State(0)));
		end if;
	end process;
	
	ibusy <= State(0) or State(1);
	busy  <= ibusy;
	
	process(clk, rst)
	begin
		if(rst = '1') then
			count <= 0;
		elsif rising_edge(clk) then
			if en = '1' and start = '0' then
				count <= count + 1;
			else
				count <= 0;
			end if;
		end if;
	end process;
	
	process(count)
	begin
		if (count > (1 + (row * col) + 2)) then
			ivalid <= '0';
		elsif (count >= (3 + 2 * col + 2 + 1 - 1)) then
			ivalid <= '1';
		end if;
	end process;
	
	valid <= ivalid;
	
	SW: process(clk)
	begin
		if rising_edge(clk) then
			MAT_REG(2, 2) <= stream_in;
			MAT_REG(2, 1) <= MAT_REG(2, 2);
			MAT_REG(2, 0) <= MAT_REG(2, 1);
			MAT_REG(1, 2) <= LB_SR_1(col-4);
			MAT_REG(1, 1) <= MAT_REG(1, 2);
			MAT_REG(1, 0) <= MAT_REG(1, 1);
			MAT_REG(0, 2) <= LB_SR_2(col-4);
			MAT_REG(0, 1) <= MAT_REG(0, 2);
			MAT_REG(0, 0) <= MAT_REG(0, 1);
		end if;
	end process;
	
	LB: process(clk)
	--	variable i : integer;
	begin
		if rising_edge(clk) then
			for i in 1 to col-4 loop
				LB_SR_1(0) <=  MAT_REG(2, 0);
				LB_SR_1(i) <=  LB_SR_1(i-1);
				LB_SR_2(0) <=  MAT_REG(1, 0);
				LB_SR_2(i) <=  LB_SR_2(i-1);
			end loop;
		end if;
	end process;
	
	CAL: process(clk)
	begin
		if rising_edge(clk) then
			Areg  <= (to_integer(unsigned(MAT_REG(0, 1))) + to_integer(unsigned(MAT_REG(2, 1)))) + (to_integer(unsigned(MAT_REG(1, 0))) + to_integer(unsigned(MAT_REG(1, 2))));
			Breg  <= (5 * to_integer(unsigned(MAT_REG(1, 1))));
			if ((Breg - Areg) < 0) then
				stream_out <= (others => '0');
			elsif ((Breg - Areg) < (2**wid)) then
				stream_out <= std_logic_vector(to_unsigned((Breg - Areg), stream_out'length));
			else
				stream_out <= (others => '1');
			end if;
		end if;
	end process;

end behave;