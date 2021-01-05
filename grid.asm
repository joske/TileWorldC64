.var video = $0400
.var IAL = $FB
.var XPOS = $FD
.var YPOS = $FF
.var CODE = $02

.var A1X = $4000
.var A1Y = $4001
.var A1HASTILE = $4002
.var A1SCORE = $4003

.var T1X = $4010
.var T1Y = $4011

.var H1X = $4020
.var H1Y = $4021

BasicUpstart2(start)
start:        
        jsr init_screen

init_objects:
        jsr rnd
        sta T1X
        jsr rnd
        sta T1Y
        jsr rnd
        sta H1X
        jsr rnd
        sta H1Y
        jsr rnd
        sta A1X
        jsr rnd
        sta A1Y
        lda #0
        sta A1HASTILE

        jsr draw_agent
        jsr draw_tile
        jsr draw_hole
move:        
        jsr move_agent
        lda A1HASTILE
        cmp #1
        beq checkhole
        lda T1X
        cmp A1X
        bne move
        lda T1Y
        cmp A1Y
        bne move
        lda #1
        sta A1HASTILE
        jsr rnd             // create new tile
        sta T1X
        jsr rnd
        sta T1Y
        jsr draw_tile
checkhole:        
        lda H1X
        cmp A1X
        bne move
        lda H1Y
        cmp A1Y
        bne move
        lda #0
        sta A1HASTILE
        jsr rnd             // create new hole
        sta H1X
        jsr rnd
        sta H1Y
        jsr draw_hole
        jmp move
wait:
        jmp wait

draw_tile:        
        lda #$D1
        sta CODE
        lda T1X
        sta XPOS
        lda T1Y
        sta YPOS
        jsr plotchar
        rts
draw_hole:        
        lda #81
        sta CODE
        lda H1X
        sta XPOS
        lda H1Y
        sta YPOS
        jsr plotchar
        rts
draw_agent:                 // draw agent
        lda #$01            // $01 is A
        sta CODE
        lda A1X
        sta XPOS
        lda A1Y
        sta YPOS
        jsr plotchar
        rts
move_agent:                 // draw agent
        lda #$2e            // .
        sta CODE
        lda A1X
        sta XPOS
        lda A1Y
        sta YPOS
        jsr plotchar
        jsr update_agent
        jsr draw_agent
        jsr delay
        rts
        
update_agent:               // find tile, move to it, if has tile, move to hole
        lda A1HASTILE
        cmp #1
        beq holex
        lda T1X
        jmp cmpx
holex:
        lda H1X
cmpx:        
        cmp A1X
        beq updown
        bcc left
        jsr move_right
        jmp done
left:        
        jsr move_left
        jmp done
updown:
        lda A1HASTILE
        cmp #1
        beq holey
        lda T1Y
        jmp cmpy
holey:
        lda H1Y
cmpy:        
        cmp A1Y
        beq done
        bcc up
        jsr move_down
        jmp done
up:
        jsr move_up
done:        
        rts

move_left:
        dec A1X
        rts
                
move_right:
        inc A1X
        rts
                
move_up:
        dec A1Y
        rts
                
move_down:
        inc A1Y
        rts
                
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

rnd:    
        lda $d012
        eor $dc04
        sbc $dc05
        cmp 25
        bcs rnd
        rts

