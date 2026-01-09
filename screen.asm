// screen.asm - Screen routines for TileWorld C64

line1: .text "agent1 :  "

// Initialize screen - clear and set colors
init_screen:
        ldx #$01                // set X to 1 (white color code)
        stx $d021               // set background color
        ldx #$00                // set X to 0 (black color code)
        stx $d020               // set border color
        lda #0                  // set text foreground to black
        sta $286
clear:
        lda #CHAR_DOT           // fill screen with .
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $06e8,x
        lda #$00                // set foreground to black in Color Ram
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx
        bne clear
        rts

// Print score at bottom of screen
print_score:
        ldx #0
print_score_loop:
        lda line1,x
        sta $07c0,x
        inx
        cpx #10
        bne print_score_loop
        clc
        ldx #24
        ldy #10
        jsr SETCURSOR
        lda A1SCORE + 1
        ldx A1SCORE
        jsr INPRNT
        rts

// Plot character at XPOS, YPOS with character CODE
plotchar:
        lda #$00
        sta IAL+1
        ldy XPOS
        lda YPOS
        asl
        rol IAL+1
        asl
        rol IAL+1
        clc
        adc YPOS
        sta IAL
        lda #0
        adc IAL+1
        sta IAL+1
        asl IAL
        rol IAL+1
        asl IAL
        rol IAL+1
        asl IAL
        rol IAL+1
        lda #$04
        adc IAL+1
        sta IAL+1
        lda CODE
        sta (IAL),y
        rts
