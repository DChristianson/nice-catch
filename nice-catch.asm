; https://www.ibiblio.org/mutopia/ftp/SchubertF/D881B/SchubertF-D881B-Fischerweise/SchubertF-D881B-Fischerweise-let.pdf
;    a  220.0000
;    b  246.9417
; do c  261.6256
;    c# 277.1826
; re d  293.6648
;    d# 311.1270
; me e  329.6276
; fa f  349.2282
;    f# 369.9944
; so g  391.9954
; la a  440.0000
; ti b  493.8833
; do c  523.2511
;    c# 554.3653
; re d  587.3295
; mi e  659.2551
;
; 220.0, 246.9417, 261.6256, 277.1826, 293.6648, 311.1270, 329.6276, 349.2282, 369.9944, 391.9954, 440.0000, 493.8833, 523.2511, 554.3653, 587.3295, 659.2551
; [31, 28, 26, 25, 23, 22, 21, 20, 18, 17, 15, 14, 13, 12, 11, 10]

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

#if SYSTEM = NTSC
; NTSC Colors
WHITE = $0f
BLACK = 0
#else
; PAL Colors
WHITE = $0E
BLACK = 0
#endif

NUM_PLAYERS     = 4
HORIZON_HEIGHT  = 30
POOL_HEIGHT     = 160

; ----------------------------------
; variables

  SEG.U variables

    ORG $80

frame        ds 4    
paddle       ds 4
position     ds 4
target_rise  ds 4
target_run   ds 4
line_run     ds 4
line_steps   ds 4   
line_rise    ds 4   


    SEG

; ----------------------------------
; code

  SEG
    ORG $F000

Reset

    ; do the clean start macro
            CLEAN_START

newFrame

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

            lda #%10000010
            sta VBLANK

            lda #42    ; vblank timer will land us ~ on scanline 34
            sta TIM64T

            inc frame ; new frame

            ldx #NUM_PLAYERS - 1
player_update
            lda position,x
            ; clc 
            ; adc #$01
            ; sta position,x
            ; bpl target_load
            ; and #$7f
target_load
            tay
            lda RAD_2_HPOS,y
            sta target_run,x
            lda RAD_2_VPOS,y
            sta target_rise,x
            lda RAD_2_HMOV,y
            sta line_run,x
            lda RAD_2_STEPS,y
            sta line_steps,x
            sta line_rise,x
            dex
            bpl player_update

            ldx #$00
waitOnVBlank            
            cpx INTIM
            bmi waitOnVBlank
            sta WSYNC
            stx VBLANK


            lda #30
            sta COLUBK
; SL35
            sta WSYNC             ;3   0
            lda target_run        ;3   3
            sta HMP0              ;3   6
            and #$0f              ;2   8
            tay                   ;2  10
            iny                   ;2  12
resp_target_loop
            dey                   ;2  17
            bpl resp_target_loop  ;2  19
            sta RESP0
            
; SL36
            sta WSYNC             ;3   0
            sta HMOVE             ;3   3
            lda #WHITE            ;2   5
            sta COLUP0            ;3   8
            sta COLUP1            ;3  11
            

;--------------------
; Screen start

            ldx #HORIZON_HEIGHT
horizon_loop
            sta WSYNC
            dex
            bne horizon_loop

            ; line -------
            sta WSYNC
            lda #WHITE
            sta COLUBK
            sta WSYNC
            lda #BLACK
            sta COLUBK
            sta HMP0
            lda #$02
            sta ENAM0
            lda #$00
            sta HMM0             
            SLEEP 10
            sta RESM0             
    

            ldx #POOL_HEIGHT
pool_loop
            sta WSYNC                 ;3   0
            sta HMOVE                 ;3   3 
            txa                       ;2   5
            adc frame                 ;2   7
            ror                       ;2   9
            sta ENAM0                 ;3  12
            dec line_rise             ;5  17
            bpl pool_loop_line_wait   ;2  19
            lda line_steps            ;3  22
            sta line_rise             ;3  25
            lda line_run              ;3  28
            jmp pool_loop_line_save   ;3  32
pool_loop_line_wait
            lda #$00                  ;2  34
pool_loop_line_save
            sta HMM0                  ;3  37
            dec target_rise           ;5  42
            bpl pool_loop_paddle      ;2  44
            lda #$FF                  ;2  46
            sta GRP0                  ;3  52
            lda #$7F                  ;2  46
            sta line_steps            ;3  49
pool_loop_paddle
            lda INPT0
            bmi pool_loop_dec
            stx position
pool_loop_dec
            dex                       ;2  54
            bne pool_loop             ;2  56

            ; line -------
            sta WSYNC
            lda #WHITE
            sta COLUBK
            sta WSYNC
            lda #BLACK
            sta COLUBK

;--------------------
; Overscan start


            lda #$00
            sta ENAM0
            sta ENAM1
            sta GRP0
            sta COLUBK

            ldx #30
waitOnOverscan
            sta WSYNC
            dex
            bne waitOnOverscan

            jmp newFrame

    ORG $FD00

RAD_2_STEPS
    byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$3,$3,$3,$3,$3,$3,$3,$3,$3,$4,$4,$4,$4,$4,$5,$5,$5,$5,$6,$6,$6,$6,$7,$7,$8,$9,$9,$a,$b,$d,$f,$11,$14,$18,$1e,$28,$3c
RAD_2_HMOV
    byte $1,$1,$1,$1,$1,$1,$1,$90,$a0,$b0,$c0,$c0,$c0,$d0,$d0,$d0,$d0,$d0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
    ORG $FE00

RAD_2_HPOS
    byte $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$35,$35,$35,$35,$35,$35,$45,$45,$45,$45,$45,$55,$55,$55,$55,$65,$65,$65,$75,$75,$75,$94,$94,$94,$a4,$a4,$b4,$b4,$c4,$c4,$c4,$d4,$d4,$e4,$e4,$f4,$f4,$4,$4,$14,$24,$24,$34,$34,$44,$54,$54,$64,$64,$74,$93,$93,$a3,$b3,$b3,$c3,$d3,$e3,$e3,$f3,$3,$3,$13,$23,$33,$43,$43,$53,$63,$73,$92,$92,$a2,$b2,$c2,$d2,$e2,$e2,$f2,$2,$12,$22,$32,$42,$52,$52,$62,$72,$91,$a1,$b1,$c1,$d1,$e1,$f1,$1,$11,$21,$31,$41,$41,$51,$61,$71,$90,$a0,$b0,$c0,$d0,$e0,$f0,$0,$10,$20,$30,$40,$50,$60
RAD_2_VPOS
    byte $0,$1,$3,$4,$6,$7,$9,$a,$c,$d,$f,$10,$12,$13,$15,$16,$17,$19,$1a,$1c,$1d,$1f,$20,$21,$23,$24,$26,$27,$28,$2a,$2b,$2d,$2e,$2f,$31,$32,$33,$35,$36,$37,$39,$3a,$3b,$3c,$3e,$3f,$40,$41,$43,$44,$45,$46,$47,$49,$4a,$4b,$4c,$4d,$4e,$4f,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f,$60,$60,$61,$62,$63,$64,$65,$65,$66,$67,$68,$68,$69,$6a,$6b,$6b,$6c,$6c,$6d,$6e,$6e,$6f,$6f,$70,$70,$71,$71,$72,$72,$73,$73,$74,$74,$74,$75,$75,$75,$76,$76,$76,$76,$77,$77,$77,$77,$77,$78,$78,$78,$78,$78,$78,$78

    ORG $FFFA

    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ

    END