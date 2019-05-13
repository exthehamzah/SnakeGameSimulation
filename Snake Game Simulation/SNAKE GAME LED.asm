ORG	0H
HORZ	EQU	P1	; Baris LED untuk horizontal
VERT	EQU	P2	; Kolom LED untuk vertikal
UP	BIT	P3.3	; switch untuk ke atas
DOWN	BIT	P3.2	; switch untuk ke bawah
LEFT	BIT	P3.1	; switch untuk ke kiri
RIGHT	BIT	P3.0	; switch untuk ke kanan
DUP	BIT	P0.3	; nilai dummy untuk kondisi ke atas
DDOWN	BIT	P0.2	; nilai dummy untuk kondisi ke bawah
DLEFT	BIT	P0.1	; nilai dummy untuk kondisi ke kiri
DRIGHT	BIT	P0.0	; nilai dummy untuk kondisi ke kanan
MOV	P0, #0FFH	; reset nilai dummy
MOV	HORZ, #0FH	; reset LED horizontal
MOV	VERT, #07FH	; reset LED vertikal
JMP 	MAIN		; JUMP ke program utama

ORG	120H
DATAH:	DB	0H, 0FH, 087H, 0C3H, 0E1H, 0F0H, 078H, 03CH, 01EH, 0FH, 087H, 0C3H	; bentuk ular dalam 4 LED
ORG	150H
DATAV:	DB	0H, 0EFH, 0F7H, 0FBH, 0FDH, 0FEH, 07FH, 0BFH, 0DFH, 0EFH, 0F7H, 0FBH	; bentuk ular dalam 1 LED

MAIN:	ACALL	DELAY		; delay agar dapat mengatur switch arah
	; membaca switch arah
	JNB	UP, UPV
	JNB	DOWN, DOV
	JNB	LEFT, LEV
	JNB	RIGHT, RIV
	JMP	DRCT

;reset kembali nilai dummy (karena tidak pasti FFH)
UPV:
MOV	P0, #0FFH
CLR	DUP
JMP	VERTM
DOV:
MOV	P0, #0FFH
CLR	DDOWN
JMP	VERTM
LEV:
MOV	P0, #0FFH
CLR	DLEFT
JMP	HORZM
RIV:
MOV	P0, #0FFH
CLR	DRIGHT
JMP	HORZM

; menentukan arah
DRCT:
JNB	DUP, MOVU
JNB	DDOWN, MOVD
JNB	DLEFT, MOVL
JNB	DRIGHT, MOVR

; proses ular bergerak
MOVU:	MOV	A, VERT
	RL	A
	MOV	VERT, A
	MOV	A, P3
	CJNE 	A, #0F7H, MAIN	; akan terus ke arah sama jika switch tidak berubah
	JMP	MOVU
MOVD:	MOV	A, VERT
	RR	A
	MOV	VERT, A
	MOV	A, P3
	CJNE 	A, #0FBH, MAIN	; akan terus ke arah sama jika switch tidak berubah
	JMP 	MOVD
MOVL:	MOV	A, HORZ
	RL	A
	MOV	HORZ, A
	MOV	A, P3
	CJNE 	A, #0FDH, MAIN	; akan terus ke arah sama jika switch tidak berubah
	JMP 	MOVL
MOVR:	MOV	A, HORZ
	RR	A
	MOV	HORZ, A
	MOV	A, P3
	CJNE 	A, #0FEH, MAIN	; akan terus ke arah sama jika switch tidak berubah
	JMP 	MOVR

; fungsi delay waktu dengan Timer 0 (0,05 ms)
DELAY:	MOV	TMOD, #01H
	MOV	TH0, #0FFH
	MOV	TL0, #0D2H
	CLR	TF0
	SETB	TR0
CDTMR:	JNB 	TF0, CDTMR
	CLR	TR0
	CLR	TF0
	RET

; pengecekan kondisi untuk mengubah gerak ular jika akan ke arah atas/bawah
VERTM:
MOV	R2, HORZ
MOV 	R3, #08H
CMPV:
MOV 	DPTR, #DATAH
MOV	A, R3
MOVC	A, @A+DPTR
SUBB	A, R2
JZ	VERTN
DJNZ	R3, CMPV
JMP	DRCT

VERTN:
MOV	R2, VERT
MOV	R1, #08H
CMPY:
MOV	DPTR, #DATAV
MOV	A, R1
MOVC	A, @A+DPTR
SUBB	A, R2
JZ	MOVVR
DJNZ	R1, CMPY

; pengaturan agar ular ke posisi vertikal (ke arah atas/bawah)
MOVVR:
MOV	A, R3
MOVC	A, @A+DPTR
MOV	HORZ, A
MOV	DPTR, #DATAH
MOV	A, R1
JNB	DDOWN, SDOWN
JMP	MAKEV
SDOWN:
ADD	A, #03H
MAKEV:
MOVC	A, @A+DPTR
MOV	VERT, A
JMP	DRCT

; pengecekan kondisi untuk mengubah gerak ular jika akan ke arah atas/bawah
HORZM:
MOV	R2, VERT
MOV 	R1, #08H
CMPH:
MOV 	DPTR, #DATAH
MOV	A, R1
MOVC	A, @A+DPTR
SUBB	A, R2
JZ	HORZN
DJNZ	R1, CMPH
JMP	DRCT

HORZN:
MOV	R2, HORZ
MOV	R3, #08H
CMPX:
MOV	DPTR, #DATAV
MOV	A, R3
MOVC	A, @A+DPTR
SUBB	A, R2
JZ	MOVHR
DJNZ	R3, CMPX

; pengaturan agar ular ke posisi horizontal (ke arah kiri/kanan)
MOVHR:
MOV	DPTR, #DATAH
MOV	A, R3
JNB	DRIGHT, SRIGHT
JMP	MAKEH
SRIGHT:
ADD	A, #03H
MAKEH:
MOVC	A, @A+DPTR
MOV	HORZ, A
MOV	A, R1
MOV	DPTR, #DATAV
MOVC	A, @A+DPTR
MOV	VERT, A
JMP	DRCT

END