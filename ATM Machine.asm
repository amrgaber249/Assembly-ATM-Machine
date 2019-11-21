
;Name:Amr Mohamed Gaber


name 'ATM Machine'


.data
MSG0 DB 'WELCOME TO **** ATM-MACHINE','$'
MSG1 DB 'ENTER PASSWORD  : ','$'
MSG2 DB 'WRONG PASSWORD !!! ACCESS DENIED, TRY AGAIN','$'
MSG3 DB 'ACCESS ALLOWED  :D !!!',0 
MSG4 DB 'ENTER YOUR CARD : ','$'
MSG5 DB 'Card does not exist or Expired, Re-Enter Your Card!','$' 
linefeed db 13, 10, "$"	
DATA1 DW 0000H,0001H,0002H,0003H,0004H,0005H,0006H,0007H,0008H,0009H ; list of Card Numbers
DATA2 DW 000AH,000BH,000CH,000DH,000EH,000FH,0010H,0011H,0012H,0013H
DATA3 DW 0000H,0001H,0002H,0003H,0004H,0005H,0006H,0007H,0008H,0009H ; list of Passwords
DATA4 DW 000AH,000BH,000CH,000DH,000EH,000FH,0010H,0011H,0012H,0013H
DATAC DB  5,?,5 DUP (?) ; current card
DATAP DB  5,?,5 DUP (?) ; current password
; 1st 5 is for discovery of length, and the input will take 4H places


.code
MAIN	   	 PROC
	   		MOV AX,@DATA 			; Initialize AX, DS & ES data segment offset 
            		MOV DS,AX			; 
           		MOV ES,AX  			;
			
			
START:		
			CALL CLRSCR			; clear screen
			CALL WLCM			; greeting the customer  
			CALL NWLINE			; make a new line
			CALL VCRD			; vladiate card input
			CALL NWLINE			; make a new line
			CALL VPWD			; vladiate password
			CALL NWLINE			; make a new line
			CALL VALID			; allow access if you entered the correct combination of card# and password#
			
			
CLRSCR		PROC
			MOV AX,03H			; reset cursor to the start and-
           	        INT 10H				; clear everything
			CALL NWLINE			; make a new line
			RET
CLRSCR		ENDP	


NWLINE		PROC
			LEA DX,linefeed			; get message
			MOV AH,09H			; display string function 
			INT  21H			; display message 
			RET
NWLINE		ENDP


WLCM		PROC
			LEA DX,MSG0			; get message
			MOV AH,09H			; display string function 
			INT  21H			; display message 
			CALL NWLINE			; make a new line
			RET
WLCM		ENDP	


VCRD      	  PROC
            		LEA  DX,MSG4			; get message 
			MOV  AH,09H			; display string function 
			INT  21H			; display message 
			CALL CRDIN			; card is inside atm machine
			LEA  SI,DATAC+2			; move the card number to SI
			CALL SETCMP			; put the card number into AX for vladiation
			CALL CRDCHCK			; check if card is valid
			RET
VCRD       	 ENDP


VPWD       	 PROC
            		LEA  DX,MSG1			; get message 
			MOV  AH,09H			; display string function 
			INT  21H			; display message 
			CALL PWDIN			; a password is entered 
			LEA  SI,DATAP+2			; move the password to SI
			CALL SETCMP			; put the password into AX for vladiation
			CALL PWDCHCK			; check if password is valid
			RET
VPWD     	ENDP


CRDIN      	PROC				
           		LEA DX,DATAC			; load the empty card list
            		MOV AH,0AH			; scan user input
           		INT 21H 			;
           		RET
CRDIN     	ENDP


PWDIN       	PROC				
            		LEA DX,DATAP			; load the empty password list
            		MOV AH,0AH			; scan user input
            		INT 21H 			; 
            		RET
PWDIN      	ENDP


CRDCHCK     	PROC
            		MOV CX,21            		; SET CX = 21 people
            		LEA DI,DATA1         		; SET DI = DATA1 offset (list of Card Numbers)
            		CLD                  		; DF = 0 (AUTO INCREAMENT) to traverse through the list
            		REPNE SCASW          		; Check if the card is valid(COMPARE AX WITH DI)
            		CMP CX,0         	 	; could not find it in the 20 customers ?
            		JZ WRNGCRD           		; If it is not valid go to WRNGCRD
            		RET        
CRDCHCK     	ENDP  


PWDCHCK     	PROC
            		MOV BX,AX			; to not change AX
            		ADD DI,38			; jump to the same index in list of Passwords
            		CMP BX,[DI]          		; Check if the password correct or not    
            		JNZ WRNGPWD          		; If it is not valid go to WRNGCRD
            		RET          
PWDCHCK     	ENDP 


WRNGCRD     	PROC 
			CALL NWLINE			; make a new line
            		LEA DX,MSG5			; get message 
			MOV AH,09H			; display string function 
			INT 21H				; display message 
			MOV CX,0F0H			; timer so the screen does not change too quickly
			LOOP $				;
            		JMP START			; restart the machine to accept a new card
            		RET
WRNGCRD     	ENDP


WRNGPWD     	PROC 
			CALL NWLINE			; make a new line
            		LEA DX,MSG2			; get message 
			MOV AH,09H			; display string function 
			INT 21H				; display message 
			MOV CX,0F0H			; timer so the screen does not change too quickly
			LOOP $				;
            		JMP START			; restart the machine to accept a new card
            		RET
WRNGPWD     	ENDP


SETCMP      	PROC 
            		MOV CX,4			; 4-number input
LOOP1:	    		CMP [SI],39H			; is it a number ?
            		JBE NUM         		; if yes, go to num case
            		JA  LETR    			; o.w. go to letr case
NUM:        		SUB [SI],30H			; change the number character from ascii to hexa
            		JMP INCR         		; increment the counter and goto next element
LETR:       		CMP [SI],46H			; find if the letter in upper or lower case
            		JBE UPPER			; case1 if it was upper
            		JA  LOWER			; case2 if it was lower
UPPER :     		SUB [SI],37h			; change the lower case letter from ascii to hexa
            		JMP INCR 			; increment the counter and goto next element
LOWER:      		SUB [SI],57H			; change the upper case letter from ascii to hexa	       		
INCR:       		INC SI 				; goto next element
            		DEC CX   			; sub from counter
            		JNZ LOOP1       		; loop till you finish all 4 elements
            		SUB SI,4         		; to go back to the 1st element
            		MOV AH,[SI]         		; AX =  0  N1  0  N3
            		MOV BH,[SI+1]       		; BX =  0  N2  0  N4
            		MOV AL,[SI+2]       		; after shift
            		MOV BL,[SI+3]       		; AX =  N1  0  N3  0
            		SHL AX,4            		; BX =  0  N2  0  N4
            		OR  AX,BX           		; after or
            		RET                 		; AX =  N1  N2  N3  N4
SETCMP      	ENDP  


VALID       	PROC				
			CALL NWLINE			; make a new line
            		MOV SI,0			; will act as index to each char in the string
NXTLTR:     		MOV AL,MSG3[SI]			; get first letter
            		CMP AL,0			; did the string end ?
            		JE  EOT				; if yes, go to end of text
            		MOV AH,0EH 			; if no, print the char and advance the cursor 
            		INT 10H				; (teletype output)
            		INC SI				; go to next letter
            		JMP NXTLTR			;
EOT:			MOV CX,0FFH			; timer so the screen does not change too quickly
			LOOP $				;
            		JMP START			; reset the program
VALID       	ENDP


			END MAIN
