***------------------------------------***
***          VLSI Intro 2025           ***
***           CMOS 6-bit ALU           ***
***              Example               ***
***------------------------------------***
.title vlsi

*************************************************************
*************************************************************
***************Don't touch settings below********************
*************************************************************
*************************************************************

***-----------------------***
***     input vector      ***
***-----------------------***
.VEC 'input.vec'
***-----------------------***
***        setting        ***
***-----------------------***
.lib "./../../umc018.l" L18U18V_TT
.TEMP 25
.op
.options post

***-----------------------***
***      power/input      ***
***-----------------------***
.global VDD GND
.param supply=1.8
.param load=10f

Vss GND 0   0
Vd1 VDD GND supply
***-----------------------***
***       simulation      ***
***-----------------------***
.tran 0.005n 'period*401'

***-----------------------***
***      measurement      ***
***-----------------------***
.meas tran Iavg avg I(Vd1) from=0ns to='period*401'
.meas Pavg param='abs(Iavg)*supply'

***-----------------------***
***        loading        ***
***-----------------------***
C0 OUT0 GND load
C1 OUT1 GND load
C2 OUT2 GND load
C3 OUT3 GND load
C4 OUT4 GND load
C5 OUT5 GND load
C6 OUT6 GND load
*************************************************************
*************************************************************
***************Don't touch settings above********************
*************************************************************
*************************************************************

***** you can modify period here, remember this period need to match the period in the input.vec ****
***** OUT0~OUT6 should be correct before 0.5*period                                              ****
.param period = 1.32n
***-----------------------***
***      parameters       ***
***-----------------------***
.param wp=0.44u
.param wn=0.44u
.param l_18=0.18u
.param GND=0
.param VDD=1.8
Vcin C0 0 0
***-----------------------***
*** Your design      ***
***-----------------------***

***=========================================***
*** Level 1: Basic Gates              ***
***=========================================***

*** Inverter ***
.subckt INV in1 out VDD GND
Mp1 out in1 VDD VDD P_18_G2 w=wp l=l_18
Mn1 out in1 GND GND N_18_G2 w=wn l=l_18
.ends

*** Transmission Gate (Required for XOR/MUX) ***
.subckt TRAN en en_bar d out VDD GND
Mn out en d GND N_18_G2 w=wn l=l_18
Mp out en_bar d VDD P_18_G2 w=wp l=l_18
.ends

*** 2-input NOR Gate ***
.subckt NOR2 in1 in2 out VDD GND
* PMOS (Pull-up Network: Series)
mp1 out GND VDD VDD P_18_G2 w=wp l=l_18
* NMOS (Pull-down Network: Parallel)
mn1 out in1 GND GND N_18_G2 w=wn l=l_18
mn2 out in2 GND GND N_18_G2 w=wn l=l_18
.ends

*** 2-input NAND Gate ***
.subckt NAND2 in1 in2 out VDD GND
* PMOS (Pull-up Network: Parallel)
mp1 out in1 VDD VDD P_18_G2 w=wp l=l_18
mp2 out in2 VDD VDD P_18_G2 w=wp l=l_18
* NMOS (Pull-down Network: Series)
mn1 node1 in1 GND GND N_18_G2 w=wn l=l_18
mn2 out in2 node1 GND N_18_G2 w=wn l=l_18
.ends

.subckt Pseudo_NOR6 in1 in2 in3 in4 in5 in6 out VDD GND
mp1 out GND VDD VDD P_18_G2 w=wp l=l_18

mn1 out in1 GND GND N_18_G2 w=wp l=l_18
mn2 out in2 GND GND N_18_G2 w=wp l=l_18
mn3 out in3 GND GND N_18_G2 w=wp l=l_18
mn4 out in4 GND GND N_18_G2 w=wp l=l_18
mn5 out in5 GND GND N_18_G2 w=wp l=l_18
mn6 out in6 GND GND N_18_G2 w=wp l=l_18
.ends NOR6

*** XOR2 ***
.subckt XOR2 a b y VDD GND

Xinv_a a a_bar VDD GND INV
Xinv_b b b_bar VDD GND INV
Xtg1 b b_bar a_bar y VDD GND TRAN
Xtg2 b_bar b a y VDD GND TRAN
.ends

* XOR Gate using Transmission Gates (4T ver.)
.subckt NEWXOR a b b_bar y vdd vss
mp1 y a b vdd P_18_G2 l=l_18 w=wp
mn1 y a b_bar vss N_18_G2 l=l_18 w=wn
mp2 a b y vdd P_18_G2 l=l_18 w=wp
mn2 a b_bar y vss N_18_G2 l=l_18 w=wn
.ends

*** Buffer ***
.subckt BUF in out VDD GND
Xinv1 in node_int VDD GND INV
Xinv2 node_int out VDD GND INV
.ends


***=========================================***
*** Level 2: Multiplexers             ***
***=========================================***

*** 2-to-1 Multiplexer ***
.SUBCKT MUX2 A B S S_bar Vout VDD GND
Xtg_B S S_bar B Vout VDD GND TRAN
Xtg_A S_bar S A Vout VDD GND TRAN
.ends

*** 4-to-1 Multiplexer ***
.subckt MUX4 in0 in1 in2 in3 sel0 sel1 sel0_ sel1_ out VDD GND
Xmux0 in0 in1 sel0 sel0_ m0_out VDD GND MUX2
Xmux1 in2 in3 sel0 sel0_ m1_out VDD GND MUX2
Xmux2 m0_out m1_out sel1 sel1_ out VDD GND MUX2
.ends

*** 8-to-1 Multiplexer (Standard) ***
.subckt MUX8 in0 in1 in2 in3 in4 in5 in6 in7 sel0 sel1 sel2 sel0_ sel1_ sel2_ out VDD GND
Xmux0 in0 in1 in2 in3 sel0 sel1 sel0_ sel1_ m0_out VDD GND MUX4
Xmux1 in4 in5 in6 in7 sel0 sel1 sel0_ sel1_ m1_out VDD GND MUX4
Xmux2 m0_out m1_out sel2 sel2_ out VDD GND MUX2
.ends

*** 8-to-1 Multiplexer (Version B - Optimized/Custom) ***
.subckt MUX8B in0 in1 in2 in3 in4 in5 in6 in7 sel0 sel1 sel2 sel0_ sel1_ sel2_ out VDD GND
Xmux0 in0 in1 in2 in3 sel0 sel1 sel0_ sel1_ m0_out VDD GND MUX4
Xmux1 in4 in6 sel1 sel1_ m1_out VDD GND MUX2
Xmux2 m0_out m1_out sel2 sel2_ out VDD GND MUX2
.ends

*** 8-to-1 Multiplexer (for MSB) (port: GND GND GND GND add_cout add_cout_ add_cout_1 add_cout_1) ***
.subckt MUX8_MSB in0 in4 in5 in6 sel0 sel1 sel2 sel0_ sel1_ sel2_ out VDD GND
Xmux1 in4 in5 sel0 sel0_ out1 VDD GND MUX2
Xumx2 out1 in6 sel1 sel1_ m1_out VDD GND MUX2
Xmux3 in0 m1_out sel2 sel2_ out VDD GND MUX2
.ends


***=========================================***
*** Level 3: 1-bit Arithmetic Units   ***
***=========================================***

*** 20T TG Full Adder ***
.subckt FA A B Cin Sum Cout VDD GND
Xinva A A_bar VDD GND INV
Xinvb B B_bar VDD GND INV
Xinvc Cin Cin_bar VDD GND INV
Xtran1 B_bar B A N1 VDD GND TRAN
Xtran2 B B_bar A_bar N1 VDD GND TRAN
Xinvn1 N1 N1_bar VDD GND INV
Xtran3 N1 N1_bar Cin_bar Sum VDD GND TRAN
Xtran4 N1_bar N1 Cin Sum VDD GND TRAN
Xtran5 N1_bar N1 A Cout VDD GND TRAN
Xtran6 N1 N1_bar Cin Cout VDD GND TRAN
.ends

*** 1-bit Incrementer/Decrementer Cell ***
.subckt INCRE A Cin Sum Cout SUB VDD GND
Xinv0 A A_bar VDD GND INV
Xxor0 SUB A A_bar n1 VDD GND NEWXOR
Xnand Cin n1 Cout_bar VDD GND NAND2
Xinv1 Cout_bar Cout VDD GND INV
Xxor1 Cin A A_bar Sum VDD GND NEWXOR
.ends


***=========================================***
*** Level 4: 6-bit Arrays             ***
***=========================================***

*** 6-bit Ripple Carry Adder ***
.subckt RCA6 a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 cin s0 s1 s2 s3 s4 s5 cout VDD GND
Xfa0 a0 b0 cin s0 c1 VDD GND FA
Xfa1 a1 b1 c1 s1 c2 VDD GND FA
Xfa2 a2 b2 c2 s2 c3 VDD GND FA
Xfa3 a3 b3 c3 s3 c4 VDD GND FA
Xfa4 a4 b4 c4 s4 c5 VDD GND FA
Xfa5 a5 b5 c5 s5 cout VDD GND FA
.ends

*** 6-bit Ripple Carry Incrementer/Decrementer ***
.subckt RCI6 a0 a1 a2 a3 a4 a5 s0 s1 s2 s3 s4 s5 cout SUB1 VDD GND
Xinv0 a0 s0 VDD GND INV
Xxor SUB1 a0 c1 VDD GND XOR2
Xinc1 a1 c1 s1 c2 SUB1 VDD GND INCRE
Xinc2 a2 c2 s2 c3 SUB1 VDD GND INCRE
Xinc3 a3 c3 s3 c4 SUB1 VDD GND INCRE
Xinc4 a4 c4 s4 c5 SUB1 VDD GND INCRE
Xinc5 a5 c5 s5 cout SUB1 VDD GND INCRE
.ends


***=========================================***
*** Level 5: Major Functional Units   ***
***=========================================***

*** 6-bit Logic Operations Unit ***
.subckt LOGIC_UNIT a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5
+                  or0 or1 or2 or3 or4 or5
+                  and0 and1 and2 and3 and4 and5
+                  xor0 xor1 xor2 xor3 xor4 xor5
+                  EQ VDD GND

* OR operations
Xor0 a0 b0 or0_ VDD GND NOR2
Xin1 or0_ or0 VDD GND INV
Xor1 a1 b1 or1_ VDD GND NOR2
Xin2 or1_ or1 VDD GND INV
Xor2 a2 b2 or2_ VDD GND NOR2
Xin3 or2_ or2 VDD GND INV
Xor3 a3 b3 or3_ VDD GND NOR2
Xin4 or3_ or3 VDD GND INV
Xor4 a4 b4 or4_ VDD GND NOR2
Xin5 or4_ or4 VDD GND INV
Xor5 a5 b5 or5_ VDD GND NOR2
Xin6 or5_ or5 VDD GND INV

* AND operations
Xand0 a0 b0 and0_ VDD GND NAND2
Xinv1 and0_ and0 VDD GND INV
Xand1 a1 b1 and1_ VDD GND NAND2
Xinv2 and1_ and1 VDD GND INV
Xand2 a2 b2 and2_ VDD GND NAND2
Xinv3 and2_ and2 VDD GND INV
Xand3 a3 b3 and3_ VDD GND NAND2
Xinv4 and3_ and3 VDD GND INV
Xand4 a4 b4 and4_ VDD GND NAND2
Xinv5 and4_ and4 VDD GND INV
Xand5 a5 b5 and5_ VDD GND NAND2
Xinv6 and5_ and5 VDD GND INV

* XOR operations
Xxor0 a0 b0 xor0 VDD GND XOR2
Xxor1 a1 b1 xor1 VDD GND XOR2
Xxor2 a2 b2 xor2 VDD GND XOR2
Xxor3 a3 b3 xor3 VDD GND XOR2
Xxor4 a4 b4 xor4 VDD GND XOR2
Xxor5 a5 b5 xor5 VDD GND XOR2

* EQ operation (NOR6)
Xeq xor0 xor1 xor2 xor3 xor4 xor5 EQ VDD GND Pseudo_NOR6
.ends

*** 6-bit Arithmetic Unit (ADD/SUB) ***
.subckt ARITH_UNIT a0 a1 a2 a3 a4 a5 b0 b1 b2 b3 b4 b5 SUB \
                   s0 s1 s2 s3 s4 s5 cout VDD GND

* B_eff = B xor SUB (if sub then invert b)

Xbx0 b0 SUB b0f VDD GND XOR2
Xbx1 b1 SUB b1f VDD GND XOR2
Xbx2 b2 SUB b2f VDD GND XOR2
Xbx3 b3 SUB b3f VDD GND XOR2
Xbx4 b4 SUB b4f VDD GND XOR2
Xbx5 b5 SUB b5f VDD GND XOR2

* 6-bit adder
Xadder a0 a1 a2 a3 a4 a5 b0f b1f b2f b3f b4f b5f SUB \
       s0 s1 s2 s3 s4 s5 cout VDD GND RCA6
.ends

*** A+1 / A-1 Unit Wrapper ***
.subckt A_plus_1 a0 a1 a2 a3 a4 a5 s0 s1 s2 s3 s4 s5 cout SUB1 VDD GND
Xincre a0 a1 a2 a3 a4 a5 s0 s1 s2 s3 s4 s5 cout SUB1 VDD GND RCI6
.ends


***=========================================***
*** Level 6: Top Level ALU            ***
***=========================================***

*** MAIN 6-BIT ALU ***
.subckt ALU6 A5 A4 A3 A2 A1 A0 B5 B4 B3 B2 B1 B0 SEL2 SEL1 SEL0
+OUT6 OUT5 OUT4 OUT3 OUT2 OUT1 OUT0 VDD GND

* Invert select lines
XnS2 SEL2 SEL2_ VDD GND INV
XnS1 SEL1 SEL1_ VDD GND INV
XnS0 SEL0 SEL0_ VDD GND INV

*** Logic Unit for bits 0-5 ***
Xlogic A0 A1 A2 A3 A4 A5 B0 B1 B2 B3 B4 B5
+       OR0 OR1 OR2 OR3 OR4 OR5
+       AND0 AND1 AND2 AND3 AND4 AND5
+       XOR0 XOR1 XOR2 XOR3 XOR4 XOR5 EQ VDD GND LOGIC_UNIT

*** Arithmetic Unit (ADD/SUB) ***
Xarith A0 A1 A2 A3 A4 A5 B0 B1 B2 B3 B4 B5 SEL0
+      ADD0 ADD1 ADD2 ADD3 ADD4 ADD5 add_cout VDD GND ARITH_UNIT

*** Increment/Decrement Unit ***
Xaplus1 A0 A1 A2 A3 A4 A5 ADD0_1 ADD1_1 ADD2_1 ADD3_1 ADD4_1 ADD5_1 add_cout_1 SEL0 VDD GND A_plus_1

Xcoutinv add_cout add_cout_ VDD GND INV

*** Output Selection for bits 0-5 ***
* Bit 0
Xout_mux0 OR0 AND0 XOR0 EQ ADD0 ADD0 ADD0_1 ADD0_1
+SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT0 VDD GND MUX8B
* Bit 1
Xout_mux1 OR1 AND1 XOR1 GND ADD1 ADD1 ADD1_1 ADD1_1
+SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT1 VDD GND MUX8B
* Bit 2
Xout_mux2 OR2 AND2 XOR2 GND ADD2 ADD2 ADD2_1 ADD2_1
+SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT2_t VDD GND MUX8B
Xbuf2 OUT2_t OUT2 VDD GND BUF
* Bit 3
Xout_mux3 OR3 AND3 XOR3 GND ADD3 ADD3 ADD3_1 ADD3_1
+SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT3 VDD GND MUX8B
* Bit 4
Xout_mux4 OR4 AND4 XOR4 GND ADD4 ADD4 ADD4_1 ADD4_1
+SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT4 VDD GND MUX8B
* Bit 5
Xout_mux5 OR5 AND5 XOR5 GND ADD5 ADD5 ADD5_1 ADD5_1
+SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT5_t VDD GND MUX8B
Xbuf5 OUT5_t OUT5 VDD GND BUF

*** Output Selection for bit 6 (Carry/Sign) ***
Xout_mux6 GND add_cout add_cout_ add_cout_1 \
     SEL0 SEL1 SEL2 SEL0_ SEL1_ SEL2_ OUT6_t VDD GND MUX8_MSB
Xbuf6 OUT6_t OUT6 VDD GND BUF
.ends

*** Execution ***
Xalu A5 A4 A3 A2 A1 A0 B5 B4 B3 B2 B1 B0 SEL2 SEL1 SEL0
+OUT6 OUT5 OUT4 OUT3 OUT2 OUT1 OUT0 VDD GND ALU6

.end


