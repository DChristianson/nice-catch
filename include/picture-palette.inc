	; palette

gfx.palette.parameters:
	.byte	$FF			; color 1 (ON)
	.byte	$00			; color 2 (OFF)
	.byte	121			; x position
	.byte	0			; y position
	.byte	2			; width
	.byte	58			; height
	.word	gfx.palette.data	; address for the graphics

gfx.palette.data:
		.byte	%10101010, %10101010, %10101010, %10101010, %10101010, %10101010, %10101010
		.byte	%10101010, %10101010, %10101010, %10101010, %10101010, %10101010, %10101010
		.byte	%10101010
