;================;
; Multiblit Code ;
;================;
;
; green: %00 (Port color code %00000000 / $00)
; red  : %01 (Port color code %01000000 / $40)
; blue : %10 (Port color code %10000000 / $80)
; background: %11.  (Port color code %11000000 / $C0)
;
;-------------------;
; MultiBlitGfx ;
;-------------------;

; takes graphic parameters from ROM, stores them in r1-r4, changes
; the DC and calls the multiblit function with the parameters
;
; modifies: r1-r4, Q, DC

multiblitGraphic:
	; set ISAR
	lisu	0
	lisl	1
	; load four bytes from the parameters into r1-r4
	lm   
	lr	I, A						; store byte and increase ISAR
	lm   
	lr	I, A
	lm   
	lr	I, A
	lm   
	lr	S, A

	; load the graphics address
	lm
	lr	Qu, A						; into Q
	lm
	lr	Ql, A
	lr	DC, Q						; load it into the DC

	; call the blit function
;	jmp	multiblit					; Not needed, it's the next piece of code

;--------------------;
; Multiblit Function ;
;--------------------;
;
; Adjusted so that (0,0) is the top left pixel in the MESS display.
; If you want to skip this adjustment, saving 6 cycles, use 
; "multiblit_no" for real origo - and not (4,4).
;
; This function blits a 4-color graphic based on parameters set
; in r1-r4 and the graphic data pointed to by DC0, onto the
; screen
; Origin from cart 26, modified for color and annotated
;
; modifies: r0-r7, DC

; register reference:
; -------------------
; r0 = quick adder
; r1 = x position
; r2 = y position
; r3 = width
; r4 = height (and vertical counter)
;
; r5 = horizontal counter
; r6 = graphics byte
; r7 = pixel counter
;
; DC = pointer to graphics

multiblit:
	; fix the x coordinate
	lis	4
	as	1
	lr	1, A
	; fix the y coordinate
	lis	4
	as	2
	lr	2, A
multiblit_no:
	clr
	com
	lr	0, A							; $FF, for adding 1

	lis	1
	lr	7, A							; load #1 into r7 so it'll be reset when we start
	lr	A, 2							; load the y offset
	com								; invert it
.multiblitRow:
	outs	5							; load accumulator into port 5 (row)

	; check vertical counter
	ds	4							; decrease r4 (vertical counter)
	bnc	.multiblitExit					; if it rolls over exit

	; load the width into the horizontal counter
	lr	A, 3
	lr	5, A

	lr	A, 1							; load the x position
	com								; complement it
.multiblitColumn:
	outs	4							; use the accumulator as our initial column
	; check to see if this byte is finished
	ds	7							; decrease r7 (pixel counter)
	bnz	.multiblitDrawPixel				; if we aren't done with this byte, branch

.multiblitGetByte:
	; get the next graphics byte and set related registers
	lis	4
	lr	7, A							; load 4 into r7 (4 doublebit, pixel counter)
	lm
	lr	6, A							; load a graphics byte into r6

.multiblitDrawPixel:
	; get new color
	lr	A, 6
	ni	%11000000						; Just keep top two
	outs	1							; output A in p1 (color)

.multiblitTransferData:
	; transfer the pixel data
	lis	6
	sl	4
	outs	0
	sl	1
	outs	0


	; GFX DELAY

	; shift graphics byte
	lr	A, 6							; load r6 (graphics byte)
	sl	1
	sl	1							; shift left two, move up to b7, b6
	lr	6, A							; save it

	lis	1							; Same delay as in blit
.multiblitSavePixelDelay:
	ai	$ff
	bnz	.multiblitSavePixelDelay			; loop if not 0 (small delay)



.multiblitCheckColumn:
	ds	5							; decrease r5 (horizontal counter)
	bz	.multiblitCheckRow				; if it's 0, branch

	ins	4							; get p4 (column)
	as	0							; add 1 (complemented)
	br	.multiblitColumn					; branch

.multiblitCheckRow:
	ins	5							; get p5 (row)
	as	0							; add 1 (complemented)
	br	.multiblitRow					; branch

.multiblitExit:
	; return from the subroutine
	pop