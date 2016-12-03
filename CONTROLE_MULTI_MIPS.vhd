---- Trabalho 7: Organizacao e Arquitetura de Computadores 
---- Lucas Nascimento Santos Souza - 14/0151010

---- Controle do Multiciclo

---- Somador
entity SOMADOR is
	port (
			-- Entradas
			EstadoAtual						: in natural;
			-- Saidas
			ProximoEstado					: out natural
			);
end SOMADOR;
architecture comportamento of SOMADOR is

	begin
	
	ProximoEstado <= (EstadoAtual + 1);
	
end architecture;

---- Estado
entity ESTADO is
	port (
			-- Entradas
			EstadoMUX						: in natural;
			-- Saidas
			EstadoSelecionado				: out natural
			);
end ESTADO;
architecture comportamento of ESTADO is

	begin
	
	EstadoSelecionado <= EstadoMUX;
	
end architecture;

---- Logica de Enderecamento
library ieee;
use ieee.std_logic_1164.all;

entity LOGICA_ENDERECAMENTO is
	port (
			-- Entradas
			Opcode							: in std_logic_vector(5 downto 0);
			SeletorEndereco				: in std_logic_vector(1 downto 0);
			ProximoPC						: in natural;
			-- Saidas
			PC									: out natural
			);
end LOGICA_ENDERECAMENTO;
architecture comportamento of LOGICA_ENDERECAMENTO is

	signal entradaMUX1					: natural;
	signal entradaMUX2					: natural;
	signal entradaMUX3					: natural;

	begin		
			-- Despacho 1
			EntradaMUX1 <=   6 when Opcode = "000000" else
								  9 when Opcode = "000010" else
								  8 when Opcode = "000100" else
								  2 when Opcode = "100011" else
								  2 when Opcode = "101111";
			
			-- Despacho 2
			EntradaMUX2 <=   3 when Opcode = "100011" else
								  5 when Opcode = "101011";			
		
			-- Somador
			EntradaMUX3 <=   ProximoPC;
		
			-- Selecao do MUX
			process(SeletorEndereco, EntradaMUX1, EntradaMUX2, EntradaMUX3) begin		
	
					if    (SeletorEndereco = "00") then
							PC <= 0;
					elsif (SeletorEndereco = "01") then
							PC <= EntradaMUX1;
					elsif (SeletorEndereco = "10") then
							PC <= EntradaMUX2;
					elsif (SeletorEndereco = "11") then
							PC <= EntradaMUX3;
					end if;
	
			end process;

end architecture;



---- Micro Programa
library ieee;
use ieee.std_logic_1164.all;

entity MICRO_PROGRAMA is
	port (
			-- Entradas
			EstadoMicroPrograma			: in natural;
			-- Saidas
			mEscrevePC, mEscrevePCCond, mIouD, mLeMem, mEscreveMem, mEscreveIR,
			mMemParaReg						: out std_logic;
			mOrigPC, mOpALU, mOrigBALU : out std_logic_vector(1 downto 0);
			mOrigAALU						: out std_logic;
			mEscreveReg, mRegDst			: out std_logic;
			mCtlEnd							: out std_logic_vector(1 downto 0)			
			);
end MICRO_PROGRAMA;
architecture comportamento of MICRO_PROGRAMA is
	---- ROM
	SUBTYPE microComandos_T is std_logic_vector(0 to 15);
	SUBTYPE nextAdress_T is std_logic_vector(0 to 1);

	-- Definindo uma microInstrucao_T
	TYPE microInstrucao_T is RECORD
		microCmds			 : microComandos_T;
		nextAdress			 : nextAdress_T;
	end RECORD;

	-- Tamanho do microPrograma_T
	TYPE microPrograma_T is array(0 to 9) of microInstrucao_T;

	-- Valores para o campo de sequenciamento
	constant SEQ 			 : nextAdress_T := "11";
	constant FETCH			 : nextAdress_T := "00";
	constant DISPATCH_1	 : nextAdress_T := "01";
	constant DISPATCH_2	 : nextAdress_T := "10";

	-- microPrograma_T    : listar os sinais de saida na ordem da figura	
	
	-- Sinais
	-- ALU Ctrl 			 | OpALU(2)     
	--	SRC 1					 |	OrigAALU 
	--	SRC 2					 | OrigBALU(2) 
	--	Regs					 | EscreveReg, RegDst, MemParaReg
	--	Memory				 | LeMem, EscreveMem, IouD, EscreveIR
	--	PC Write				 | OrigPC(2), EscrevePC, EscrevePCCond
	--	Seq					 | CtlEnd(2)
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           | Memory                   | PC Write     | Seq
	-- microPrograma_T[0] | Soma      | PC    | 4         |                | Ler a partir do PC       | ALU		     | Seq  
	constant mFETCH		 : microInstrucao_T := ("0000100010010010", SEQ);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[1] | Soma      | PC	   | ExtDesloc | Leitura        				|                          |             | Despacho 1
	constant mDECODE		 : microInstrucao_T := ("0001100000000000", DISPATCH_1);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[2] | Soma      | A     | Ext       |                				|                          |              | Despacho 2 
	constant mMEM1		    : microInstrucao_T := ("0011000000000000", DISPATCH_2);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[3] |           |       |           |                				| Ler a partir da ALU      |              | Seq 
	constant mLW2		    : microInstrucao_T := ("0000000010100000", SEQ);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[4] |           |       |           | Escreve no MDR 				|                          |              | Busca
	constant mLW2_2		 : microInstrucao_T := ("0000010100000000", FETCH);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[5] |           |       |           |                				| Escrever a partir da ALU |              | Busca
	constant mSW2		    : microInstrucao_T := ("0000000001100000", FETCH);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[6] | Funct     | A     | B         |                				|                          |              | Seq 
	constant mRFORMAT1    : microInstrucao_T := ("1010000000000000", SEQ);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           			   | Memory         			   | PC Write     | Seq	
	-- microPrograma_T[7] |           |       |           | Escrever a partir da ALU |                			   |          	   | Busca  
	constant mRFORMAT1_2	 : microInstrucao_T := ("0000011000000000", FETCH);
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[8] | Subtracao | A     | B         |                				| 								   | ALUSaidaCond | Busca
	constant mBEQ1		    : microInstrucao_T := ("0110000000000101", FETCH);	
	
	-- microInstrucao_T   | ALU Ctrl  | SRC 1 | SRC 2     | Regs           				| Memory                   | PC Write     | Seq	
	-- microPrograma_T[9] |           |       |           |                				|                          | Endereco DvI | Busca  
	constant mJUMP1	    : microInstrucao_T := ("0000000000001010", FETCH);
	
	-- Micro programa em si
	signal microPrograma	 : microPrograma_T;
	
	begin
	
		-- Sinais
		-- ALU Ctrl 			 | OpALU(2)     
		--	SRC 1					 |	OrigAALU 
		--	SRC 2					 | OrigBALU(2) 
		--	Regs					 | EscreveReg, RegDst, MemParaReg
		--	Memory				 | LeMem, EscreveMem, IouD, EscreveIR
		--	PC Write				 | OrigPC(2), EscrevePC, EscrevePCCond
		--	Seq					 | CtlEnd(2)
			
		-- Saidas dependendo do estado do micro programa
		-- mOpALU(2)
			mOpALU <= 		   mFETCH.microCmds(0 to 1)       			when EstadoMicroPrograma = 0 else 
								   mDECODE.microCmds(0 to 1)      			when EstadoMicroPrograma = 1 else 
								   mMEM1.microCmds(0 to 1)        			when EstadoMicroPrograma = 2 else 
								   mLW2.microCmds(0 to 1)         			when EstadoMicroPrograma = 3 else 
								   mLW2_2.microCmds(0 to 1)       			when EstadoMicroPrograma = 4 else 
								   mSW2.microCmds(0 to 1) 		  				when EstadoMicroPrograma = 5 else
								   mRFORMAT1.microCmds(0 to 1) 	  			when EstadoMicroPrograma = 6 else 
								   mRFORMAT1_2.microCmds(0 to 1)  			when EstadoMicroPrograma = 7 else 
								   mBEQ1.microCmds(0 to 1)        			when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(0 to 1)       			when EstadoMicroPrograma = 9;		
					
		-- mOrigAALU
			mOrigAALU <=      mFETCH.microCmds(2)       		  			when EstadoMicroPrograma = 0 else 
							      mDECODE.microCmds(2)      		  			when EstadoMicroPrograma = 1 else 
							      mMEM1.microCmds(2)        		  			when EstadoMicroPrograma = 2 else 
							      mLW2.microCmds(2)         		  			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(2)       		  			when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(2) 		  		  			when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(2) 	  		  			when EstadoMicroPrograma = 6 else 
								   mRFORMAT1_2.microCmds(2)  		  			when EstadoMicroPrograma = 7 else 
								   mBEQ1.microCmds(2)        		  			when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(2)       		  			when EstadoMicroPrograma = 9;
				
		-- mOrigBALU(2)
			mOrigBALU <=      mFETCH.microCmds(3 to 4)       			when EstadoMicroPrograma = 0 else 
							      mDECODE.microCmds(3 to 4)      			when EstadoMicroPrograma = 1 else 
							      mMEM1.microCmds(3 to 4)        			when EstadoMicroPrograma = 2 else 
							      mLW2.microCmds(3 to 4)         			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(3 to 4)       			when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(3 to 4) 		  				when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(3 to 4) 	  			when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(3 to 4)  			when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(3 to 4)        			when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(3 to 4)       			when EstadoMicroPrograma = 9;		
					
		-- mEscreveReg
			mEscreveReg <=    mFETCH.microCmds(5)       		  			when EstadoMicroPrograma = 0 else 
							      mDECODE.microCmds(5)      		  			when EstadoMicroPrograma = 1 else 
							      mMEM1.microCmds(5)        		  			when EstadoMicroPrograma = 2 else 
							      mLW2.microCmds(5)         		  			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(5)       		  			when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(5) 		  		     		when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(5) 	  		  			when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(5)  		 	 		when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(5)        		  			when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(5)       		  			when EstadoMicroPrograma = 9;	
					
		-- mRegDst
			mRegDst <=        mFETCH.microCmds(6)       		  			when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(6)      		  			when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(6)        		  			when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(6)         		  			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(6)       		  			when EstadoMicroPrograma = 4 else 
								   mSW2.microCmds(6) 		  		     		when EstadoMicroPrograma = 5 else
								   mRFORMAT1.microCmds(6) 	  		  			when EstadoMicroPrograma = 6 else 
								   mRFORMAT1_2.microCmds(6)  		  			when EstadoMicroPrograma = 7 else 
								   mBEQ1.microCmds(6)        		  			when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(6)       		  			when EstadoMicroPrograma = 9;	
					
		-- mMemParaReg
			mMemParaReg <=    mFETCH.microCmds(7)       		  			when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(7)      		  			when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(7)        		  			when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(7)         		  			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(7)       		  			when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(7) 		  		     		when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(7) 	  		  			when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(7)  		  			when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(7)        		  			when EstadoMicroPrograma = 8 else 	
							      mJUMP1.microCmds(7)       		  			when EstadoMicroPrograma = 9;	
					
		-- mLeMem
			mLeMem <=         mFETCH.microCmds(8)       		  			when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(8)      		  			when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(8)        		  			when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(8)         		  			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(8)       		  			when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(8) 		  		     		when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(8) 	  		  			when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(8)  		  			when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(8)      		  		   when EstadoMicroPrograma = 8 else 	
							      mJUMP1.microCmds(8)       		  			when EstadoMicroPrograma = 9;	
				
		-- mEscreveMem
			mEscreveMem <=    mFETCH.microCmds(9)       		  			when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(9)      		  			when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(9)        		  			when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(9)         		  			when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(9)       		  			when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(9) 		  		     		when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(9) 	  		  			when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(9)  		  			when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(9)        		  			when EstadoMicroPrograma = 8 else 	
							      mJUMP1.microCmds(9)       		  			when EstadoMicroPrograma = 9;	
					
		-- mIouD
			mIouD <=          mFETCH.microCmds(10)       		  		when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(10)      		  		when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(10)        		  		when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(10)         		  		when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(10)       		  		when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(10) 		  		      	when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(10) 	  		  		when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(10)  		  		when EstadoMicroPrograma = 7 else 
								   mBEQ1.microCmds(10)        		  		when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(10)       		  		when EstadoMicroPrograma = 9;						


		-- mEscreveIR
			mEscreveIR <=     mFETCH.microCmds(11)       		  		when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(11)      		  		when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(11)        		  		when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(11)         		  		when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(11)       		  		when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(11) 		  		      	when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(11) 	  		  		when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(11)  		  		when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(11)        		  		when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(11)       		  		when EstadoMicroPrograma = 9;	
							  
		-- mOrigPC(2)
			mOrigPC <= 		   mFETCH.microCmds(12 to 13)       		when EstadoMicroPrograma = 0 else 
							      mDECODE.microCmds(12 to 13)      		when EstadoMicroPrograma = 1 else 
							      mMEM1.microCmds(12 to 13)        		when EstadoMicroPrograma = 2 else 
							      mLW2.microCmds(12 to 13)         		when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(12 to 13)       		when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(12 to 13) 		   		when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(12 to 13) 			when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(12 to 13)  		when EstadoMicroPrograma = 7 else 
								   mBEQ1.microCmds(12 to 13)        		when EstadoMicroPrograma = 8 else 	
								   mJUMP1.microCmds(12 to 13)       		when EstadoMicroPrograma = 9;	

		-- mEscrevePC
			mEscrevePC <=     mFETCH.microCmds(14)       		      when EstadoMicroPrograma = 0 else 
						         mDECODE.microCmds(14)      		  		when EstadoMicroPrograma = 1 else 
					            mMEM1.microCmds(14)        		  		when EstadoMicroPrograma = 2 else 
						         mLW2.microCmds(14)         		  		when EstadoMicroPrograma = 3 else 
							      mLW2_2.microCmds(14)       		  		when EstadoMicroPrograma = 4 else 
							      mSW2.microCmds(14) 		  		  			when EstadoMicroPrograma = 5 else
							      mRFORMAT1.microCmds(14) 	  		  		when EstadoMicroPrograma = 6 else 
								   mRFORMAT1_2.microCmds(14)  		  		when EstadoMicroPrograma = 7 else 
								   mBEQ1.microCmds(14)        		  		when EstadoMicroPrograma = 8 else 	
							      mJUMP1.microCmds(14)       		  		when EstadoMicroPrograma = 9;
		
		-- mEscrevePCCond
			mEscrevePCCond <= mFETCH.microCmds(15)       		  		when EstadoMicroPrograma = 0 else 
								   mDECODE.microCmds(15)      		  		when EstadoMicroPrograma = 1 else 
								   mMEM1.microCmds(15)        		  		when EstadoMicroPrograma = 2 else 
								   mLW2.microCmds(15)         		  		when EstadoMicroPrograma = 3 else 
								   mLW2_2.microCmds(15)       		  		when EstadoMicroPrograma = 4 else 
								   mSW2.microCmds(15) 		  		  			when EstadoMicroPrograma = 5 else
								   mRFORMAT1.microCmds(15) 	  		  		when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.microCmds(15)  		  		when EstadoMicroPrograma = 7 else 
							      mBEQ1.microCmds(15)        		  		when EstadoMicroPrograma = 8 else 	
							      mJUMP1.microCmds(15)       		  		when EstadoMicroPrograma = 9;		
									
		-- mCtlEnd
			mCtlEnd <= 		   mFETCH.nextAdress       		     		when EstadoMicroPrograma = 0 else 
						         mDECODE.nextAdress    		     			when EstadoMicroPrograma = 1 else 
					            mMEM1.nextAdress        		     		when EstadoMicroPrograma = 2 else 
						         mLW2.nextAdress         		     		when EstadoMicroPrograma = 3 else 
							      mLW2_2.nextAdress      		     			when EstadoMicroPrograma = 4 else 
							      mSW2.nextAdress		  		        		when EstadoMicroPrograma = 5 else
							      mRFORMAT1.nextAdress 	  		     		when EstadoMicroPrograma = 6 else 
							      mRFORMAT1_2.nextAdress  		     		when EstadoMicroPrograma = 7 else 
							      mBEQ1.nextAdress       		     			when EstadoMicroPrograma = 8 else 	
							      mJUMP1.nextAdress       		     		when EstadoMicroPrograma = 9;								  
							  
end architecture;

---- Controle
library ieee;
use ieee.std_logic_1164.all;

entity CONTROLE_MULTI_MIPS is
	port (
			-- Entradas
			Clk								: in std_logic;
			Op									: in std_logic_vector(5 downto 0);
			-- Saidas
			EscrevePC, EscrevePCCond, IouD, LeMem, EscreveMem, EscreveIR,
			MemParaReg						: out std_logic;
			OrigPC, OpALU, OrigBALU 	: out std_logic_vector(1 downto 0);
			OrigAALU							: out std_logic;
			EscreveReg, RegDst			: out std_logic;
			CtlEnd							: out std_logic_vector(1 downto 0);
			-- Para facilitar
			EstadoAtual						: out natural			
			);
end CONTROLE_MULTI_MIPS;

architecture comportamento of CONTROLE_MULTI_MIPS is

	---- Somador
	component SOMADOR is
		port (
				-- Entradas
				EstadoAtual						: in natural;
				-- Saidas
				ProximoEstado					: out natural
				);
	end component;

	---- Estado
	component ESTADO is
		port (
				-- Entradas
				EstadoMUX						: in natural;
				-- Saidas
				EstadoSelecionado				: out natural
				);
	end component;

	---- Logica de Enderecamento
	component LOGICA_ENDERECAMENTO is
		port (
				-- Entradas
				Opcode							: in std_logic_vector(5 downto 0);
				SeletorEndereco				: in std_logic_vector(1 downto 0);
				ProximoPC						: in natural;
				-- Saidas
				PC									: out natural
				);
	end component;

	---- Micro Programa
	component MICRO_PROGRAMA is
		port (
				-- Entradas
				EstadoMicroPrograma			: in natural;
				-- Saidas
				mEscrevePC, mEscrevePCCond, mIouD, mLeMem, mEscreveMem, mEscreveIR,
				mMemParaReg						: out std_logic;
				mOrigPC, mOpALU, mOrigBALU : out std_logic_vector(1 downto 0);
				mOrigAALU						: out std_logic;
				mEscreveReg, mRegDst			: out std_logic;
				mCtlEnd							: out std_logic_vector(1 downto 0)			
				);
	end component;
	
	-- Sinais para interconexao entre os componentes
	signal eCtlEnd								: std_logic_vector(1 downto 0);
	signal eProximoEstado					: natural;

	signal sCtlEnd								: std_logic_vector(1 downto 0);	
	signal sProximoEstado					: natural;
	signal sEstadoMUX							: natural;
	signal sEstadoSelecionado				: natural;	
	
	begin 	
			G1: LOGICA_ENDERECAMENTO port map (Op, eCtlEnd, eProximoEstado, sEstadoMUX);
			G2: ESTADO  				 port map (sEstadoMUX, sEstadoSelecionado);
			G3: SOMADOR 				 port map (sEstadoSelecionado, sProximoEstado);
			G4: MICRO_PROGRAMA 		 port map (sEstadoSelecionado, EscrevePC, EscrevePCCond, IouD, LeMem, EscreveMem, EscreveIR,
														  MemParaReg, OrigPC, OpALU, OrigBALU, OrigAALU, EscreveReg, RegDst, sCtlEnd);
														  
			-- Seletor do proximo estado
			CtlEnd <= sCtlEnd;
			
			-- Estado atual
			EstadoAtual <= sEstadoSelecionado;			

			process (Clk) begin
					
					if(rising_edge(Clk)) then
						eCtlEnd <= sCtlEnd;
						eProximoEstado <= sProximoEstado;
					end if;
			
			end process;

end architecture;

