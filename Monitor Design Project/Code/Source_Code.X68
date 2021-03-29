      ORG    $1000
START:  
*VECTOR EXCEPTION TABLE SET UP
     MOVE.L #BUS_VECTOR,$8  
     MOVE.L #ADDRESS_VECTOR,$C
     MOVE.L #ILLEGAL_VECTOR,$10
     MOVE.L #DIVZ_VECTOR,$14
     MOVE.L #CHECK_VECTOR,$18
     MOVE.L #PRIVILEGE_VECTOR,$20
     MOVE.L #LINEA_VECTOR,$28
     MOVE.L #LINEF_VECTOR,$2C
    
    LEA MSG_WELCOME,A5
    LEA MSG_WELCOME_ED,A6
    BSR PRINT
    
RESET:
    LEA HISTORY_BUFF,A2
    MOVE.B #0,(A2)
    LEA STACK,A7        ;SET(RESET) A7
MAIN:    
    LEA MSG_PROM, A5
    LEA MSG_PROM_ED, A6
    BSR PRINT_C
    BSR INPUT
    BSR INTERPRETER
    BRA MAIN
    
    
*------------------SUBROUTINE------------*    
;Standard I/O
;Print WITH carrige return and line feed
;Print string stored within address range marked by A5 and A6
PRINT:
    MOVEM.L D0-D1/A1,-(A7)
    MOVEA.L A5,A1           
    SUBA.L A5,A6            
    MOVE.L A6,D1            
    MOVE.L #0,D0            
    TRAP #15
    MOVEM.L (A7)+,D0-D1/A1
    RTS
;Print WITHOUT carrige return and line feed
;Print string stored within address range marked by A5 and A6
PRINT_C:            
    MOVEM.L D0-D1/A1,-(A7)
    MOVEA.L A5,A1           
    SUBA.L A5,A6            
    MOVE.L A6,D1            
    MOVE.L #1,D0
    TRAP #15
    MOVEM.L (A7)+,D0-D1/A1
    RTS
;Store input string to buffer
;Marked
INPUT:
    MOVEM.L D0-D1/A1,-(A7)
    LEA INPUT_BUFF,A1  ;EVERY WORDS COMES FROM KEYBOARD WILL BE STORED AT BUFF AREA
    MOVE.L #2,D0
    TRAP #15
    ADDA.W D1,A1
    MOVE.B #NULL,(A1)
    CMPI.B #0,D1
    MOVEM.L (A7)+,D0-D1/A1
    RTS

;Determine which command been input and branch accordingly 
INTERPRETER:    
    ;Check if input buffer is empty
    LEA INPUT_BUFF,A1
    CMPI.B #NULL,(A1)
    BEQ INTERPRETER_END
 
    ;Check if it's HELP command
    LEA MSG_CMD_HELP,A5
    LEA MSG_CMD_HELP_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP   
    
    ;Block search
    LEA MSG_CMD_BSCH,A5
    LEA MSG_CMD_BSCH_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BSCH

    ;TO display memory
    LEA MSG_CMD_MDSP,A5
    LEA MSG_CMD_MDSP_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ MDSP
    
    ;To modify memory 
    LEA MSG_CMD_MM,A5
    LEA MSG_CMD_MM_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ MM
    
    ;To set memory
    LEA MSG_CMD_MS,A5
    LEA MSG_CMD_MS_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ MS
    
    ;To fill block of memory
    LEA MSG_CMD_BF,A5
    LEA MSG_CMD_BF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BF
    
    ;TO move block of memory
    LEA MSG_CMD_BMOV,A5
    LEA MSG_CMD_BMOV_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BMOV
   
   ;To perform destructive test on memory
    LEA MSG_CMD_BTST,A5
    LEA MSG_CMD_BTST_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ BTST
    
     
    ;To start execution from given address
    LEA MSG_CMD_GO,A5
    LEA MSG_CMD_GO_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ GO
    
    ;To display formatted register
    LEA MSG_CMD_DF,A5
    LEA MSG_CMD_DF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ DF
   
    LEA MSG_CMD_HEXSQR,A5
    LEA MSG_CMD_HEXSQR_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HEXSQR
    
    LEA MSG_CMD_EVENODD,A5
    LEA MSG_CMD_EVENODD_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ EVENODD

    ;To terminate the monitor program
    LEA MSG_CMD_EXIT,A5
    LEA MSG_CMD_EXIT_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ EXIT
    
    ;Invalid input
    BSR SYNTAX_ER
INTERPRETER_END:    
    RTS
    
;Compare strIng from A1 to NULL or SPACE 
;With string from A5 to A6
COMPARE:                    
    CMPI.B #SPACE,(A1)      ;Check if end of command(SPACE)
    BEQ COMPARE_CHK_END
    CMPI.B #NULL, (A1)
    BEQ COMPARE_CHK_END     ;Check if end of command(NULL)
    CMPI.B #DOT, (A1)
    BEQ COMPARE_CHK_END
    CMPA.L A5,A6
    BEQ COMPARE_END
    CMP.B (A1)+,(A5)+       
    BNE COMPARE_END         ;If content not the same end
    BRA COMPARE
COMPARE_CHK_END:
    CMPA.L A5,A6
COMPARE_END:
    RTS
    
; Convert HEX num (D0) to ASCII, length in D2 (Bytes) before use
; ASCII string buffer should start from A6
HEX2ASCII:
   MOVEM.L D1/D3, -(A7)
    ROL.L #1,D2
    MOVEA.L #$2500,A6
    MOVE.B #0,(A6)
   HEX2ASCII_LOOP:
    MOVE.L D0,D1
    ANDI.L #$0000000F,D1	;Get last digit (4 bits)
    CMPI.B #10,D1			;Compare with 10
    BGE CONVERT_HEX
    ADDI.B #$30,D1			;Convert to 0-9
    JMP STORE_ASCII
CONVERT_HEX:
    ADDI.B #$37,D1			;Convert to A-F
STORE_ASCII:
    MOVE.B D1, -(A6)		;Store to Stack(self defined stack)
    ROR.L #4,D0
    SUBI.B #1, D2			;Count to 0
    BNE HEX2ASCII_LOOP
    MOVEM.L (A7)+, D1/D3
    RTS

; Convert ASCII(START FROM A1) to HEX num (Will be storeed in D0) 
; length will be stored in D2
ASCII2HEX:
    MOVEM.L D1,-(A7)
    CLR.L   D2
    CLR.L   D1
    CLR.L   D0
    CMPI.B #DOLLAR, (A1)    ;Get rid of $ first
    BNE ASCII2HEX_LOOP
    ADDA #1,A1
ASCII2HEX_LOOP:
    MOVE.B (A1)+,D1
    CMPI.B #$30,D1     ;0-9
    BLT SYNTAX_ER
    CMPI.B #$39,D1
    BLE ASCII2HEX_NUM 
    CMPI.B #F_ASC,D1  ;A-F
    BGT SYNTAX_ER
    CMPI.B #A_ASC,D1
    BLT SYNTAX_ER
    SUBI.B #$37,D1
    BRA ASCII2HEX_SUM
ASCII2HEX_NUM    
    SUBI.B #$30,D1
ASCII2HEX_SUM
    ROL.L #4,D0    
    ADD.L D1, D0
    ADDQ.B #1,D2
    CMPI.B #SPACE,(A1)  ;If next char is SPACE or NULL end sub routine
    BEQ ASCII2HEX_END   
    CMPI.B #NULL,(A1)
    BEQ ASCII2HEX_END
    BRA ASCII2HEX_LOOP
ASCII2HEX_END
    ADDQ #1,D2          ;CONVERT DIGIT TO BYTE
    BCLR #0,D2
    ROR.L #1,D2    
    MOVEM.L (A7)+,D1
    RTS

;Store input buffer
STORE_HIS:
    MOVEM.L A1/A2,-(A7)
    LEA INPUT_BUFF,A1
    LEA HISTORY_BUFF,A2
STORE_HIST_LOOP:
    CMPI.B #0,(A1)
    BEQ STORE_HIS_END
    MOVE.B (A1)+,(A2)+
    BRA STORE_HIST_LOOP
STORE_HIS_END:
    MOVE.B #0,(A2)
    MOVEM.L (A7)+,A1/A2
    RTS  

*----------------COMMAND SUBROUTINE----------------------*
;Help
;Print help messages for each individual debugger command
HELP:
    BSR STORE_HIS 
    LEA MSG_HELP,A5
    LEA MSG_HELP_ED,A6  
    BSR PRINT 
    LEA MSG_CMD_FST,A5
    LEA MSG_CMD_LST,A6  
    BSR PRINT 
HELP_LOOP:
    ;Print help console prompt
    LEA MSG_CMD_HELP,A5
    LEA MSG_CMD_HELP_ED,A6
    MOVE.B #LARGER,(A6)+
    BSR PRINT_C
    
    ;User input command to be displayed
    BSR INPUT
    LEA INPUT_BUFF,A1

    ;Check if buffer is empty
    CMPI.B #NULL,(A1)
    BEQ HELP_LOOP
      
    ;To display memory 
    LEA MSG_CMD_MDSP,A5
    LEA MSG_CMD_MDSP_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_MDSP 
    
    ;To modify memory
    LEA MSG_CMD_MM,A5
    LEA MSG_CMD_MM_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_MM
    
    ;To set memory
    LEA MSG_CMD_MS,A5
    LEA MSG_CMD_MS_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_MS
    
    ;To fill block of memory
    LEA MSG_CMD_BF,A5
    LEA MSG_CMD_BF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BF
    
    ;To move block of memory
    LEA MSG_CMD_BMOV,A5
    LEA MSG_CMD_BMOV_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BMOV
    
    ;To test block of memory
    LEA MSG_CMD_BTST,A5
    LEA MSG_CMD_BTST_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BTST
    
    ;To do block search
    LEA MSG_CMD_BSCH,A5
    LEA MSG_CMD_BSCH_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_BSCH
  
    ;To start execution from given address
    LEA MSG_CMD_GO,A5
    LEA MSG_CMD_GO_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_GO  
    
    ;To display formatted registers
    LEA MSG_CMD_DF,A5
    LEA MSG_CMD_DF_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_DF
    
    
    
    ;To exit monitor program
    LEA MSG_CMD_EXIT,A5
    LEA MSG_CMD_EXIT_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_EXIT
    
    ;To calculate square of a hex number
    LEA MSG_CMD_HEXSQR,A5
    LEA MSG_CMD_HEXSQR_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_HEXSQR

;To check whether the number is even or odd
    LEA MSG_CMD_EVENODD,A5
    LEA MSG_CMD_EVENODD_ED,A6
    LEA INPUT_BUFF,A1
    BSR COMPARE
    BEQ HELP_EVENODD
    ;Exit help console
    LEA INPUT_BUFF,A1
    CMPI.B #Q_ASC,(A1)
    BEQ HELP_EXIT
    BRA HELP
    
HELP_EXIT:
          RTS
    
    
HELP_MDSP:
    LEA MSG_HELP_MDSP,A5
    LEA MSG_HELP_MDSP_ED,A6
    BSR PRINT
    BRA HELP_LOOP
    
HELP_MM:
    LEA MSG_HELP_MM,A5
    LEA MSG_HELP_MM_ED,A6
    BSR PRINT
    BRA HELP_LOOP    
    
HELP_MS:
    LEA MSG_HELP_MS,A5
    LEA MSG_HELP_MS_ED,A6
    BSR PRINT
    BRA HELP_LOOP  
    
HELP_BF:
    LEA MSG_HELP_BF,A5
    LEA MSG_HELP_BF_ED,A6
    BSR PRINT
    BRA HELP_LOOP  

HELP_BMOV:
    LEA MSG_HELP_BMOV,A5
    LEA MSG_HELP_BMOV_ED,A6
    BSR PRINT
    BRA HELP_LOOP

HELP_BTST:
    LEA MSG_HELP_BTST,A5
    LEA MSG_HELP_BTST_ED,A6
    BSR PRINT
    BRA HELP_LOOP
    
HELP_BSCH:
    LEA MSG_HELP_BSCH,A5
    LEA MSG_HELP_BSCH_ED,A6
    BSR PRINT
    BRA HELP_LOOP
    
HELP_GO:
    LEA MSG_HELP_GO,A5
    LEA MSG_HELP_GO_ED,A6
    BSR PRINT
    BRA HELP_LOOP 
  
HELP_DF:
    LEA MSG_HELP_DF,A5
    LEA MSG_HELP_DF_ED,A6
    BSR PRINT
    BRA HELP_LOOP
    
HELP_HEXSQR
    LEA MSG_HELP_HEXSQR,A5
    LEA MSG_HELP_HEXSQR_ED,A6
    BSR PRINT
    BRA HELP_LOOP

HELP_EVENODD
    LEA MSG_HELP_EVENODD,A5
    LEA MSG_HELP_EVENODD_ED,A6
    BSR PRINT
    BRA HELP_LOOP


;Block search
BSCH:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A4        ;Parse the second address
    CMPA.L A4,A3        ;Check if the first address is smalller
    BGE SYNTAX_ER       
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER
    MOVE.L A1,-(A7)
BSCH_LOOP_1:
    MOVE.L (A7),A1
    CMPA.L A3,A4
    BEQ BSCH_FAILD    
    CMPM.B (A3)+,(A1)+
    BNE BSCH_LOOP_1
    MOVE.L A3,D0
    SUBQ #1,D0
BSCH_LOOP_2:
    CMPA.L A3,A4
    BLT BSCH_FAILD 
    CMPM.B (A3)+,(A1)+
    BEQ BSCH_LOOP_2
    CMPI.B #0,-1(A1)
    BEQ BSCH_SUCCESS
    CMPA.L A3,A4
    BEQ BSCH_FAILD
    MOVE.L (A7),A1
    BRA BSCH_LOOP_1
BSCH_FAILD:
    LEA MSG_BSCH_FAILD,A5
    LEA MSG_BSCH_FAILD_ED,A6
    BSR PRINT
    BRA BSCH_END    
BSCH_SUCCESS:
    LEA MSG_BSCH_SUCCESS,A5
    LEA MSG_BSCH_SUCCESS_ED,A6
    BSR PRINT_C
    LEA OUTPUT_BUFF,A6
    BSR HEX2ASCII
    LEA OUTPUT_BUFF,A5
    BSR PRINT
    BRA BSCH_END
BSCH_END:
    ADDQ #4,A7    
    RTS


HEXSQR:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER 
    BSR ASCII2HEX
    MOVE.W D0,D4      
    MOVE.W D4,D1        ;Parse the first address
    MOVE D1,D2
    MULU D1,D2
    MOVE.W D2,D0
    MOVE.W #2,D2
    BSR HEX2ASCII
    MOVE.W A6,A1
    MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    BSR MAIN
    
EVENODD:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER     
    BSR ASCII2HEX
    MOVE.L D0,A3       ;Parse the first address
    MOVE.L A3,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODDN
    LEA EVENNUMBER,A1
	MOVE #14,D0
    TRAP #15
    LEA NEXTLINE,A1
    MOVE #14,D0
    TRAP #15
    BRA MAIN
ODDN   LEA ODDNUMBER,A1
	   MOVE #14,D0
       TRAP #15
       LEA NEXTLINE,A1
       MOVE #14,D0
       TRAP #15
       BRA MAIN
       

    
;MEMORY DISPLAY
MDSP:
     BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address
    CMPI.B #NULL,(A1)+ 
    BEQ TYPE2       
    BSR ASCII2HEX
    MOVE.L D0,A4
    MOVE.L A3,A2
    MOVE.L D2,D4
    MOVE.L #4,D5
    BRA DISPLAY
    
TYPE2:
    MOVE.L A3,A4
    ADD.L #8,A4

    MOVE.L A3,A2

    MOVE.L D2,D4
    MOVE.L #4,D5



DISPLAY:
    MOVE.L A2,D0
    MOVE.L D4,D2
    BSR HEX2ASCII
    ADD.L #4, A6
    MOVE.L -(A6),D1
    SWAP D1
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
     ;PRINT SEMICOLON
    MOVEA.L #SEMI,A1     
    MOVE.B #14,D0
    TRAP #15
    
    ;PRINT CONTENT
    CLR.L D0
    MOVE.L D5,D2
    MOVE.B (A2),D0
    BSR HEX2ASCII
    ADD.L #4,A6
    MOVE.L (A6),D1 
     
    
    ROR #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROR #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ;PRINT empty space
    MOVEA.L #SPACE1,A1     
    MOVE.B #13,D0
    TRAP #15
    
    ADD.L #1,A2
    CMPA.L A2,A4
    BGE DISPLAY
    BSR MAIN
    
MM:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A4        ;Parse the second address
*    CMPA.L A4,A3        
*    BGE ADDR_CMP
    MOVE.L A3,A2
    MOVE.L D2,D4
    MOVE.L #4,D5
    MOVE.W (A1),D6
    CMPI.B #66,D6
    BEQ BYTE_MOD
    CMPI.B #87,D6
    BEQ WORD_MOD
    CMPI.B #$4C,D6
    BEQ LONG_MOD
    LEA ERR_MM,A1
    MOVE.B #14,D0
    TRAP #15
    LEA NEXTLINE,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MM_EXIT

BYTE_MOD: 
    ;PRINT MEMLOC
    MOVE.L A2,D0
    MOVE.L D4,D2
    BSR HEX2ASCII
    ;bit manipulation that helps with printing memory location by byte
    ADD.L #4,A6
    MOVE.L -(A6),D1 
     
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15

    
*   ;PRINT SEMICOLON
    MOVEA.L #SEMI,A1     
    MOVE.B #14,D0
    TRAP #15    
    ;PRINT CONTENT
    CLR.L D0
    MOVE.L D5,D2
    MOVE.B (A2),D0
    BSR HEX2ASCII
    ADD.L #4,A6
    MOVE.L (A6),D1 
    
    ROR #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROR #8,D1
    MOVE.B #6,D0
    TRAP #15
*   
    MOVEA.L #EQUALTWO,A1
    MOVE.B #14,D0
    TRAP #15
*    CLR.L (A1)
    ;PROMPT FOR INPUT,CONTINUE UNLESS IT IS DOT
    LEA $5000,A1
    MOVE.B #2,D0
    TRAP #15
    
    MOVE.W (A1),D6
    ADD.L #$30300000,D6
*    ADD.L #00000000,D6
*    MOVE.L D6,(A1)
    BSR ASCII2HEX
    MOVE.B D0,(A2)
    ADD.L #1,A2
    CMPA.L A2,A4
    BGE BYTE_MOD
    BSR MM_EXIT

WORD_MOD: 
     ;PRINT MEMLOC
    MOVE.L A2,D0
    MOVE.L D4,D2
    BSR HEX2ASCII
    ;bit manipulation that helps with printing memory location by byte

     ADD.L #4,A6
     MOVE.L -(A6),D1 
     
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15

    
*    ;PRINT SEMICOLON
   MOVEA.L #SEMI,A1     
    MOVE.B #14,D0
    TRAP #15
    
    ;PRINT CONTENT
    CLR.L D0
    MOVE.L D5,D2
    MOVE.W (A2),D0
    BSR HEX2ASCII
    ADD.L #4,A6
    MOVE.L (A6),D1 
    
    SWAP D1
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15

*   
    MOVEA.L #EQUALTWO,A1
    MOVE.B #14,D0
    TRAP #15
    
*    CLR.L (A1)
    ;PROMPT FOR INPUT,CONTINUE UNLESS IT IS DOT
    LEA $5000,A1
    MOVE.B #2,D0
    TRAP #15
    
    MOVE.L (A1),D6
*    ADD.L #$30300000,D6
*    ADD.L #00000000,D6
*    MOVE.L D6,(A1)
    BSR ASCII2HEX
    MOVE.W D0,(A2)
    ADD.L #2,A2
    CMPA.L A2,A4
    BGE WORD_MOD
    BSR MM_EXIT

    
LONG_MOD: 
     ;PRINT MEMLOC
    MOVE.L A2,D0
    MOVE.L D4,D2
    BSR HEX2ASCII
    ;bit manipulation that helps with printing memory location by byte

     ADD.L #4,A6
     MOVE.L -(A6),D1 
     
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15

    
*    ;PRINT SEMICOLON
   MOVEA.L #SEMI,A1     
    MOVE.B #14,D0
    TRAP #15
    
    ;PRINT CONTENT
    CLR.L D0
    ADD.L #4,D5
    MOVE.L D5,D2
    MOVE.L (A2),D0
    BSR HEX2ASCII
    ADD.L #12,A6
    MOVE.W (A6),D1 
    
   SWAP D1
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
  
  
    ;PRINT SECOND WORD
    ;PRINT CONTENT
    CLR.L D0
    MOVE.L D5,D2
    MOVE.L (A2),D0
    BSR HEX2ASCII
    ADD.L #12,A6
    MOVE.W (A6),D1 

     
    SWAP D1
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    SWAP D1
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15
    
    ROL #8,D1
    MOVE.B #6,D0
    TRAP #15

*   
    MOVEA.L #EQUALTWO,A1
    MOVE.B #14,D0
    TRAP #15
    
*    CLR.L (A1)
    ;PROMPT FOR INPUT,CONTINUE UNLESS IT IS DOT
    LEA $5000,A1
    MOVE.B #2,D0
    TRAP #15
    
    MOVE.L (A1),D6
*    ADD.L #$30300000,D6
*    ADD.L #00000000,D6
*    MOVE.L D6,(A1)
    BSR ASCII2HEX
    MOVE.L D0,(A2)
    ADD.L #4,A2
    CMPA.L A2,A4
    BGE LONG_MOD
    BSR MM_EXIT   
MM_EXIT: 
      BSR MAIN
      RTS




MS: BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address IN A3
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,D4        ;Parse the string IN D4
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER 
    CMPI.B #'H',(A1)
    BEQ MS_HEX
    CMPI.B #'A',(A1)
    BEQ MS_ASCII
    LEA ERR_MS,A1
    MOVE.B #14,D0
    TRAP #15
    LEA NEXTLINE,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MS_EXIT

MS_HEX: 
    MOVE.L D4,(A3)
    LEA SUCCESS_MS,A1
    MOVE.B #14,D0
    TRAP #15
    LEA NEXTLINE,A1
    MOVE.B #14,D0
    TRAP #15
    BRA MS_EXIT 
        
MS_ASCII: MOVE.L D4,D0
        BSR HEX2ASCII
        MOVE.L (A6),(A3)
        LEA SUCCESS_MS,A1
        MOVE.B #14,D0
        TRAP #15
        LEA NEXTLINE,A1
        MOVE.B #14,D0
        TRAP #15
        BRA MS_EXIT         
MS_EXIT: BRA MAIN
          

BF:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER     
    BSR ASCII2HEX
    MOVE.L D0,A3       ;Parse the first address
    MOVE.L A3,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A4        ;Parse the second address
    MOVE.L A4,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD
    CMPA.L A4,A3        ;Check if the first address is smalller
    BGE SYNTAX_ER 
    ADD.L #1,A4      
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER
    BSR ASCII2HEX
    MOVE.L D0,A5

BF1:
    MOVE.W A5,(A3)+
    CMPA.L A3,A4
    BGT BF1
    BRA MAIN
ODD: 
    LEA EVEN,A1
    MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    BSR MAIN

BMOV:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address
    MOVE.L A3,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A4        ;Parse the second address
    MOVE.L A4,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD

    CMPA.L A4,A3        ;Check if the first address is smalller
    BGE SYNTAX_ER 
    ADD.L #1,A4      
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER
    BSR ASCII2HEX
    MOVE.L D0,A5
    MOVE.L A5,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD

BMOV1:
    MOVE.L (A3)+,(A5)+
    CMPA.L A3,A4
    BGT BMOV1
    BRA MAIN

BTST:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3       ;Parse the first address
    MOVE.L A3,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD
    CMPI.B #SPACE,(A1)+ 
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A4        ;Parse the second address
    MOVE.L A4,D0
    DIVU #2,D0
    SWAP D0
    CMP.W #0,D0
    BNE ODD
    CMPA.L A4,A3        ;Check if the first address is smalller
    BGE SYNTAX_ER 
    ADD.L #1,A4    
    MOVE.L #$0101,A5  
    
BTST1:
    MOVE.W A5,(A3)  ;MOVE THE WORD TO START
    MOVE.W (A3)+,D5  ;READ THE WORD
    CMP.W A5,D5      
    BNE BTSTERROR   ;IF NOT EQUAL GO TO SUBROUTINE 
    CMPA.L A3,A4
    BGT BTST1
    LEA MSG_BTST_SUCCESS,A5
    LEA MSG_BTST_SUCCESS_ED,A6
    BSR PRINT
    BRA MAIN

BTSTERROR:
    LEA MSG_BTST_FAILD,A5
    LEA MSG_BTST_FAILD_ED,A6
    BSR PRINT
    BRA MAIN

SYNTAX_ER:
    LEA MSG_WRONG_CMD,A5
    LEA MSG_WRONG_CMD_ED,A6
    BSR PRINT
    LEA MSG_HELP_PROM,A5
    LEA MSG_HELP_PROM_ED,A6
    BSR PRINT
    BRA MAIN

* Put program code here

    SIMHALT             ; halt simulator
DF         
DISP_PC     
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            LEA PC_REG,A1                 ;Display PC REGISTER
            MOVE #14,D0
            TRAP #15
            MOVE.L #'=',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE #DISP_PC,D0
            MOVE.L #4,D2
            JSR HEX2ASCII
            MOVEA.L A6,A1
            MOVE #14,D0
            TRAP #15
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15

DISP_SSP
            LEA SSP_REG,A1                 ;Display SSP REGISTER
            MOVE #14,D0
            TRAP #15
            MOVE.L #'=',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            
            MOVE A7,D1
            MOVE.B #16,D2    
            MOVE.B #15,D0
            TRAP #15

            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
           
DISP_USP    
            LEA USP_REG,A1                 ;Display USP REGISTER
            MOVE #14,D0
            TRAP #15
            MOVE.L #'=',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
                    
             MOVE.L USP,A1
             MOVE.L A1,D1
             MOVE.B #16,D2    
             MOVE.B #15,D0
             TRAP #15
             
            LEA NEXTLINE,A1 
            MOVE #14,D0
            TRAP #15
                                                    
DISP_SR     LEA SR_REG,A1                 ;Display SR REGISTER
            MOVE #14,D0
            TRAP #15
            MOVE.L #'=',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE SR,D0
            MOVE.L #4,D2
            JSR HEX2ASCII
            MOVEA.L A6,A1
            MOVE #14,D0
            TRAP #15
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15


DF_REG      LEA REG,A1                 
            MOVE #14,D0
            TRAP #15
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            BSR PRINT_REG
            BSR DISP_REG
            BRA MAIN
            
DISP_REG    LEA STACK_BEG,A2                                          ;Display A0 and D0 register
            MOVE.L #'0',D6
DISP_DATAREG  MOVE.B #'D',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE.B D6,D1                  ;D7 AS TEMP
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE.L #'=',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE.L (A2)+,D0
            MOVE.L #4,D2
            JSR HEX2ASCII
            MOVEA.L A6,A1
            MOVE #14,D0
            TRAP #15
            ADDI.L #$1,D6
            CMPI.L #'8',D6
            BEQ DF_END
            LEA SPACE1,A1
            MOVE #14,D0
            TRAP #15
            CMPI.L #'4',D6
            BNE DISP_DATAREG
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            BNE DISP_DATAREG
DF_END      LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            
            MOVE.B #'0',D6
DISP_ADDREG MOVE.B #'A',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE.L D6,D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE.L #'=',D1
            MOVE.L D1,A1
            MOVE #6,D0
            TRAP #15
            MOVE.L (A2)+,D0
            MOVE.L #4,D2
            JSR HEX2ASCII
            MOVEA.L A6,A1
            MOVE #14,D0
            TRAP #15
            
            ADDI.L #$1,D6
            CMPI.L #'8',D6
            BEQ DF_END1
            LEA SPACE1,A1
            MOVE #14,D0
            TRAP #15
            CMPI.L #'4',D6
            BNE DISP_ADDREG
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            BRA DISP_ADDREG
DF_END1     LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            LEA NEXTLINE,A1
            MOVE #14,D0
            TRAP #15
            RTS

PRINT_REG
            MOVE.L A2,STACK_END
            LEA STACK_BEG, A2
            MOVE.L D0,(A2)+
            MOVE.L D1,(A2)+
            MOVE.L D2,(A2)+
            MOVE.L D3,(A2)+
            MOVE.L D4,(A2)+
            MOVE.L D5,(A2)+
            MOVE.L D6,(A2)+
            MOVE.L D7,(A2)+
            MOVE.L (STACK_END),(A2)+
            MOVE.L A1,(A2)+
            MOVE.L A2,(A2)+
            MOVE.L A3,(A2)+
            MOVE.L A4,(A2)+
            MOVE.L A5,(A2)+
            MOVE.L A6,(A2)+
            MOVE.L A7,(A2)+
            RTS 
            
GO:
    BSR STORE_HIS
    CMPI.B #SPACE,(A1)+ ;Get rid of the space after command
    BNE SYNTAX_ER       
    BSR ASCII2HEX
    MOVE.L D0,A3        ;Parse the first address
    JSR (A3)
    BRA MAIN
    
EXIT:
     LEA EXIT_MESSAGE,A1
     MOVE #14,D0
	 TRAP #15
     MOVE.B #9,D0
     TRAP #15
  
 ** BUS ERROR EXCEPTION     
*     
    ORG $7520
    MOVE.L #$FF,D0
    MOVE.B $A00000,D0
    BRA MAIN

    ORG $7000
    MOVEM.L A0-A6/D0-D7,-(SP)
    LEA BUS_ERROR,A1
	MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
        
    ;PRINT BA
    LEA BUSADDRESS,A1
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.L (18,A7),D1
    MOVE.B #16,D2
    MOVE.B #15,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    
    ;PRINT IR
    LEA IRTEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    CLR.L D1 
    MOVE.W (22,A7),D1
    MOVE.B #16,D2
    MOVE.B #15,D0
    TRAP #15
    
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    ;PRINT SSW
    LEA SSWTEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    CLR.L D1 
    MOVE.W (16,A7),D1
    MOVE.B #16,D2
    MOVE.B #15,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    
    ;PRINT EMPTY LINE TO END
    LEA SPACE,A1
    MOVE.B #13,D0
    TRAP #15
    
    MOVEM.L (SP)+,A0-A6/D0-D7
    BRA  DF

* ADDRESS ERROR EXCEPTION     
    
    ORG $9000
    MOVE.W $1234,$5001
    BRA MAIN
    ORG $7100
    MOVEM.L A0-A6/D0-D7,-(SP)
    LEA ADDRESS_ERROR,A1
	MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    
    ;PRINT OUT BERR STRING
    
        
    ;PRINT BA
    LEA BUSADDRESS,A1
    MOVE.B #14,D0
    TRAP #15
    
    MOVE.L (18,A7),D1
    MOVE.B #16,D2
    MOVE.B #15,D0
    TRAP #15
    
    
    ;PRINT IR
    LEA IRTEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    CLR.L D1 
    MOVE.W (22,A7),D1
    MOVE.B #16,D2
    MOVE.B #15,D0
    TRAP #15
    
    ;PRINT SSW
    LEA SSWTEXT,A1
    MOVE.B #14,D0
    TRAP #15
    
    CLR.L D1 
    MOVE.W (16,A7),D1
    MOVE.B #16,D2
    MOVE.B #15,D0
    TRAP #15
    
    ;PRINT EMPTY LINE TO END
    LEA SPACE,A1
    MOVE.B #13,D0
    TRAP #15
    
    MOVEM.L (SP)+,A0-A6/D0-D7
    BRA  DF
* ILLEGAL ERROR EXCEPTION     
    
     ORG $6666
     DC.W $4AFC
     BRA MAIN
     ORG $7200
     LEA ILLEGAL_ERROR,A1
	 MOVE #14,D0
	
     TRAP #15
     LEA NEWLINE,A1
     MOVE #14,D0
     TRAP #15
     BSR DF
    
    
* DIVIDE BY ZERO EXCEPTION 
   
    ORG $5000
    MOVE.B #0,D1		;DIVIDE BY ZERO ERROR
	MOVE.B #5,D2
	DIVU D1,D2
	BRA MAIN
	
	ORG $7300
    LEA DIVIDE_ERROR,A1
	MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    BSR DF
 
* PRIVILEGE ERROR EXCEPTION 
    
                       ORG $5050
Privilege_violation    ANDI.W #$0700,SR
                       BRA Privilege_violation
    
      ORG $7400
	LEA PRIVILEGE_ERROR,A1
    MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    BSR DF
	
** LINE 1010 ERROR EXCEPTION    
     
    ORG $7666
    DC.W $AAAA
    BRA MAIN
    ORG $7500
    LEA LINEA_EXCEPTION,A1
	MOVE #14,D0
    TRAP #15
    LEA NEWLINE,A1
    MOVE #14,D0
    TRAP #15
    BSR DF
	
* LINE 1111 ERROR EXCEPTION  	
     
    ORG $8666
    DC.W $FFFF
    BRA MAIN
	 ORG $7600 
     MOVE $F000,A0   
     LEA LINEF_EXCEPTION,A1
	 MOVE #14,D0
     TRAP #15
     LEA NEWLINE,A1
     MOVE #14,D0
     TRAP #15
     BSR DF
     
	
* CHECK ERROR EXCEPTION
     
     ORG $4260  

     MOVE.L #$3000,D6
     MOVE.L #$3010,D7
     CHK.W D6,D7 
     BRA MAIN
     
     ORG $7700 
     LEA CHECK_ERROR,A1
	 MOVE #14,D0
     TRAP #15
     LEA NEWLINE,A1
     MOVE #14,D0
     TRAP #15
     BSR DF

*----------------COMMON SYMBOLS--------------------------*
BUFFSIZE    EQU     $256    ;BUFF SIZE IS EQUAL TO $256
SPACE       EQU	    $20     ;SPACE IN ASCII
CR          EQU     $0D     ;CARRIGE RETURN IN ASCII
LF          EQU     $0A     ;LINE FEED IN ASCII
NULL        EQU     $00     ;NULL
COLON	    EQU     $3A     ; : IN ASCII
COMMA	    EQU	    $2C     ; , IN ASCII
DOT	        EQU	    $2E     ; . IN ASCII
DOLLAR	    EQU	    $24     ; $ IN ASCII
A_ASC	    EQU	    'A'
B_ASC	    EQU	    'B'
D_ASC	    EQU	    'D'
F_ASC       EQU     'F'
G_ASC	    EQU	    'G'
H_ASC	    EQU	    'H'
L_ASC       EQU     'L'
M_ASC	    EQU	    'M'
Q_ASC		EQU		'Q'
S_ASC	    EQU	    'S'
W_ASC       EQU     'W'
LARGER      EQU     '>'  
    
PC_REG      DC.W    'PC',CR,LF,0
SSP_REG      DC.W    'SSP',CR,LF,0
USP_REG      DC.W    'USP',CR,LF,0
REG           DC.W    'Address and Data registers:',CR,LF,0
SR_REG        DC.W    'SR',CR,LF,0
STACK_BEG     EQU     $3000
STACK_END  EQU     $3050

ILLEGAL_ERROR        DC.W 'Illegal Error Exception',CR,LF,0
ADDRESS_ERROR        DC.W 'Address Error Exception',CR,LF,0
PRIVILEGE_ERROR      DC.W 'Privilege Error Exception',CR,LF,0
LINEA_EXCEPTION      DC.W 'Line 1010 Error Exception',CR,LF,0
LINEF_EXCEPTION      DC.W 'Line 1111 Error Exception',CR,LF,0
CHECK_ERROR          DC.W 'Check Error Exception',CR,LF,0
BUS_ERROR            DC.W 'Bus Error Exception',CR,LF,0
DIVIDE_ERROR         DC.W 'Divide By Zero Error Exception',CR,LF,0
EXIT_MESSAGE          DC.W 'Monitor Program Terminated',0
EVEN                 DC.W 'Please enter even address',CR,LF,0
EVENNUMBER           DC.W 'The entered number is EVEN',CR,LF,0
ODDNUMBER            DC.W 'The entered number is ODD',CR,LF,0
SUCCESS_MS          DC.B 'The data was successfully stored in the memory',CR,LF,0
     



BUSADDRESS       DC.W        'BA=',CR,LF,0
IRTEXT        DC.W        'IR=',CR,LF,0
SSWTEXT          DC.W        'SSW=',CR,LF,0
NEXTLINE     DC.B CR,LF,0


*---------------COMMAND MESSAGES------------------*
MSG_CMD_HELP    DC.B    'HELP'
MSG_CMD_HELP_ED:   
	DC.B	CR,LF 
MSG_CMD_FST:
MSG_CMD_MDSP    DC.B    'MDSP'
MSG_CMD_MDSP_ED:
	DC.B	CR,LF
	
MSG_CMD_MM    DC.B    'MM'
MSG_CMD_MM_ED:
	DC.B	CR,LF
	
MSG_CMD_MS    DC.B    'MS'
MSG_CMD_MS_ED:
	DC.B	CR,LF
	
MSG_CMD_BF    DC.B    'BF'
MSG_CMD_BF_ED:
	DC.B	CR,LF

MSG_CMD_BMOV    DC.B    'BMOV'
MSG_CMD_BMOV_ED:
	DC.B	CR,LF	
	
MSG_CMD_BTST    DC.B    'BTST'
MSG_CMD_BTST_ED:
	DC.B	CR,LF	
	
MSG_CMD_BSCH    DC.B    'BSCH'
MSG_CMD_BSCH_ED:
	DC.B	CR,LF

MSG_CMD_DF    DC.B    'DF'
MSG_CMD_DF_ED:
	DC.B	CR,LF	
	
MSG_CMD_GO    DC.B    'GO'
MSG_CMD_GO_ED:
	DC.B	CR,LF	
	
MSG_CMD_EXIT    DC.B    'EXIT'
MSG_CMD_EXIT_ED:
	DC.B	CR,LF	
MSG_CMD_HEXSQR    DC.B    'HEXSQR'
MSG_CMD_HEXSQR_ED:
	DC.B	CR,LF	
MSG_CMD_EVENODD    DC.B    'EVENODD'
MSG_CMD_EVENODD_ED:
	DC.B	CR,LF
MSG_CMD_LST:

*----------------COMMON MESSAGES------------------*
MSG_WELCOME:
    DC.B 'System initialised. Please input your command.',CR,LF 
    DC.B 'Type "EXIT" to terminate the program anytime.',CR,LF
MSG_WELCOME_ED
MSG_PROM:
    DC.B 'ECE441 MONITOR>'
MSG_PROM_ED
MSG_HELP:
    DC.B	'Enter the command you need help with.'
    DC.B 	CR,LF,'Type "Q" to come out of the help console.'
MSG_HELP_ED
MSG_BSCH_SUCCESS:
    DC.B 'Content found at: $'
MSG_BSCH_SUCCESS_ED
MSG_BSCH_FAILD:
    DC.B 'Content not found'
MSG_BSCH_FAILD_ED
MSG_BTST_SUCCESS
    DC.B 'Block test Successful'
MSG_BTST_SUCCESS_ED
MSG_BTST_FAILD
    DC.B 'Block test failed'
MSG_BTST_FAILD_ED

MSG_WRONG_CMD:
    DC.B 'Wrong command'
MSG_WRONG_CMD_ED
MSG_HELP_PROM:
    DC.B	'Enter "HELP" for help info.'
MSG_HELP_PROM_ED
MSG_FINISH:
    DC.B 'Finshed'
MSG_FINISH_ED
MSG_HIS_EMPTY:
    DC.B 'No command to recall.'
MSG_HIS_EMPTY_ED

NEWLINE         DC.B CR,LF,0
QUESTION        DC.B '>',0
SPACE1          DC.B ' ',0
SEMI          DC.B ' : ',0
LINEPROMPT    DC.B ' --> ',0
REGISTER        DC.W    'SR',CR,LF,0
EQUALTWO:
    DC.B ' = '
    DC.B 0    
    










   
*--------------HELP MESSAGES----------------------*

;BSCH
MSG_HELP_BSCH:
    DC.B	'Search for specific pattern (input as string) within',CR,LF 
    DC.B	'a memory range. If found, print the location of such',CR,LF
    DC.B	'string, if not found print failed promotion.',CR,LF 
    DC.B	'Syntax - BSCH <addr1> <addr2> string'
MSG_HELP_BSCH_ED

;MDSP
MSG_HELP_MDSP:
    DC.B	'The command outputs the address and memory contents from.',CR,LF 
    DC.B	'<address1> to <address2>',CR,LF
    DC.B	'The command also outputs the address and memory contents from',CR,LF 
    DC.B	'<address1> to <address1 + 16bytes>',CR,LF
    DC.B	'Syntax - MDSP <addr1> <addr2> or MDSP <addr1> '
MSG_HELP_MDSP_ED

;MM
MSG_HELP_MM:
    DC.B	'The memory modify command is used to display and modify data',CR,LF 
    DC.B	'The size (byte, word, long word) controls the number of bytes',CR,LF
    DC.B	'displayed for each address.',CR,LF 
    DC.B	'Syntax - MM <addr1> <addr2> <B/W/L>'
MSG_HELP_MM_ED

;MS
MSG_HELP_MS:
    DC.B	'The command alters memory by setting data into the address specified.',CR,LF
    DC.B	'The data can take the form of ASCII string or hexadecimal data.',CR,LF  
    DC.B	'Syntax - MS <addr> <data> <A/H>'
MSG_HELP_MS_ED

;BF
MSG_HELP_BF:
    DC.B	'The command fills memory starting with the word boundary from',CR,LF 
    DC.B	'<addr1> to <addr2>. The command fills with only word-size pattern',CR,LF 
    DC.B	'Syntax - BF <addr1> <addr2> Hex-value'
MSG_HELP_BF_ED

;BMOV
MSG_HELP_BMOV:
    DC.B	'The command is used to move blocks of memory from',CR,LF 
    DC.B	'one area to another',CR,LF 
    DC.B	'Syntax - BMOV <addr1> <addr2> <addr3>'
MSG_HELP_BMOV_ED

;BTST
MSG_HELP_BTST:
    DC.B	'The command performs destructive test for a block of memory',CR,LF 
    DC.B	'If the test runs to completion, success message is displayed.',CR,LF 
    DC.B	'Else,address of the memory, data stored and data read are displayed ',CR,LF 
    DC.B    'Syntax - BTST <addr1> <addr2>',CR,LF
MSG_HELP_BTST_ED

;DF
MSG_HELP_DF:
    DC.B	'The command displays the MC68K processor registers.',CR,LF 
    DC.B	'The command displays current PC, SR, US, SS and D, A registers.',CR,LF 
    DC.B	'Syntax - DF'
MSG_HELP_DF_ED

;GO
MSG_HELP_GO:
    DC.B	'The command is used to start the execution of program',CR,LF 
    DC.B	'from given address. Syntax - GO <addr>'
MSG_HELP_GO_ED

;EXIT
MSG_HELP_EXIT:
    DC.B 	'The command terminates the monitor program. '
MSG_HELP_EXIT_ED


MSG_HELP_HEXSQR:
    DC.B 	'The command calculates the square of a hex number.',CR,LF
    DC.B	'Syntax - HEXSQR <hexvalue>'
MSG_HELP_HEXSQR_ED

MSG_HELP_EVENODD:
    DC.B 	'The command checks whether the given number is even or odd.',CR,LF
    DC.B	'Syntax - EVENODD <hexvalue>'
MSG_HELP_EVENODD_ED

ERR_MM:
    DC.B ' Please enter valid mode, enter HELP for information '
    DC.B 0
ERR_MS:
    DC.B ' Please enter valid mode, enter HELP for information '
    DC.B 0


BUS_VECTOR        EQU     $7000
ADDRESS_VECTOR    EQU     $7100

ILLEGAL_VECTOR    EQU     $7200

DIVZ_VECTOR       EQU     $7300

PRIVILEGE_VECTOR  EQU     $7400

LINEA_VECTOR      EQU     $7500

LINEF_VECTOR      EQU     $7600

CHECK_VECTOR      EQU     $7700

    ORG $3000
INPUT_BUFF:
    DS.B    BUFFSIZE 
OUTPUT_BUFF:
    DS.B    BUFFSIZE
HISTORY_BUFF:
    DS.B    BUFFSIZE    
ADDR_BUFF:
    DS.B    8
    ORG $4000
    DS.B    1024    ;RESERVE 1KB FOR A7 STACK
STACK:    
    DS.L    20      ;RESERVE 40 BYTES FOR
REGISTER_STACK: 
    DS.L    1
REGISTER_PC:   
    DS.L    1
    END    START        
    



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
