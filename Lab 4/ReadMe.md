Changes made to Lab 4:

On leddec16.vhd, changed lines 39-43 to reflect a change in order of bit significance. 

Original:
	anode <= "1110" WHEN dig = "00" ELSE --0
	         "1101" WHEN dig = "01" ELSE --1
	         "1011" WHEN dig = "10" ELSE --2
	         "0111" WHEN dig = "11" ELSE --3
	         "1111";

New:
	anode <= "1110" WHEN dig = "11" ELSE --0
	         "1101" WHEN dig = "10" ELSE --1
	         "1011" WHEN dig = "01" ELSE --2
	         "0111" WHEN dig = "00" ELSE --3
	         "1111";
