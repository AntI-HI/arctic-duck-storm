;===============================================================================
; Arctic Duck Storm
;===============================================================================

    ; Version         1.00
    ; Author:         Darius Kryszczuk
    ; Web:            https://github.com/ TODO
    ;
    ; Game where the player controls a duck flying through a snowstorm. Goal
    ; is to fly as fast as possible without hitting any of the snow ball.
    ;
    ; See README.txt for compile instructions and how to play the game.

    processor 6502

    include "vcs.h"
    include "macro.h"

;===============================================================================
; Global variables
;===============================================================================
    seg.u Variables
    org $80

    ;; P0
P0X byte
P0Y byte
P0H byte
P0Frame0Ptr word
P0ColorFrame0Ptr word
P0AnimOffset byte
P0AnimCounter byte
P0AnimSpeed byte

    ;; P1
P1X byte
P1Y byte
P1H byte
P1Frame0Ptr word
P1ColorFrame0Ptr word
P1AnimOffset byte
P1AnimCounter byte
P1AnimSpeed byte

    ;; Random
Random byte

    ;; Scoreboard
DigitsHeight byte
Score byte
Timer byte
Temp byte
OnesDigitOffset word
TensDigitOffset word
ScoreSprite byte
TimerSprite byte
TimerCounter byte
TimerSpeed byte

    ;; Audio
MuteCounter byte

    ;; Color
SkyBlue byte
SnowWhite byte
GameOverRed byte
PlayfieldColor byte
BackgroundColor byte

;===============================================================================
; Subroutines
;===============================================================================

    ;; Cartridge start
    seg code
    org $F000

VerticalSync:
    lda #2
    sta VSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC
    rts

VerticalBlank:
    sta WSYNC
    lda #2
    sta VBLANK
    ldx #33
.VerticalBlankLoop:
    ;; Reset
    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    sta COLUBK
    sta WSYNC
    dex
    bne .VerticalBlankLoop
    ;; Position Horizontally P0
    ldy #0                      ; COLUP0
    lda P0X
    and #%01111111              ; forces positive result
    jsr PositionObjectX
    ;; Position Horizontally P1
    ldy #1                      ; COLUP1
    lda P1X
    and #%01111111
    jsr PositionObjectX
    sta WSYNC
    sta HMOVE                   ; apply fine position offset
    ;; Scoreboard Calculations
    jsr CalculateDigitOffset
    ;; Turn Off
    lda #0
    sta VBLANK
    rts

;===============================================================================
; Position Object X
; -----------------
; A is a x-coordinate
; Y is the object type (0:Player0, 1:Player1, 2:Missile0, 3:Missile1, 4:Ball)
;===============================================================================
PositionObjectX:
    sta WSYNC
    sec                         ; set carry = 1
.DivideLoop:
    sbc #15
    bcs .DivideLoop             ; if carry is cleared (borrowed) then skip the jump
    eor #%0111
    asl                         ; HMP0 uses only 4 bits most significant bits
    asl
    asl
    asl
    sta HMP0,Y                  ; set fine position
    sta RESP0,Y                 ; reset 15-step position
    sta WSYNC
    rts

;===============================================================================
; Print Scoreboard
; -----------------
; Prints scoreboard based on the calculated ones and tens digit offset.
; Sources:
; - https://www.randomterrain.com/atari-2600-lets-make-a-game-spiceware-03.html
; - https://www.udemy.com/course/programming-games-for-the-atari-2600
;===============================================================================
PrintScoreboard:
    sta WSYNC
    lda #0
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    lda #$1C
    sta COLUPF
    lda #%00000000
    sta CTRLPF
    ldx DigitsHeight
.ScoreDigitLoop
    ldy TensDigitOffset
    lda Digits,Y
    and #$F0
    sta ScoreSprite
    ldy OnesDigitOffset
    lda Digits,Y
    and #$0F
    ora ScoreSprite
    sta ScoreSprite
    sta WSYNC
    sta PF1
    ldy TensDigitOffset+1
    lda Digits,Y
    and #$F0
    sta TimerSprite
    ldy OnesDigitOffset+1
    lda Digits,Y
    and #$0F
    ora TimerSprite
    sta TimerSprite
    jsr Sleep12Cycles
    sta PF1
    ldy ScoreSprite
    sta WSYNC
    sty PF1
    inc TensDigitOffset
    inc TensDigitOffset+1
    inc OnesDigitOffset
    inc OnesDigitOffset+1
    jsr Sleep12Cycles
    dex
    sta PF1
    bne .ScoreDigitLoop
    ;; Scoreboard padding
    lda #0
    sta PF0
    sta PF1
    sta PF2
    REPEAT 8
        sta WSYNC
    REPEND
    rts

CalculateDigitOffset
    ldx #1
.CalculateDigitOffsetLoop
    lda Score,X
    and #$0F
    sta Temp
    asl
    asl
    adc Temp
    sta OnesDigitOffset,X
    lda Score,X
    and #$F0
    lsr
    lsr
    sta Temp
    lsr
    lsr
    adc Temp
    sta TensDigitOffset,X
    dex
    bpl .CalculateDigitOffsetLoop
    rts

;===============================================================================
; Sleep 12 cycles
; -----------------
; Utils subroutines for 12 CPU cycles sleep.
;===============================================================================
Sleep12Cycles:
    rts

;===============================================================================
; Print Game
; -----------------
; Prints game in a two line kernel mode.
;===============================================================================
PrintGame:
    sta WSYNC
    ;; Playfield
    lda PlayfieldColor
    sta COLUPF
    lda #%00000001
    sta CTRLPF
    ;; Background
    lda BackgroundColor
    sta COLUBK
    ;; Borders
    lda #$F0                    ;
    sta PF0
    sta PF1
    lda #0
    sta PF2
    ldx #86                     ; (GAMEFIELD_WIDTH - P0Y - P1Y)/2
.PrintGameLoop:
.IsInsideP0Sprite:
    txa
    sec
    sbc P0Y
    cmp P0H
    bcc .PrintP0                ;  if carry flag set then PrintP0
    lda #0
.PrintP0:
    clc
    adc P0AnimOffset
    tay
    sta WSYNC
    lda (P0Frame0Ptr),Y
    sta GRP0
    lda (P0ColorFrame0Ptr),Y
    sta COLUP0
.IsInsideP1Sprite:
    txa
    sec
    sbc P1Y
    cmp P1H
    bcc .PrintP1
    lda #0
.PrintP1:
    clc
    adc P1AnimOffset
    tay
    sta WSYNC
    lda (P1Frame0Ptr),Y
    sta GRP1
    lda (P1ColorFrame0Ptr),Y
    dex
    bne .PrintGameLoop
    sta WSYNC
    rts

;===============================================================================
; Animate Player 0
; -----------------
; Changes Player 0 frame if P0AnimCounter is equal with P0AnimSpeed.
;===============================================================================
AnimateP0:
    lda P0AnimCounter
    and P0AnimSpeed
    beq .AnimateP0Break         ; branch on zero result
    lda #0
    sta P0AnimCounter
    lda P0H
    adc P0H
    cmp P0AnimOffset
    bne .P0Frame1
    jsr .P0Frame0
    rts
.P0Frame0:
    lda P0H
    sta P0AnimOffset
    rts
.P0Frame1:
    clc
    lda P0H
    adc P0H
    sta P0AnimOffset
    rts
.AnimateP0Break:
    inc P0AnimCounter
    rts

;===============================================================================
; Animate Player 1
; -----------------
; Changes Player 1 frame if P1AnimCounter is equal with P1AnimSpeed.
;===============================================================================
AnimateP1:
    lda P1AnimCounter
    and P1AnimSpeed
    beq .AnimateP1Break         ; branch on zero result
    lda #0
    sta P1AnimCounter
    lda P1H
    adc P1H
    cmp P1AnimOffset
    bne .P1Frame1
    jsr .P1Frame0
    rts
.P1Frame0:
    lda P1H
    sta P1AnimOffset
    rts
.P1Frame1:
    clc
    lda P1H
    adc P1H
    sta P1AnimOffset
    rts
.AnimateP1Break:
    inc P1AnimCounter
    rts

;===============================================================================
; Generate Random Player 1
; ------------------------
; Generates Player 1 with random X, NUSIZ1 and REFP1.
;===============================================================================
GenerateRandomP1:
    ;; X
    lda Random
    asl
    eor Random
    asl
    eor Random
    asl
    asl
    eor Random
    asl
    rol Random
    lsr
    lsr
    sta P1X
    lda #20
    adc P1X
    sta P1X
    lda #84
    sta P1Y
    ;; NUSIZ1
    lda Random
    and #%00000111
    sta NUSIZ1
    ;; REFP1
    lda Random
    and #%00001111
    sta REFP1
    rts

;===============================================================================
; Update Player 1 Position
; ------------------------
; Falling movement of the Player 1. Speed of falling depends on the P0AnimSpeed.
;===============================================================================
UpdateP1Position:
    lda P1Y
    clc
    cmp #0
    bmi .ResetP1Position
    jsr DetectP0P1Collision
    lda #7
    cmp P0AnimSpeed
    bpl .UpdateP1PositionFaster
    dec P1Y
    jmp .UpdateP1PositionBreak
.ResetP1Position:
    jsr GenerateRandomP1
.UpdateScore:
    sed
    lda Score
    clc
    adc #1
    sta Score
    cld
.UpdateP1PositionFaster:
    dec P1Y
    dec P1Y
    dec P1Y
.UpdateP1PositionBreak:
    rts

;===============================================================================
; Detect P0 and P1 Collision
; --------------------------
; Blinks red, plays the buzz sound and resets the score.
;===============================================================================
DetectP0P1Collision:
    lda #%10000000
    bit CXPPMM
    bne .PlayerP1Collision
    jsr SetGameColors
    jmp .CollisionFinally
    rts
.PlayerP1Collision:
    jsr GenerateCollisionSound
    jsr GameOver
.CollisionFinally:
    sta CXCLR
    lda MuteCounter
    and #32
    beq .CollisionFinallyBreak  ; branch on zero result
    lda #0
    sta MuteCounter
    jsr Mute
    rts
.CollisionFinallyBreak:
    inc MuteCounter
    rts

GameOver:
    lda GameOverRed
    sta PlayfieldColor
    sta BackgroundColor
    lda #0
    sta Score
    jsr GenerateRandomP1
    rts

SetGameColors:
    lda SkyBlue
    sta BackgroundColor
    lda SnowWhite
    sta PlayfieldColor
    rts

Mute:
    lda #0
    sta AUDV0
    sta AUDF0
    sta AUDC0
    rts

GenerateCollisionSound:
    lda #3
    sta AUDV0

    lda #20
    sta AUDF0

    lda #1
    sta AUDC0
    rts

;===============================================================================
; Overscan
; --------
; Overscan WSYNC ritual.
;===============================================================================
Overscan:
    lda #2
    sta VBLANK
    ldx #30
.OverscanLoop:
    sta WSYNC
    dex
    bne .OverscanLoop
    lda #0
    sta VBLANK
    rts

;===============================================================================
; Lookup Tables
;===============================================================================
P0Frame0
        .byte #%00000000
        .byte #%00000000
        .byte #%00011000
        .byte #%00011000
        .byte #%01111110
        .byte #%11011011
        .byte #%00001111
        .byte #%00110101
        .byte #%00011111
        .byte #%00011110
P0Frame1
        .byte #%00000000
        .byte #%00000000
        .byte #%00010000
        .byte #%00011000
        .byte #%01111110
        .byte #%11011011
        .byte #%00001111
        .byte #%00110101
        .byte #%00011111
        .byte #%00011110
P0Frame2
        .byte #%00000000
        .byte #%00000000
        .byte #%00001000
        .byte #%11011011
        .byte #%01111110
        .byte #%00011000
        .byte #%00001111
        .byte #%00110101
        .byte #%00011111
        .byte #%00011110

P0ColorFrame0
        .byte #$34
        .byte #$34
        .byte #$34
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$1E
        .byte #$D0
        .byte #$D0
        .byte #$D0
P0ColorFrame1
        .byte #$34
        .byte #$34
        .byte #$34
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$1E
        .byte #$D0
        .byte #$D0
        .byte #$D0
P0ColorFrame2
        .byte #$34
        .byte #$34
        .byte #$34
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$1E
        .byte #$D0
        .byte #$D0
        .byte #$D0

P1Frame0
        .byte #%00000000
        .byte #%00111110
        .byte #%11111011
        .byte #%11111101
        .byte #%11011111
        .byte #%01111110
        .byte #%00011100
        .byte #%00000000
        .byte #%00000000
        .byte #%00000000
P1Frame1
        .byte #%00000000
        .byte #%00111110
        .byte #%11111011
        .byte #%11111101
        .byte #%11011111
        .byte #%01111110
        .byte #%00011100
        .byte #%01000001
        .byte #%00010100
        .byte #%00000000
P1Frame2
        .byte #%00000000
        .byte #%00111110
        .byte #%11111011
        .byte #%11111101
        .byte #%11011111
        .byte #%01111110
        .byte #%00011100
        .byte #%00000000
        .byte #%01000001
        .byte #%01010101

P1ColorFrame0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
P1ColorFrame1
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
P1ColorFrame2
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0
        .byte #$F0

Digits:
    ;; 00
    .byte %01110111
    .byte %01010101
    .byte %01010101
    .byte %01010101
    .byte %01110111

    ;; 11
    .byte %00010001
    .byte %00010001
    .byte %00010001
    .byte %00010001
    .byte %00010001

    ;; 22
    .byte %01110111
    .byte %00010001
    .byte %01110111
    .byte %01000100
    .byte %01110111

    ;; 33
    .byte %01110111
    .byte %00010001
    .byte %00110011
    .byte %00010001
    .byte %01110111

    ;; 44
    .byte %01010101
    .byte %01010101
    .byte %01110111
    .byte %00010001
    .byte %00010001

    ;; 55
    .byte %01110111
    .byte %01000100
    .byte %01110111
    .byte %00010001
    .byte %01110111

    ;; 66
    .byte %01110111
    .byte %01000100
    .byte %01110111
    .byte %01010101
    .byte %01110111

    ;; 77
    .byte %01110111
    .byte %00010001
    .byte %00010001
    .byte %00010001
    .byte %00010001

    ;; 88
    .byte %01110111
    .byte %01010101
    .byte %01110111
    .byte %01010101
    .byte %01110111

    ;; 99
    .byte %01110111
    .byte %01010101
    .byte %01110111
    .byte %00010001
    .byte %01110111

    ;; AA
    .byte %00100010
    .byte %01010101
    .byte %01110111
    .byte %01010101
    .byte %01010101

    ;; BB
    .byte %01100110
    .byte %01010101
    .byte %01100110
    .byte %01010101
    .byte %01100110

    ;; CC
    .byte %00110011
    .byte %01000100
    .byte %01000100
    .byte %01000100
    .byte %00110011

    ;; DD
    .byte %01100110
    .byte %01010101
    .byte %01010101
    .byte %01010101
    .byte %01100110

    ;; EE
    .byte %01110111
    .byte %01000100
    .byte %01100110
    .byte %01000100
    .byte %01110111

    ;; FF
    .byte %01110111
    .byte %01000100
    .byte %01100110
    .byte %01000100
    .byte %01000100

;===============================================================================
; IO
;===============================================================================
IO:
.P0Down:
    lda #%00100000
    bit SWCHA
    bne .P0Left
    dec P0Y
    lda #%11110101              ; -10
    cmp P0Y
    beq .Restart
    dec P0Y
    lda #%11110101              ; -10
    cmp P0Y
    beq .Restart
    rts

.P0Left:
    lda #%01000000
    bit SWCHA
    bne .P0Right
    lda #23
    cmp P0X
    bne .P0LeftMove
    rts
.P0LeftMove:
    dec P0X
    lda #%1000
    sta REFP0
    lda #8
    sta P0AnimSpeed
    jsr AnimateP0

.P0Right:
    lda #%10000000
    bit SWCHA
    bne .P0Up
    lda P0X
    cmp #111
    bpl .P0Up
    inc P0X
    lda #%0
    sta REFP0
    lda #8
    sta P0AnimSpeed
    jsr AnimateP0

.P0Up:
    lda #%00010000
    bit SWCHA
    bne .P0NoIO
    lda P0Y
    cmp #70
    bpl .P0NoIO
    inc P0Y
    inc P0Y
    lda #1
    sta P0AnimSpeed
    jsr AnimateP0
    rts

.P0NoIO:
    dec P0Y
    lda #32
    sta P0AnimSpeed
    jsr AnimateP0
    lda #%11110101              ; -10
    cmp P0Y
    beq .Restart
    rts

.Restart:
    lda GameOverRed
    sta PlayfieldColor
    sta BackgroundColor
    lda #0
    sta Score
    jmp Start
    rts

UpdateTimer:
    lda TimerCounter
    and TimerSpeed
    beq .UpdateTimerBreak       ; branch on zero result
    lda #0
    sta TimerCounter
    sed
    lda Timer
    sec
    sbc #1
    sta Timer
    cld
    lda Timer
    cmp #0
    beq Start
    rts

.UpdateTimerBreak:
    inc TimerCounter
    rts

;===============================================================================
; App
;===============================================================================
Start:
    CLEAN_START

    ;; P0
    lda #60
    sta P0X

    lda #70
    sta P0Y

    lda #10
    sta P0H

    lda #<P0Frame0
    sta P0Frame0Ptr
    lda #>P0Frame0
    sta P0Frame0Ptr + 1

    lda #<P0ColorFrame0
    sta P0ColorFrame0Ptr
    lda #>P0ColorFrame0
    sta P0ColorFrame0Ptr + 1

    lda #0
    sta P0AnimOffset

    lda #8
    sta P0AnimSpeed
    sta P0AnimCounter

    ;; P1
    lda #105
    sta P1X

    lda #70
    sta P1Y

    lda #10
    sta P1H

    lda #<P1Frame0
    sta P1Frame0Ptr
    lda #>P1Frame0
    sta P1Frame0Ptr + 1

    lda #<P1ColorFrame0
    sta P1ColorFrame0Ptr
    lda #>P1ColorFrame0
    sta P1ColorFrame0 + 1

    lda #0
    sta P1AnimOffset
    sta P1AnimCounter

    lda #8
    sta P1AnimSpeed

    ;; Scoreboard
    lda #%11010100
    sta Random

    lda #5
    sta DigitsHeight
    lda #0
    sta Score

    sed
    lda #0
    adc #89
    sta Timer
    cld

    lda #0
    sta TimerCounter

    lda #64
    sta TimerSpeed

    lda #0
    sta MuteCounter

    ;; Colors
    lda #$8C
    sta SkyBlue
    sta BackgroundColor

    lda #$0A
    sta SnowWhite
    sta PlayfieldColor
    sta COLUP1

    lda #$44
    sta GameOverRed
Main:
    jsr VerticalSync
    jsr VerticalBlank
    jsr PrintScoreboard
    jsr PrintGame
    jsr Overscan
    jsr IO
    jsr UpdateP1Position
    jsr AnimateP1
    jsr UpdateTimer
    jmp Main

    org $FFFC
    word Start
    word Start
