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
%define MaxPoints	10

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

section .data

event:		times	24 dq 0

x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0

;pas dans le code de base
test2: 	db 	"Le resultat: %d ", 10, 0
second: db 0
counterPoints: db 0

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

mov rdi, test2
movzx rsi, word[x1]
mov rax, 0
call printf

cmp byte[counterPoints],  0
je comeback
jmp dessin
comeback:

inc byte[counterPoints]
cmp byte[counterPoints], MaxPoints
jb placePoints

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
jb comeback

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

global generate
generate:
    tooHigh:
    rdrand rax

    cmp ax, 350
    ja tooHigh
    cmp ax, 50
    jb tooHigh
    mov word[x1],ax

    tooHigh2:
    rdrand rax

    cmp ax, 350
    ja tooHigh2
    cmp ax, 50
    jb tooHigh2
    mov word[y1],ax
ret
