; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)
extern printf
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1
%define MaxPoints	5

global main

section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

;pas dans le code de base
temp:		resq	1

tableX:		resw	MaxPoints
tableY:		resw	MaxPoints

startingPoint: 	resw	1
startingNumber:	resb	1
P:	resb	1
Q:	resb	1

valueClock1:	resd	1
valueClock2:	resd	1
valueClock3:	resd	1
valueClock4:	resd	1

multClock1:	resd	1
multClock2:	resd	1
finalResult: resd   1

section .data

event:		times	24 dq 0

x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0

;pas dans le code de base
test2: 	db 	"Le resultat: %d ", 10, 0
test3: db	"Result: %d", 10, 0
test4: db	"P = %ld", 10, 0
test5: db	"Q = %ld", 10, 0
test6: db	"counterTable = %d", 10, 0

ok: db "ok", 10, 0
pos: db "positive", 10, 0
neg: db "negative", 10, 0

testPos: db	"Result Pos: %ld", 10, 0
testCol: db	"Result Col: %ld", 10, 0
testNeg: db	"Result Neg: %ld", 10, 0

testClock1: db 	"valueClock1: %lld", 10, 0
testClock2: db 	"valueClock2: %lld", 10, 0
testClock3: db 	"valueClock3: %lld", 10, 0
testClock4: db 	"valueClock4: %lld", 10, 0

testClockMult1: db "multClock1: %d", 10, 0
testClockMult2: db "multClock2: %d", 10, 0

second: db 	0
counterPoints: 	db 	0
lmao:	db 	"t[%d]=%d", 10, 0
counterTable:	db	0

testValue1:	dw	2
testValue2:	dw	2

countValue: dw  0

section .text

;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0x000000	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0xFFFFFF	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin				; on saute au label 'dessin'
cmp dword[event],KeyPress		; Si on appuie sur une touche
je closeDisplay				; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#	DEBUT DE LA ZONE DE DESSIN	 #
;#########################################


;########################################
;#   Partie ou Simon fait de la merde   #
;########################################

startProg:

push rbp

placePoints:

call generate

;mov rdi, test2
;movzx rsi, word[x1]
;mov rax, 0
;call printf

cmp byte[counterPoints],  0
je afterStartProg
jmp dessin
comebackPoints:

inc byte[counterPoints]
cmp byte[counterPoints], MaxPoints
jb placePoints

call vector
call searchTriangle

;exemple pour la multi
;mov ax, word[testValue1]
;mul word[testValue2]
;mov rdi, test2
;movzx rsi, ax
;mov rax, 0
;call printf

;##############################################
;# Fin de la partie ou Simon fait de la merde #
;##############################################

dessin:
;couleur du point 1
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0xFF0000	; Couleur du crayon ; rouge
call XSetForeground

cmp byte[counterPoints], 0
je startProg

afterStartProg:

; Dessin d'un point rouge sous forme d'un petit rond : coordonnées (100,200)
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov rcx,qword[x1]		; coordonnée en x du point
sub ecx,3
mov r8,qword[y1] 		; coordonnée en y du point
sub r8,3
mov r9,6
mov rax,23040
push rax
push 0
push r9
call XFillArc

cmp byte[counterPoints], MaxPoints
jb comebackPoints

drawLines:

;couleur de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0xFFFFFF	; Couleur du crayon ; blanc
call XSetForeground

;mov dword[x1], 50
;mov dword[y1], 50
;mov dword[x2], 200
;mov dword[y2], 200

; dessin de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x1]	; coordonnée source en x
mov r8d,dword[y1]	; coordonnée source en y
mov r9d,dword[x2]	; coordonnée destination en x
push qword[y2]		; coordonnée destination en y
call XDrawLine


mov al, byte[P]
cmp byte[startingNumber], al

jne returnFromDrawLine

; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit

;#############################
;#	Les Fonctions        #
;#############################
global generate
generate:

	tooHigh:
	rdrand rax

	cmp ax, 350
	ja tooHigh
	cmp ax, 50
	jb tooHigh
    	mov word[x1],ax

	;Rangement dans le tableau
	movzx ecx, byte[counterPoints]
	mov [tableX + ecx * WORD], ax

	;code pour voir le tableau
	;mov rdi, lmao
	;movzx rsi, byte[counterPoints]
	;movzx rdx, word[tableX + ecx*WORD]
	;mov rax, 0
	;call printf

	tooHigh2:
	rdrand rax

   	cmp ax, 350
	ja tooHigh2
    	cmp ax, 50
    	jb tooHigh2
    	mov word[y1],ax

	;Rangement dans le tableau
	movzx ecx, byte[counterPoints]
	mov [tableY + ecx * WORD], ax

	;code pour voir le tableau
	;mov rdi, lmao
	;movzx rsi, byte[counterPoints]
	;movzx rdx, word[tableY + ecx*WORD]
	;mov rax, 0
	;call printf
ret

global vector

vector:
	movzx ecx, byte[counterTable]
	mov ax, [tableX+ecx*WORD]

	cmp byte[counterTable], 0
	je storeX

	cmp ax, word[startingPoint]
	jb storeX

continueVector:
	inc byte[counterTable]
	cmp byte[counterTable], MaxPoints
	jb vector
	jmp showStarting

storeX:
	movzx ecx, byte[counterTable]
	mov word[startingPoint], ax
	mov al, byte[counterTable]
	mov byte[startingNumber], al
	jmp continueVector

showStarting:
	;mov rdi, lmao
	;movzx rsi, byte[startingNumber]
	;movzx rdx, word[startingPoint]
	;mov rax, 0
	;call printf
ret

global searchTriangle

searchTriangle:
	mov al, byte[startingNumber]
	mov byte[P], al

	returnFromDrawLine:

	cmp byte[P], 0
	je isEqualTo0

	mov byte[Q], 0
	jmp searchClockwise

	isEqualTo0:
	mov byte[Q], 1

	searchClockwise:

		mov byte[counterTable], 0

		loop:
		call clockwise
		cmp al, 1

		je skip

		mov al, byte[counterTable]
		mov byte[Q], al

		skip:

		inc byte[counterTable]

		cmp byte[counterTable], MaxPoints
		jb loop

		movzx ecx, byte[P]
		mov ax, [tableX+ecx*WORD]
		movzx ebx, ax
		mov dword[x1], ebx
		mov ax, [tableY+ecx*WORD]
		movzx ebx, ax
		mov dword[y1], ebx

		movzx ecx, byte[Q]
		mov ax, [tableX+ecx*WORD]
		movzx ebx, ax
		mov dword[x2], ebx
		mov ax, [tableY+ecx*WORD]
		movzx ebx, ax
		mov dword[y2], ebx

		mov al, byte[Q]
		mov byte[P], al

		jmp drawLines
ret

; ca fonctionne pas par pitie TOUCHE a ca
global clockwise

clockwise:
    movzx ecx, byte[counterTable]   ;coordonnee x de I
    mov eax, 0
    mov ax, [tableX+ecx*WORD]

    movzx ecx, byte[P]              ;coordonnee x de P
    mov bx, [tableX+ecx*WORD]

    sub ax, bx                      ;xI - xP

    cmp ax, 0
    jge positive1

    not ax
    inc ax
    neg eax

    positive1:

    mov dword[valueClock1], eax       ;xPI
    mov rdi, testClock1
    movsx rsi, dword[valueClock1]
    mov rax, 0

;########################################################

    movzx ecx, byte[counterTable]   ;coordonnee y de I
    mov eax, 0
    mov ax, [tableY+ecx*WORD]

    movzx ecx, byte[P]              ;coordonne y de P
    mov bx, [tableY+ecx*WORD]

    sub ax, bx

    cmp ax, 0
    jge positive2

    not ax
    inc ax
    neg eax

    positive2:

    mov dword[valueClock2], eax     ;yPI
    mov rdi, testClock2
    movsx rsi, dword[valueClock2]
    mov rax, 0

;########################################################

    movzx ecx, byte[counterTable]   ;coordonnee x de I
    mov eax, 0
    mov ax, [tableX+ecx*WORD]

    movzx ecx, byte[Q]              ;coordonnee x de Q
    mov bx, [tableX+ecx*WORD]

    sub ax, bx

    cmp ax, 0
    jge positive3

    not ax
    inc ax
    neg eax

    positive3:

    mov dword[valueClock3], eax      ;xQI
    mov rdi, testClock3
    movsx rsi, dword[valueClock3]
    mov rax, 0

;########################################################

    movzx ecx, byte[counterTable]   ;coordonnee x de I
    mov eax, 0
    mov ax, [tableY+ecx*WORD]

    movzx ecx, byte[Q]              ;coordonnee x de Q
    mov bx, [tableY+ecx*WORD]

    sub ax, bx

    cmp ax, 0
    jge positive4

    not ax
    inc ax
    neg eax

    positive4:

    mov dword[valueClock4], eax      ;yQI
    mov rdi, testClock4
    movsx rsi, dword[valueClock4]
    mov rax, 0

;########################################################

    mov rax, 0

    mov eax, dword[valueClock3]
    mul dword[valueClock2]    ;xIQ * yPI

    mov dword[multClock1], eax

    cmp dword[multClock1], 0
    jge positive5

    not dword[multClock1]
    inc dword[multClock1]
    neg dword[multClock1]

    positive5:

    mov eax, dword[valueClock1]
    mul dword[valueClock4]    ;xPI * yIQ

    mov dword[multClock2], eax

    cmp dword[multClock2], 0
    jge positive6

    not dword[multClock2]
    inc dword[multClock2]
    neg dword[multClock2]

    positive6:

    mov rdi, testClockMult1
    movsx rsi, dword[multClock1]
    mov rax, 0

    mov rdi, testClockMult2
    movsx rsi, dword[multClock2]
    mov rax, 0

;#######################################################

    mov eax, dword[multClock1]
    sub eax, dword[multClock2]    ;calcul total
    mov dword[finalResult], eax

    cmp dword[finalResult], 0
    jg positive
    jmp notPositive

    positive:
	    mov rdi, pos
	    mov rax, 0

        mov al, 0
        jmp end

    notPositive:
	    mov rdi, neg
	    mov rax, 0

        mov al, 1

    end:
ret
