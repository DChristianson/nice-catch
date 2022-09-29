
; full screen picture demo by e5frog, original picture painted by Kurt_Woloch

	processor f8

;===========================================================================
; VES Header
;===========================================================================

	include	"ves.h"	

;===========================================================================
; Configuration
;===========================================================================

game_size		=	4			; game size in kilobytes

;===========================================================================
; Program Entry
;===========================================================================

;---------------------------------------------------------------------------
; Cartridge Initalization unsing macros from ves.h
;---------------------------------------------------------------------------

	org	$800

cartridge.init:
	; initalize the system
	CARTRIDGE_START
	CARTRIDGE_INIT

	
;---------------------------------------------------------------------------
; Main Program 
;---------------------------------------------------------------------------

main:

	
	; clear to B&W using a BIOS routine

	li	$21
	lr	3, A
	pi	clrscrn



	; now draw with the multiblit version, two bits per pixel

	dci	gfx.bitmap.bmp.parameters
	pi	multiblitGraphic


	; set palette 
	
	dci	gfx.palette.parameters
	pi	blitGraphic



	; wait for hand controller input

	pi	wait.4.controller.input


	jmp	0			; restart




wait.4.controller.input:
	; see if one of the hand controllers has moved
	clr
	outs	0
	outs	1						; check right hand controller
	ins	1
	com
	bnz	wait.4.controller.input.end
	; check the other controller
	clr
	outs	4						; check left hand controller
	ins	4
	com
	bnz	wait.4.controller.input.end
	br	wait.4.controller.input

wait.4.controller.input.end:

	pop
	

;---------------------------------------------------------------------------

	; gfx drawing routines

	include "drawing.inc"

	include "multiblit.inc"

	; graphics data

	include "picture-palette.inc"	
	; include "blue.inc"
	; include "red.inc"
	; include "green.inc"

	include "ves_graphic.data.txt"

;===========================================================================
; Signature 
;===========================================================================

	; signature
	org [$800 + [game_size * $400] -$10]

signature:

	.byte	"   e5frog 2007  "