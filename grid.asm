.var video = $0400
.var IAL = $FB
.var XPOS = $FD
.var YPOS = $FF
.var CODE = $02

.var A1X = $4000
.var A1Y = $4001
.var A1HASTILE = $4002
.var A1SCORE = $4003
.var A1TILENO = $4004
.var A1TILEX = $4005
.var A1TILEY = $4006

.var T1X = $4010
.var T1Y = $4011
.var T1SCORE = $4012
.var T2X = $4013
.var T2Y = $4014
.var T2SCORE = $4015

.var H1X = $4020
.var H1Y = $4021

.var SETCURSOR = $E50A
.var INPRNT = $BDCD

line1: .text "agent1 :  "

BasicUpstart2(start)
start:
        jsr init_screen

init_objects:
        lda #0
        sta A1SCORE
        ldx #40
        jsr rnd
        sta T1X
        ldx #25
        jsr rnd
        sta T1Y
        ldx #6
        jsr rnd
        sta T1SCORE
        ldx #40
        jsr rnd
        sta T2X
        ldx #25
        jsr rnd
        sta T2Y
        ldx #6
        jsr rnd
        sta T2SCORE
        ldx #40
        jsr rnd
        sta H1X
        ldx #24
        jsr rnd
        sta H1Y
        ldx #40
        jsr rnd
        sta A1X
        ldx #24
        jsr rnd
        sta A1Y
        lda #0
        sta A1HASTILE

        jsr draw_agent
        jsr draw_tile1
        jsr draw_tile2
        jsr draw_hole
move:
        jsr print_score
        jsr move_agent
.break
        lda A1HASTILE
        cmp #1
        beq checkhole
        lda A1TILEX
        cmp A1X
        bne move
        lda A1TILEY
        cmp A1Y
        bne move
        lda #1
        sta A1HASTILE
        lda A1TILENO
        cmp #1
        bne create_t2
        ldx #40
        jsr rnd             // create new tile
        sta T1X
        ldx #24
        jsr rnd
        sta T1Y
        jmp checkhole
create_t2:
        ldx #40
        jsr rnd             // create new tile
        sta T2X
        ldx #24
        jsr rnd
        sta T2Y
checkhole:
        jsr draw_tile1
        jsr draw_tile2
        lda H1X
        cmp A1X
        bne move
        lda H1Y
        cmp A1Y
        bne move
                            // we have arrived at hole
.break
        lda A1TILENO
        cmp #1
        bne score_t2
        lda T1SCORE
        adc A1SCORE
        sta A1SCORE
        ldx #6
        jsr rnd
        sta T1SCORE
        jmp create_hole
score_t2:
        lda T2SCORE
        adc A1SCORE
        sta A1SCORE
        ldx #6
        jsr rnd
        sta T2SCORE
create_hole:
        lda #0
        sta A1HASTILE
        lda #0
        sta A1TILENO
        ldx #40
        jsr rnd             // create new hole
        sta H1X
        ldx #24
        jsr rnd
        sta H1Y
        jsr draw_hole
        jmp move
wait:
        jmp wait

draw_tile1:
        lda #$D1
        sta CODE
        lda T1X
        sta XPOS
        lda T1Y
        sta YPOS
        jsr plotchar
        rts
draw_tile2:
        lda #$D1
        sta CODE
        lda T2X
        sta XPOS
        lda T2Y
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
        lda A1TILENO
        cmp #0
        bne move_to_tile
        jsr find_closest_tile
move_to_tile:
        lda A1HASTILE
        cmp #1
        beq holex
        lda A1TILEX
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
        lda A1TILEY
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
        ldx #$7F
        ldy $FF
decr:
        dey
        bne decr
        dex
        bne decr
        rts

find_closest_tile:
.break
        clc
        lda A1X
        sbc T1X
        bpl store_x1
        sta $5000
        sec
        lda #$FF
        sbc $5000
store_x1:
        tax                 // X difference in X register
        clc
        lda A1Y
        sbc T1Y
        bpl store_y1
        sta $5000
        sec
        lda #$FF
        sbc $5000
store_y1:
        sta $5000           // Y difference in $5000
        txa
        clc
        adc $5000           // distance to T1 in A
        pha                 // now on stack
        clc
        lda A1X
        sbc T2X
        bpl store_x2
        sta $5000
        sec
        lda #$FF
        sbc $5000
store_x2:
        tax                 // X difference in X register
        clc
        lda A1Y
        sbc T2Y
        bpl store_y2
        sta $5000
        sec
        lda #$FF
        sbc $5000
store_y2:
        sta $5000           // Y difference in $5000
        txa
        clc
        adc $5000           // distance to T1 in A
        sta $5000           // now in $5000
        clc
        pla                 // distance 1 now in A
        cmp $5000           // d1 - d2
        bpl take_t2         // d1 > d2 -> go to T2
        lda #$1
        sta A1TILENO
        lda T1X
        sta A1TILEX
        lda T1Y
        sta A1TILEY
        jmp find_out
take_t2:
        lda #$2
        sta A1TILENO
        lda T2X
        sta A1TILEX
        lda T2Y
        sta A1TILEY
find_out:
        rts

init_screen:
        ldx #$01            // set X to 1 (white color code)
        stx $d021           // set background color
        ldx #$00            // set X to 0 (black color code)
        stx $d020           // set border color
        lda #0              // set text foreground to black
        sta $286

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

print_score:
        ldx #0
loop_text:
        lda line1,x      // read characters from line1 table of text...
        sta $07c0,x

        inx
        cpx #10          // finished when all 40 cols of a line are processed
        bne loop_text    // loop if we are not done yet
        clc
        ldx #24
        ldy #10
        jsr SETCURSOR
        lda A1SCORE + 1
        ldx A1SCORE
        jsr INPRNT
        rts

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

rnd:                        // pass max in X register
        stx $5000
        lda $d012
        eor $dc04
        sbc $dc05
        cmp $5000
        bcs rnd
        rts
