

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
WHITE = $00f
BLACK = 0
#else
; PAL Colors
WHITE = $00E
BLACK = 0
#endif

HORIZON_HEIGHT  = 94
POOL_HEIGHT     = 96

; ----------------------------------
; variables

  SEG.U variables

    ORG $80

frame        ds 1    
position     ds 1
line_run     ds 1
line_steps   ds 1   
line_rise    ds 1   


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

player_update
            lda frame
            and #$01
            clc
            adc position
            sta position
            clc
            lsr
            lsr
            lsr
            sec
            sbc #16
            bcc _left
            ldx #$f0
            jmp _run
_left
            eor #$ff
            clc
            adc #$01
            ldx #$10
_run
            stx line_run
            sta line_steps
            sta line_rise
            ldx #$00
waitOnVBlank            
            cpx INTIM
            bmi waitOnVBlank
            sta WSYNC
            stx VBLANK


            lda #BLACK
            sta COLUBK
; SL35
            sta WSYNC             ;3   0
            
; SL36
            sta WSYNC             ;3   0
            sta HMOVE             ;3   3
            lda #WHITE            ;2   5
            sta COLUP0            ;3   8
            

;--------------------
; Screen start

            ldx #HORIZON_HEIGHT
horizon_loop
            sta WSYNC
            dex
            bne horizon_loop

            ; line -------
            sta WSYNC
            sta WSYNC
            lda #$00
            sta HMM0             
            SLEEP 33
            sta RESM0             
    

            sta WSYNC
            lda #$02
            sta ENAM0
            ldx #POOL_HEIGHT
pool_loop
            sta WSYNC                 ;3   0
            sta HMOVE                 ;3   3 
            SLEEP 10
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
pool_loop_paddle
            ; test paddle
            ;lda INPT0
            ;bmi pool_loop_dec
            ;stx position
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


            lda #$000
            sta ENAM0
            sta COLUBK

            ldx #30
waitOnOverscan
            sta WSYNC
            dex
            bne waitOnOverscan

            jmp newFrame
    
    ORG $FFFA

    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ

    END