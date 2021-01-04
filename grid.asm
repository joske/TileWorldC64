.var video = $0400
.var IAL = $FB
.var XPOS = $FD
.var YPOS = $FF
.var CODE = $02

BasicUpstart2(start)
start:        
        jsr init_screen

        lda #81             // draw a ball at random location
        sta CODE
        jsr rnd
        sta XPOS
        jsr rnd
        sta YPOS
        jsr plotchar
        lda #1
        sta XPOS
        lda #10
        sta YPOS
update:                     // draw an agent at 1, 10, and move it 
        lda #$01
        sta CODE
        jsr plotchar
        jsr delay
        lda #$2e
        sta CODE
        jsr plotchar
        inc XPOS
        cmp #40
        bcs update
        inc YPOS
        jmp update
                
wait:
        jmp wait

delay:
        ldx #$FF
        ldy $FF
decr:
        dey
        bne decr
        dex
        bne decr
        rts

init_screen:      
        ldx #$01            // set X to 1 (white color code)
        stx $d021           // set background color
        ldx #$00            // set X to 0 (black color code)
        stx $d020           // set border color

clear:   
        lda #$2E            // #$2E is . -> fill screen with .
        sta $0400,x  
        sta $0500,x 
        sta $0600,x 
        sta $06e8,x 
        lda #$00            // set foreground to black in Color Ram 
        sta $d800,x  
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx                 // increment X
        bne clear           // did X turn to zero yet?
                            // if not, continue with the loop
        rts                 // return from this subroutine

plotchar:                   // $FD & $FF contain the x,y coords, 
                            // $02 contains the char to plot  
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
PLOT:
        lda CODE
        sta (IAL),y
        rts

rnd:    lda $d012
        eor $dc04
        sbc $dc05
        cmp 25
        bcs rnd
        rts
