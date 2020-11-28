-- Sobel_filter - Gaussian approximate - VHDL Code
-- Author : Mehdi Sadeghi
-- Date : 27 Nov 2020
-- Entity Name : sobel_filter
-- Input/Output Type : Stream
-- Do Not ALTER this Code

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.sliding_window_pkg.ALL;

entity sobel_filter is
	generic(
		ROW    : natural := 32;
		COL    : natural := 32
		);
	port(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		stream_in : in  std_logic_vector(7 downto 0);
		busy : out std_logic;
		valid : out std_logic;
		stream_out : out  std_logic_vector(7 downto 0)
		);
end sobel_filter;

architecture behave of sobel_filter is
	
	signal op1 : std_logic_vector(7 downto 0);
	signal op2 : std_logic_vector(7 downto 0);
	signal op3 : std_logic_vector(7 downto 0);
	signal op4 : std_logic_vector(7 downto 0);
	signal op5 : std_logic_vector(7 downto 0);
	signal op6 : std_logic_vector(7 downto 0);
	signal op7 : std_logic_vector(7 downto 0);
	signal op8 : std_logic_vector(7 downto 0);
	signal op9 : std_logic_vector(7 downto 0);
	
	signal A1    : unsigned(10 downto 0);
	signal B1    : unsigned(10 downto 0);
	signal C1    : unsigned(10 downto 0);
	signal A2    : unsigned(10 downto 0);
	signal B2    : unsigned(10 downto 0);
	signal C2    : unsigned(10 downto 0);
	
	signal Reg1  : unsigned(10 downto 0);
	signal Reg2  : unsigned(10 downto 0);
	signal Reg3  : unsigned(10 downto 0);
	
	signal State : std_logic_vector(1 downto 0);
	
	signal count : integer;
	signal en    : std_logic;
	signal ibusy : std_logic := '0';
	signal ivalid : std_logic := '0';
begin

	Inst_SW: sliding_window generic map(COL_LB => COL,
										BWIDTH => 8)
							port map(	CLK => clk,
										pixel_stream => stream_in,
										o1 => op1,
										o2 => op2,
										o3 => op3,
										o4 => op4,
										o5 => op5,
										o6 => op6,
										o7 => op7,
										o8 => op8,
										o9 => op9
									);
	
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
		if (count > (1 + (row * col) + 2 + 1)) then
			ivalid <= '0';
		elsif (count >= (3 + 2 * col + 2 + 1 - 1 + 1)) then
			ivalid <= '1';
		end if;
	end process;
	
	valid <= ivalid;
	
	CAL: process(clk, rst)
		variable vReg1 : unsigned(10 downto 0);
		variable vReg2 : unsigned(10 downto 0);
		variable a     : unsigned(10 downto 0);
		variable b     : unsigned(10 downto 0);
		variable c     : unsigned(10 downto 0);
		variable d     : unsigned(10 downto 0);
		variable e     : unsigned(10 downto 0);
	begin
		if(clk'event and clk = '1') then
			A1    <= (unsigned("000" & op3      ) + NOT(unsigned("000" & op1      ))+1);
			B1    <= (unsigned("00"  & op6 & '0') + NOT(unsigned("00"  & op4 & '0'))+1);
			C1    <= (unsigned("000" & op9      ) + NOT(unsigned("000" & op7      ))+1);
			A2    <= (unsigned("000" & op7      ) + NOT(unsigned("000" & op1      ))+1);
			B2    <= (unsigned("00"  & op8 & '0') + NOT(unsigned("00"  & op2 & '0'))+1);
			C2    <= (unsigned("000" & op9      ) + NOT(unsigned("000" & op3      ))+1);
			
			vReg1  := A1 + B1 + C1;
			vReg2  := A2 + B2 + C2;
			
			if (vReg1(10) = '1') then
			    Reg1 <= NOT(vReg1) + 1;
			else
			    Reg1 <= vReg1;
			end if;
			if (vReg2(10) = '1') then
			    Reg2 <= NOT(vReg2) + 1;
			else
			    Reg2 <= vReg2;
			end if;
			
			if Reg1 >= Reg2 then
				a := Reg1;
				b := Reg2;
			else
				a := Reg2;
				b := Reg1;
			end if;
			
			c  := ('0' & a(10 downto 1)) + ("00"  & a(10 downto 2));
			d  := ('0' & b(10 downto 1)) + ("000" & a(10 downto 3));
			e  := c + d;
			
			if e >= a then
				Reg3 <= e;
			else
				Reg3 <= a;
			end if;
		end if;
	end process;

	stream_out <= (others => '1') when Reg3 > "00011111111" else
				   std_logic_vector(Reg3(7 downto 0));
	
end behave;