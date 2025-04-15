----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2024 04:25:51 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;


architecture Behavioral of test_env is

component MPG is
Port ( signal clk: in std_logic;
       signal btn: in std_logic;
       signal en: out std_logic);
end component;

component SSD is 
Port ( signal clk: in std_logic;
       signal digits: in std_logic_vector(31 downto 0);
       signal cat: out std_logic_vector(6 downto 0);
       signal an: out std_logic_vector(7 downto 0));
end component;

component IFetch is
  Port (   clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           jump : in STD_LOGIC;
           JumpR: in STD_LOGIC; --nou
           pcSrc : in STD_LOGIC;
           en0 : in STD_LOGIC;
           branchAdress: in STD_LOGIC_VECTOR(31 DOWNTO 0);
           jumpAdress: in STD_LOGIC_VECTOR(31 DOWNTO 0);
           jumpAdressR: in STD_LOGIC_VECTOR(31 DOWNTO 0); --nou
           pcNext: out STD_LOGIC_VECTOR(31 downto 0);
           instruction: out STD_LOGIC_VECTOR(31 downto 0));
end component;

component ID is
  Port ( clk : in STD_LOGIC;
         regWrite: in std_logic;
         regDst: in std_logic;
         extOp: in std_logic;
         instr: in std_logic_vector(25 downto 0);
         WD: in std_logic_vector(31 downto 0);
         RD1 : out std_logic_vector(31 downto 0);
         RD2 : out std_logic_vector(31 downto 0);
         ext_imm: out std_logic_vector(31 downto 0);
         funct: out std_logic_vector(5 downto 0);
         sa: out std_logic_vector(4 downto 0));
end component;

component UC is
  Port ( instr: in std_logic_vector(5 downto 0);
         RegDst: out std_logic;
         ExtOp: out std_logic;
         ALUSrc: out std_logic;
         Branch: out std_logic;
         Jump: out std_logic;
         ALUOp: out std_logic_vector(2 downto 0);
         MemWrite: out std_logic;
         RegWrite: out std_logic;
         MemtoReg: out std_logic;
         JumpR: out std_logic );
end component;

component EX is
  Port ( signal RD1: in std_logic_vector(31 downto 0);
         signal RD2: in std_logic_vector(31 downto 0);
         signal Ext_imm: in std_logic_vector(31 downto 0);
         signal sa: in std_logic_vector(4 downto 0);
         signal func: in std_logic_vector(5 downto 0);
         signal ALUOp: in std_logic_vector(2 downto 0);
         signal PCnext: in std_logic_vector(31 downto 0);
         signal ALUSrc: in std_logic;
         signal Zero: out std_logic;
         signal ALURes: out std_logic_vector(31 downto 0);
         signal BranchAddress: out std_logic_vector(31 downto 0) );
end component;

component MEM is
  Port ( clk : in std_logic;
         MemWrite: in std_logic;
         ALURes_in: in std_logic_vector(31 downto 0);
         RD2: in std_logic_vector(31 downto 0);
         en: in std_logic; --en e setat mereu pe 1 sau trebuie debouncer?
         MemData: out std_logic_vector(31 downto 0);
         ALURes_out: out std_logic_vector(31 downto 0) ); 
end component;

signal digits, pcNext, instruction, WD, ext_imm, RD1, RD2, ALURes, branchAdress, jumpAdress, MemData, ALURes_out: std_logic_vector(31 downto 0);
signal jump, PCSrc, regWrite, regWrite2, regDst, extOp, ALUSrc, Branch, MemWrite, MemtoReg, zero, en0, JumpR: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);
signal sa: std_logic_vector(4 downto 0);
signal func: std_logic_vector(5 downto 0);

begin
    
   btn_0: MPG port map
      ( btn=>btn(0),
        clk=>clk,
        en=>en0 );
   
   ssd_piece: SSD port map
   ( clk=>clk,
     digits=>digits, 
     cat=>cat,
     an=>an );
     
   IFetch_piece: IFetch port map
        ( clk=>clk,
          btn=>btn, 
          jump=>jump,
          JumpR=>JumpR, --nou
          pcSrc=>PCSrc,
          en0=>en0,
          branchAdress => branchAdress,
          jumpAdress => jumpAdress, 
          jumpAdressR=>RD1, --nou
          pcNext=>pcNext,
          instruction=>instruction );
          
   ID_piece: ID port map
          ( clk => clk,
            regWrite => regWrite2,
            regDst => regDst,
            extOp => extOp,
            instr => instruction(25 downto 0),
            WD => WD,
            RD1 => RD1,
            RD2 => RD2,
            ext_imm => ext_imm,
            funct => func,
            sa => sa );
            
   UC_piece: UC port map
          ( instr => instruction(31 downto 26),
            RegDst => regDst,
            ExtOp => ExtOp,
            ALUSrc => ALUSrc,
            Branch => Branch,
            Jump => jump,
            ALUOp => ALUOp,
            MemWrite => MemWrite,
            RegWrite => RegWrite,
            MemtoReg => MemtoReg,
            JumpR => JumpR );     
            
   EX_piece: EX port map
          ( RD1 => RD1,
            RD2 => RD2,
            Ext_imm =>ext_imm,
            sa =>instruction(10 downto 6),
            func => instruction(5 downto 0),
            ALUOp => ALUOp,
            PCnext => pcNext,
            ALUSrc => ALUSrc,
            Zero => zero,
            ALURes => ALURes,
            BranchAddress => branchAdress);
            
   MEM_piece: MEM port map
          ( clk => clk,
            MemWrite => MemWrite,
            ALURes_in => ALURes,
            RD2 => RD2,
            en => en0,
            MemData => MemData,
            ALURes_out => ALURes_out );   
   
   regWrite2<=regWrite and en0;
   jumpAdress <= pcNext(31 downto 28) & instruction(25 downto 0) & "00"; -- nou 
   WD <= MemData when MemtoReg='1' else ALURes_out; --Write Back WB
   PCSrc <= Branch and zero;
   
   process(sw(7 downto 5))
   begin
         case(sw(7 downto 5)) is
              when "000" => digits <= instruction;
              when "001" => digits <= pcNext;
              when "010" => digits <= RD1; 
              when "011" => digits <= RD2; 
              when "100" => digits <= Ext_imm; 
              when "101" => digits <= ALURes;
              when "110" => digits <= MemData;
              when "111" => digits <= WD;
              when others => digits <= X"00000000";                 
              
         end case;
   end process;
  
  led(8 downto 0) <= RegDst & ExtOp & ALUSrc & Branch & Jump & JumpR & MemWrite & MemtoReg & RegWrite;
   
end Behavioral;
