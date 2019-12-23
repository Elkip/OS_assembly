; ELUX OS V02
; Mitchell Henschel
; Febuary 5th, 2019
; COSC429 EMU
; Assemble with:
; nasm -f bin -o ELUX.bin ELUX.asm

	;bit16					; 16bit by default
	org 0x7c00
	jmp short start
	nop
bsOEM	db "OS423 v.0.2"               ; OEM String
start:

cls:
	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,08h		;Attribute White on black 
	mov ch,0		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,24		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
		

		;Colors from 0: Black Blue Green Cyan Red Magenta Brown White
		;Colors from 8: Gray LBlue LGreen LCyan LRed LMagenta Yellow BWhite

;;enable intensive Colors
	mov ax, 1003h
	mov bx, 0
	int 10h 

logo:
	;;;load 37th sector and run welcome sceren
	mov bx, 0x0001			;es:bx input buffer, temporary set 0x0001:2345
	mov es, bx
	mov bx, 0x2345
	mov ah, 02h				;Function 02h (read sector)
	mov al, 1				;Read one sector
	mov ch, 1				;Cylinder#
	mov cl, 2				;Sector# --> 2 has program
	mov dh, 0				;Head# --> logical sector 1
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	jmp word 0x0001:0x2345	;Run program on sector 37, ex:bx
	
date:
	;;;load 38th sector and run date/time display
	mov bx, 0x0002			;es:bx input buffer, temporary set 0x0001:2345
	mov es, bx
	mov bx, 0x3456
	mov ah, 02h				;Function 02h (read sector)
	mov al, 1				;Read one sector
	mov ch, 1				;Cylinder#
	mov cl, 3				;Sector# --> 3 has program
	mov dh, 0				;Head# --> logical sector 1
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	jmp word 0x0002:0x3456	;Run program on sector 38, ex:bx

input:
	mov ah,01h 
	int 16h		;get user input
	jz input 	;if no input repeat loop

clear_screen:
  	push cs
  	pop ds
  	push cs
  	pop es
  	
	mov ah,06h		;Function 06h (scroll screen)
	mov al,0		;Scroll all lines
	mov bh,0Ah		;Attribute green on black 
	mov ch,0		;Upper left row is zero
	mov cl,0		;Upper left column is zero
	mov dh,24		;Lower left row is 24
	mov dl,79		;Lower left column is 79
	int 10h			;BIOS Interrupt 10h (video services)
	
message:
	;;;load 39th sector and run welcome message
	mov bx, 0x0000			;es:bx input buffer, temporary set 0x0001:2345
	mov es, bx
	mov bx, 0x2345
	mov ah, 02h				;Function 02h (read sector)
	mov al, 1				;Read one sector
	mov ch, 1				;Cylinder#
	mov cl, 4				;Sector# --> 4 has program
	mov dh, 0				;Head# --> logical sector 1
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	mov ah, 13h		;Function 13h (display string)
	mov al, 1		;Write mode is 0: cursor stays after last char
	mov bh, 0		;page=0
	mov bl, 0Ah		;Attribute green on black
	mov dh, 0		;row, 0..24
	mov dl, 0		;column 0
	mov bp,0x2345	;load offset address of string into bp
	int 10h
	mov dh,5
	mov cx, mlen3  	;calculate message size. 
	lea bp,[line]	;print message
	int 10h
	int 20h

line	db " eluxV02 $"
mlen3 equ $-line

padding	times 510-($-$$) db 0		;to make MBR 512 bytes
bootSig	db 0x55, 0xaa		;signature (optional)

