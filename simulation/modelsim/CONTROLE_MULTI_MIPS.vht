-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "12/03/2016 15:46:04"
                                                            
-- Vhdl Test Bench template for design  :  CONTROLE_MULTI_MIPS
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY CONTROLE_MULTI_MIPS_vhd_tst IS
END CONTROLE_MULTI_MIPS_vhd_tst;
ARCHITECTURE CONTROLE_MULTI_MIPS_arch OF CONTROLE_MULTI_MIPS_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL Clk : STD_LOGIC;
SIGNAL CtlEnd : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL EscreveIR : STD_LOGIC;
SIGNAL EscreveMem : STD_LOGIC;
SIGNAL EscrevePC : STD_LOGIC;
SIGNAL EscrevePCCond : STD_LOGIC;
SIGNAL EscreveReg : STD_LOGIC;
SIGNAL IouD : STD_LOGIC;
SIGNAL LeMem : STD_LOGIC;
SIGNAL MemParaReg : STD_LOGIC;
SIGNAL Op : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL OpALU : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL OrigAALU : STD_LOGIC;
SIGNAL OrigBALU : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL OrigPC : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL RegDst : STD_LOGIC;
SIGNAL EstadoAtual : NATURAL;
COMPONENT CONTROLE_MULTI_MIPS
	PORT (
	Clk : IN STD_LOGIC;
	CtlEnd : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	EscreveIR : OUT STD_LOGIC;
	EscreveMem : OUT STD_LOGIC;
	EscrevePC : OUT STD_LOGIC;
	EscrevePCCond : OUT STD_LOGIC;
	EscreveReg : OUT STD_LOGIC;
	IouD : OUT STD_LOGIC;
	LeMem : OUT STD_LOGIC;
	MemParaReg : OUT STD_LOGIC;
	Op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
	OpALU : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	OrigAALU : OUT STD_LOGIC;
	OrigBALU : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	OrigPC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	RegDst : OUT STD_LOGIC;
	EstadoAtual : OUT NATURAL
	);
END COMPONENT;
BEGIN
	i1 : CONTROLE_MULTI_MIPS
	PORT MAP (
-- list connections between master ports and signals
	Clk => Clk,
	CtlEnd => CtlEnd,
	EscreveIR => EscreveIR,
	EscreveMem => EscreveMem,
	EscrevePC => EscrevePC,
	EscrevePCCond => EscrevePCCond,
	EscreveReg => EscreveReg,
	IouD => IouD,
	LeMem => LeMem,
	MemParaReg => MemParaReg,
	Op => Op,
	OpALU => OpALU,
	OrigAALU => OrigAALU,
	OrigBALU => OrigBALU,
	OrigPC => OrigPC,
	RegDst => RegDst,
	EstadoAtual => EstadoAtual
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
		Clk <= '1'; wait for 5 ns;
		
		-- R (4 CICLOS)
		Op <= "000000";
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;					
			

		-- JMP (3 CICLOS)
		Op <= "000010";
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;		

	
		-- BEQ (3 CICLOS)
		Op <= "000100";		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;		
		
		-- LW (5 CICLOS)
		Op <= "100011";
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;		
		
		-- SW (4 CICLOS)
		Op <= "101011";		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;		
		
		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;

		Clk <= '0'; wait for 5 ns;
		Clk <= '1'; wait for 5 ns;
		
WAIT;                                                        
END PROCESS always;                                          
END CONTROLE_MULTI_MIPS_arch;
