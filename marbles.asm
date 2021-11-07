
    processor 6502
    include "vcs.h"
    include "macro.h"

NTSC = 0
PAL60 = 1

    IFNCONST SYSTEM
SYSTEM = NTSC
    ENDIF

; ----------------------------------
; constants

BLOCK_HEIGHT = 4

#if SYSTEM = NTSC
; NTSC Colors
WHITE = $0F
GREY = $08
RED = $44
YELLOW = $1E
GREEN = $B2
BLUE = $82
BLACK = 0
#else
; PAL Colors
WHITE = $0E
GREY = $08
RED = $62
YELLOW = $2E
GREEN = $72
BLUE = $B2
BLACK = 0
#endif


; ----------------------------------
; variables

  SEG.U variables

    ORG $80

frame          ds 1
block_counter  ds 1
blocks         ds 40
player_color   ds 2
p1_color       ds 1

    SEG

; ----------------------------------
; code

  SEG
    ORG $F000

Reset

    ; do the clean start macro
            CLEAN_START            

    
            
newFrame

  ; Start of vertical blank processing
            
            lda #0
            sta VBLANK
            sta COLUBK              ; background colour to black

    ; 3 scanlines of vertical sync signal to follow

            ldx #%00000010
            stx VSYNC               ; turn ON VSYNC bit 1

            sta WSYNC               ; wait a scanline
            sta WSYNC               ; another
            sta WSYNC               ; another = 3 lines total

            sta VSYNC               ; turn OFF VSYNC bit 1

    ; 37 scanlines of vertical blank to follow

;--------------------
; VBlank start

            lda #1
            sta VBLANK

            lda #42    ; vblank timer will land us ~ on scanline 34
            sta TIM64T


            dec frame
            bpl setupBlocks_end
            lda #$0a
            sta frame

setupBlocks_start
            ldy #39
setupBlocks_loop
            ldx blocks,y
            inx
            cpx #41
            bmi setupBlocks_save
            ldx #$00
setupBlocks_save
            stx blocks,y
            dey
            bpl setupBlocks_loop
setupBlocks_end

            ldx #0
waitOnVBlank            
            cpx INTIM
            bmi waitOnVBlank

            stx VBLANK

;--------------------
; Screen start


            sta WSYNC
            
            lda #$00
            sta PF0
            sta PF1
            sta PF2
            sta COLUBK
            sta RESP0
            sta RESM0

            lda #BLUE
            sta player_color
            lda #RED
            sta player_color + 1
            sta RESP1
            sta RESM1

            jsr playfield

            sta WSYNC
            
            lda #$00
            sta PF0
            sta PF1
            sta PF2
            sta COLUBK
            sta RESP0
            sta RESM0

            lda #GREEN
            sta player_color
            lda #YELLOW
            sta player_color + 1
            sta RESP1
            sta RESM1
            jsr playfield

            sta WSYNC
            lda #$00
            sta PF0
            sta PF1
            sta PF2
            sta COLUBK
            jmp overscan

playfield
            lda player_color
            sta COLUPF

            ldx #20
playfield_next
            dex                ;2  --/60
            bmi playfield_end  ;2  --/62
            ldy blocks,x       ;4  --/66
            lda #BLOCK_HEIGHT  ;2  --/68
            sta block_counter  ;3  --/71c

playfield_loop:
            sta WSYNC          ;3   0
            lda player_color+1 ;3   3
            sta COLUBK         ;3   6
            
            lda BLOCK_PF0,y    ;4  10
            sta PF0            ;3  13
            lda BLOCK_PF1,y    ;4  17
            sta PF1            ;3  20
            lda BLOCK_PF2,y    ;4  24
            sta PF2            ;3  27
            lda BLOCK_PF3,y    ;4  31
            sta PF0            ;3  34
            lda BLOCK_PF4,y    ;4  38
            sta PF1            ;3  41
            lda BLOCK_PF5,y    ;4  45
            sta PF2            ;3  48

            dec block_counter  ;5  53
            bmi playfield_next ;2  55
            jmp playfield_loop ;3  58            
playfield_end
            rts
            

;--------------------
; Overscan start
overscan
            ldx #30
waitOnOverscan
            sta WSYNC
            dex
            bne waitOnOverscan

            jmp newFrame

;--------------------
; Graphics

    ORG $FE00

BLOCK_PF0 byte $00,$10,$30,$70,$F0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
BLOCK_PF1 byte $00,$00,$00,$00,$00,$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
BLOCK_PF2 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$03,$07,$0F,$1F,$3F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

    ORG $FF00

BLOCK_PF3 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$30,$70,$F0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF                   
BLOCK_PF4 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
BLOCK_PF5 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$03,$07,$0F,$1F,$3F,$7F,$FF,$FF

;--------------------
; Reset

    ORG $FFFA

    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ

    END