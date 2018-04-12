ORG 100h

PUTC    MACRO   char
        PUSH    AX                    ; this macro is copied from emu8086.inc ;
        MOV     AL , char             ; this macro prints a char in AL and advances the current cursor position:
        MOV     AH , 0Eh
        INT     10h     
        POP     AX
ENDM
                        
JMP START                             ; jump to start label
msg1 db "please enter the number of elemants in the array to be stored or press 0 to terminate: $" , 0Dh,0Ah, 24h ; define variable (message):
num1 dw ? 
num2 dw ?
start:  LEA DX , msg1                 ; load effective address of msg into dx.
        MOV AH , 09h                  ; print function is 9.
        INT 21h                       ; do it 
                       
CALL SCAN_NUM                         ; get the multi-digit signed number from the keyboard, and store the result in cx register:
mov num1 ,  cx          
mov num2 , cx
putc 0Dh                              ; new line:
putc 0Ah        

CMP CX , 1                            ; compare cx with one
JLE lessthan                          ; if cx is less than 1 jump to lessthan label
    
greater_or_equal:                     ; if cx isn't less than 1
    CMP CX , 25                       ; compare cx with 25
    JLE lessthan_or_equal             ; if cx less than 25 jump to less_or_equal
    
    greater__or__equal:               ; if cx more than 25
        JMP restart                   ; jump to restart label
        msg2 db "please enter suitabal number in range of [1,25] $" , 0Dh,0Ah, 24h  ; define variable (message):
        
    
        restart:  LEA DX , msg2       ; load effective address of msg into dx.
                  MOV AH , 09h        ; print function is 9.
                  INT 21h             ; do it
                
                  MOV AH, 0 
                  INT 16h             ; wait for any key any....  
                  putc 0Dh            ; new line:
                  putc 0Ah           
                  JMP start           ; jump to start label
                                   
lessthan:                             ; less than label 
    CMP CX , 1                        ; compare cx with one
    JE  lessthan_or_equal             ; lessthan_or_equal label
    CMP CX , 0                        ; compare cx with 0
    JNZ restart2                      ; if cx not equal 0 jump to restart2 
    stop:                             ; stop label
    MOV AH , 4CH
    MOV AL , 01                       ; your return code.
    INT 21H                           ; do it
                               
    restart2:
               
               LEA DX , msg2          ; load effective address of msg into dx.
               MOV AH , 09h           ; print function is 9.
               INT 21h                ; do it
               
               MOV AH , 0 
               INT 16h                ; wait for any key any....
               putc 0Dh               ; new line:
               putc 0Ah
               JMP start              ; jump to start label
                             
    lessthan_or_equal:                ; lessthan_or_equal label  
            arr dw 50 dup(0)          ; define an array of words of 50 memory location
            mov si , 0                ; mov value 0 to si         
            jmp get_values            ; jump to get_value label
            msg3 db "please enter the elemant of the array to be stored $" , 0Dh,0Ah, 24h      ; define variable (message):
            get_values:
                    LEA DX , msg3     ; load effective address of msg into dx.
                    MOV AH , 09h      ; print function is 9.
                    INT 21h           ; do it                       
                    Call scan_num     ; call procedure scan_num
                    mov arr[si] , cx  ; mov value of cx to index of array
                    add si , 2        ; add 2 to si
                    mov cx , num1     ; mov num1 (number of elemants) to cx
                    sub num1 , 1      ; sub 1 from num1
                    putc 0Dh          ; new line:
                    putc 0Ah    
            loop get_values           ; loop the label get_values number of loops equal to the value of cx

sorting:             
            lea si , arr              ; make si point to first of arr |
            mov ax,si                 ; move si to ax
            mov cx , num2             ; mov num2 (number of elemant in the array) in cx
            cmp cx , 1                ; compare cx with 1
            je printing               ; jump to label printing if cx equal 1
            sub cx , 1                ; sub 1 from cx
            loop1:
                mov dx , cx           ; mov cx to bx 
                mov si , ax           ; mov ax to si pointer
                mov di , ax           ; mov ax to di pointer
                add di , 2            ; add 2 to di poiter to points second elemant
            loop2:       
                mov bx , [si]         ; move value that si point to dx
                cmp bx , [di]         ; compare dx with values that di points
                jna next              ; if dx is not greater than value jump to labe next
                xchg bx , [di]        ; exchange dx with value that di points
                mov [si] , bx         ; mov value of dx to pointer si
            next:
                add si , 2            ; add 2 to si poinet
                add di , 2            ; add 2 to di pointer
                sub dx , 1            ; sub 1 ffrom bx
                cmp dx , 0            ; compare dx with 0
                jnz loop2             ; if bx not equal zero jump to loop2
            loop loop1                ; loop the label loop1 
    
jmp print                             ; jump to print label
msg4 db "The sorted array is: $" , 0Dh,0Ah, 24h      ; define variable (message):                          
print:            
           LEA DX , msg4              ; load effective address of msg into dx.
           MOV AH , 09h               ; print function is 9.
           INT 21h                    ; do it
           mov si , 0                 ; move 0 to si 
           mov cx , num2              ; sub 1 from cx           
           print_loop:
              mov ax , arr[si]        ; move the index of array to ax
              call print_num_uns      ; call procedure
              add si , 2              ; add 2 to pointer si
           loop print_loop            ; loop the label print_loop
           putc 0Dh                   ; new line:
           putc 0Ah                     
           JMP start                  ; jump to start label
printing:
          LEA DX , msg4               ; load effective address of msg into dx.
          MOV AH , 09h                ; print function is 9.
          INT 21h                     ; do it
          mov si , 0                  ; move 0 to si
          mov ax , arr[si]            ; move index of array to ax
          call print_num_uns          ; call procedure       
          putc 0Dh                    ; new line:
          putc 0Ah    
          JMP start                   ; jump to start label
              
; these functions are copied from emu8086.inc                                                            
; gets the multi-digit SIGNED number from the keyboard and stores the result in CX register:                                  
SCAN_NUM        PROC    NEAR
        PUSH    DX         
        PUSH    AX         
        PUSH    SI        
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:

        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:

        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8          ; backspace.
        PUTC    ' '        ; clear last entered not digit.
        PUTC    8          ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten     ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big (result should be 16 bits) 
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX     ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2   ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX     ; restore the backuped value before add.
        MOV     DX, 0      ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten     ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8          ; backspace.
        PUTC    ' '        ; clear last entered digit.
        PUTC    8          ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP
    
; this procedure prints out an unsigned number in AX (not just a single digit) allowed values are from 0 to 65535 (FFFF) 
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        PUTC    ','
        RET
PRINT_NUM_UNS   ENDP  

ten DW 10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS. 