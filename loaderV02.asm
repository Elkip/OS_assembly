	org 0x2345

;;Load logo from 37th sector
	
	push cs
	pop ds
	push cs
	pop es

welcome:
	mov al, 30h		;ascii '0'
	mov dl, 0		;col 0
	mov ah, 13h		;Function 13h (display string)
	mov al,1		;Write mode is 0: cursor stays after last char
	mov bh, 0		;page=0
	mov bl, 07h		;Attribute white on black
	mov dh, 0		;row, 0..24
	mov cx, mlen  	;calculate message size. 

	lea bp,[elix]	;print welcome message

	int 10h

init1:
	mov al, 14		;ascii eighth note
	mov dl, 30		;col 0

topborder:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	mov dh, 12		;row, 0..24
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 08h		;dark grey on black
	mov cx, 1		;repetitions 
	int 10h

	inc dl			;col++
	cmp dl, 51		;when to stop; ah from 30h to 3ah, 10 chars
	jne topborder		;if al not reaches 3ah, do loop

init2:
	mov al, 14		;ascii eighth note
	mov dl, 30		;col 0
bottomborder:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	mov dh, 20		;row, 0..24
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 08h		;dark grey on black
	mov cx, 1		;repetitions 
	int 10h

	inc dl			;col++
	cmp dl, 51		;when to stop; ah from 30h to 3ah, 10 chars
	jne bottomborder		;if al not reaches 3ah, do loop


init3:
	mov al, 186		;ascii eighth note
	mov dh, 13		;row, 0

leftborder:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	mov dl, 30		;col, 0..79
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 08h		;dark grey on black
	mov cx, 1		;repetitions 
	int 10h

	inc dh			;row++
	cmp dh, 20		;when to stop 
	jne leftborder		;if al not reaches row 21, do loop

init4:
	mov al, 186		;ascii eighth note
	mov dh, 13		;row, 0

rightborder:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	mov dl, 50		;col, 0..79
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 08h		;dark grey on black
	mov cx, 1		;repetitions 
	int 10h

	inc dh			;row++
	cmp dh, 20		;when to stop
	jne rightborder		;if al not reaches row 21, do loop


init5:
	mov al, 179		;line? if not try 124 or 174
	mov dh, 14		;row, 0

Line1:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	mov dl, 36		;col, 0..79
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 03h		;cyan on black
	mov cx, 1		;repetitions 
	int 10h

	inc dh			;row++
	cmp dh, 18		;when to stop
	jne Line1		;if al not reaches row 21, do loop


init6:
	mov al, 179		;line? if not try 124 or 174
	mov dh, 14		;row, 0

Line2:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	mov dl, 44		;col, 0..79
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 03h		;cyan on black
	mov cx, 1		;repetitions 
	int 10h

	inc dh			;row++
	cmp dh, 18		;when to stop
	jne Line2		;if al not reaches row 21, do loop


init7:
	mov al, 92		;backslash
	mov dh, 14		;row, 0
	mov dl, 37		;col, 0..79

Diag1:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 03h		;cyan on black
	mov cx, 1		;repetitions 
	int 10h

	inc dh			;row++
	inc dl 			;col++
	inc dl
	cmp dh, 18		;when to stop
	jne Diag1	

init8:
	mov al, 47		;forward slash
	mov dh, 17		;row, 0
	mov dl, 37		;col, 0..79

Diag2:
	mov ah, 2		;set cursor location
	mov bh, 0		;page=0
	int 10h

	mov ah, 09h		;write a char and attribute
	mov bh, 0		;page=0		
	mov bl, 03h		;cyan on black
	mov cx, 1		;repetitions 
	int 10h

	dec dh			;row--
	inc dl 			;col++
	inc dl
	cmp dh, 13		;when to stop
	jne Diag2	

init9:
	mov al, 30h		;ascii '0'
	mov dl, 0		;col 0

logo:
	mov ah, 13h		;Function 13h (display string)
	mov al,1		;Write mode is 0: cursor stays after last char
	mov bh, 0		;page=0
	mov bl, 02h		;Attribute green on black
	mov dh, 19		;row, 0..24
	mov dl, 37
	mov cx, mlen1  	;calculate message size. 

	lea bp,[elux]	;print logo
	
	int 10h
	
continue:
	mov al, 30h		;ascii '0'
	mov dl, 0		;col 0
	mov ah, 13h		;Function 13h (display string)
	mov al,1		;Write mode is 0: cursor stays after last char
	mov bh, 0		;page=0
	mov bl, 07h		;Attribute white on black
	mov dh, 24		;row, 0..24
	mov cx, mlen2  	;calculate message size. 

	lea bp,[cont]	;print continue message

	int 10h
	jmp word 0x0000:0x7c41

elix	db "ELUX  OS V02",10,13,"COSC429 2019 EMU",10,13, "Mitchell Henschel Feb '19"
mlen equ $-elix

elux	db "E L U X"
mlen1 equ $-elux

cont	db "Press any key to continue..."
mlen2 equ $-cont