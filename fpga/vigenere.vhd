library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- rozhrani Vigenerovy sifry
entity vigenere is
   port(
         CLK : in std_logic;
         RST : in std_logic;
         DATA : in std_logic_vector(7 downto 0);
         KEY : in std_logic_vector(7 downto 0);

         CODE : out std_logic_vector(7 downto 0)
    );
end vigenere;

-- V souboru fpga/sim/tb.vhd naleznete testbench, do ktereho si doplnte
-- znaky vaseho loginu (velkymi pismeny) a znaky klice dle vaseho prijmeni.

architecture behavioral of vigenere is

    -- Sem doplnte definice vnitrnich signalu, prip. typu, pro vase reseni,
    -- jejich nazvy doplnte tez pod nadpis Vigenere Inner Signals v souboru
    -- fpga/sim/isim.tcl. Nezasahujte do souboru, ktere nejsou explicitne
    -- v zadani urceny k modifikaci.
	 
	 signal shift: std_logic_vector(7 downto 0);
	 signal Add: std_logic_vector(7 downto 0);
	 signal Dec: std_logic_vector(7 downto 0);

	 type tState is (plus, minus);
	 signal state: tState := plus;
	 signal nextState: tState := minus;

	 signal hshtg : std_logic_vector(7 downto 0);
	 signal fsmOutput: std_logic_vector (1 downto 0);


begin

    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.
	

	--shift
	
	 process (DATA, KEY) is
	 begin
		shift <= KEY - 64;
	 end process;

	 --add,dec
	 
	 process (shift, DATA) is
		 variable tmp_1: std_logic_vector(7 downto 0);
		 variable tmp_2: std_logic_vector(7 downto 0);
	 begin
		tmp_1 := DATA + shift;
		tmp_2 := DATA - shift;
		if (tmp_1 > 90) then
			tmp_1 := tmp_1 - 26;
		end if;
		if (tmp_2 < 65) then
			tmp_2 := tmp_2 + 26;
		end if;
		if (DATA > 47 and DATA <58) then
			tmp_1 := "00100011";
		end if;
		if (DATA > 47 and DATA <58) then
			tmp_2 := "00100011";
		end if;

		Add <= tmp_1;
		Dec <= tmp_2;
	 end process;	

	--presentStateLogic
	process(CLK, RST) is
	begin
		if RST = '1' then
			state <= plus;
		elsif (CLK 'event) and (CLK='1') then
			state <= nextstate;
		end if;
	end process;

	--nextStateLogic
	process(state, DATA, RST) is
	begin

		case state is
			when plus => nextState <= minus;
			when minus => nextState <= plus;
		end case;
	end process;


	--output
	process(state, Data, RST) is
	begin

		case state is
			when plus => fsmOutput <= "01";
			when minus => fsmOutput <= "10";
		end case;

		if RST = '1' then
			fsmOutput <= "11";
		end if;

		if (DATA > 47 and DATA < 58) then
			fsmOutput <= "11";
		end if;

	end process;

	--fsmOutput

	hshtg <= "00100011";
	with fsmOutput select
		CODE <= Add when "01" ,
			Dec when "10" ,
			hshtg when others ;


end behavioral;
