// objects.asm - Object drawing for TileWorld C64

draw_tile1:
        lda T1SCORE
        ora #$30                // convert score (0-9) to PETSCII digit
        sta CODE
        lda T1X
        sta XPOS
        lda T1Y
        sta YPOS
        jsr plotchar
        rts

draw_tile2:
        lda T2SCORE
        ora #$30                // convert score (0-9) to PETSCII digit
        sta CODE
        lda T2X
        sta XPOS
        lda T2Y
        sta YPOS
        jsr plotchar
        rts

draw_hole:
        lda #CHAR_HOLE
        sta CODE
        lda H1X
        sta XPOS
        lda H1Y
        sta YPOS
        jsr plotchar
        rts

draw_agent:
        lda #CHAR_AGENT
        sta CODE
        lda A1X
        sta XPOS
        lda A1Y
        sta YPOS
        jsr plotchar
        rts

// Initialize obstacles with random positions
init_obstacles:
        ldx #0
init_obs_loop:
        txa
        pha                     // save X on stack
        ldx #SCREEN_WIDTH
        jsr rnd
        sta TEMP
        pla
        tax                     // restore X
        lda TEMP
        sta OBS_X,x
        txa
        pha                     // save X again
        ldx #SCREEN_HEIGHT
        jsr rnd
        sta TEMP
        pla
        tax                     // restore X
        lda TEMP
        sta OBS_Y,x
        inx
        cpx #NUM_OBSTACLES
        bne init_obs_loop
        rts

// Draw all obstacles on screen
draw_obstacles:
        ldx #0
draw_obs_loop:
        lda #CHAR_OBSTACLE
        sta CODE
        lda OBS_X,x
        sta XPOS
        lda OBS_Y,x
        sta YPOS
        txa
        pha                     // save X
        jsr plotchar
        pla
        tax                     // restore X
        inx
        cpx #NUM_OBSTACLES
        bne draw_obs_loop
        rts
