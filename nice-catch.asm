;  Nice Catch!
;  A game for one to two players
;   - cruise around the bay and try to catch fish
;   - when you have a fish onboard bring it back to your home dock
;   - catch a fish of each type and a clue will appear on one of the islands
;   - dig at the marked island to get a treasure
;   - bring the treasure home to win
;      
; obstacles
;   - cyclone will spin your ship around and you lose your catch
;   - touching the turtle brings bad luck 
;   - once you enter the treasure hunt phase the cyclone is replaced by a skull
;
;
; secret
;   - if you fish near the turtle you have an increased chance of catching a fish 
;   - if you bring the treasure to the opposing dock while the other player is there 
;      you win with a friendship
;   - if both players catch all the fish a second clue will appear to mark the ghost island
;     if both players go to the unmarked island with the treasure they win by lifting the curse
;
;  credit to VES homebrew community and example code from
;   e5frog
;   Kurt_Woloch

;
; 1 game phase
; 12 - 2 players (x, y, dx, dy, fuel, effect timer) 
;  state
;    tfffssss
;     spinning
;     sinking
;     driving
;     docked
;
; 5 turtle (x, y, dx, dy, animation)
; 5 enemy (x, y, dx, dy, animation)
; 2 clue (x, y)
;
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


	; set palette 
	
	dci	gfx.title.bmp.palette.parameters
	pi	blitGraphic


	; now draw title screen

	dci	gfx.title.bmp.parameters
	pi	multiblitGraphic

    ; wait for hand controller input

	pi	wait.4.controller.input

	; now draw game screen

    dci	gfx.game.bmp.palette.parameters
	pi	blitGraphic

	dci	gfx.game.bmp.parameters
	pi	multiblitGraphic

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

	include "title_data.inc"
	include "game_data.inc"

;===========================================================================
; Signature 
;===========================================================================

	; signature
	org [$800 + [game_size * $400] -$10]

signature:

	.byte	"   e5frog 2007  "