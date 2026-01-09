// agent.asm - Agent movement and AI for TileWorld C64

// Move agent: erase old position, update, draw new
move_agent:
        lda #CHAR_DOT
        sta CODE
        lda A1X
        sta XPOS
        lda A1Y
        sta YPOS
        jsr plotchar
        jsr update_agent
        jsr draw_agent
        jsr wait_vsync
        rts

// Update agent: find tile, move to it, if has tile, move to hole
// Greedy movement, random only when blocked
update_agent:
        lda A1TILENO
        cmp #0
        bne ua_move_to_tile
        jsr find_closest_tile
ua_move_to_tile:
        // Get target position
        lda A1HASTILE
        cmp #1
        beq ua_get_hole
        lda A1TILEX
        sta TEMP+1
        lda A1TILEY
        sta TEMP+2
        jmp ua_move_toward
ua_get_hole:
        lda H1X
        sta TEMP+1
        lda H1Y
        sta TEMP+2

ua_move_toward:
        // Check if we're escaping vertically (X was blocked)
        lda A1ESCAPE_V
        beq ua_check_horiz_esc
        // In vertical escape - try X first to see if we cleared the obstacle
        lda TEMP+1
        cmp A1X
        beq ua_clear_vert_esc   // X aligned, escape done
        bcc ua_esc_try_left
        jsr move_right
        bcc ua_clear_vert_esc   // X worked, clear escape
        jmp ua_do_vert_escape   // X still blocked, continue escaping
ua_esc_try_left:
        jsr move_left
        bcc ua_clear_vert_esc
        jmp ua_do_vert_escape

ua_clear_vert_esc:
        lda #0
        sta A1ESCAPE_V
        jmp ua_done

ua_do_vert_escape:
        // Continue vertical escape in remembered direction
        lda A1ESCAPE_V
        cmp #1
        beq ua_cont_up
        jsr move_down
        bcc ua_vert_done1
        jsr move_up             // down blocked, try up
        bcs ua_vert_done1
        lda #1
        sta A1ESCAPE_V
ua_vert_done1:
        jmp ua_done
ua_cont_up:
        jsr move_up
        bcc ua_vert_done2
        jsr move_down           // up blocked, try down
        bcs ua_vert_done2
        lda #2
        sta A1ESCAPE_V
ua_vert_done2:
        jmp ua_done

ua_check_horiz_esc:
        // Check if we're escaping horizontally (Y was blocked)
        lda A1ESCAPE_H
        beq ua_normal_move
        // In horizontal escape - try Y first to see if we cleared the obstacle
        lda TEMP+2
        cmp A1Y
        beq ua_clear_horiz_esc  // Y aligned, escape done
        bcc ua_esc_try_up
        jsr move_down
        bcc ua_clear_horiz_esc  // Y worked, clear escape
        jmp ua_do_horiz_escape  // Y still blocked, continue escaping
ua_esc_try_up:
        jsr move_up
        bcc ua_clear_horiz_esc
        jmp ua_do_horiz_escape

ua_clear_horiz_esc:
        lda #0
        sta A1ESCAPE_H
        jmp ua_done

ua_do_horiz_escape:
        // Continue horizontal escape in remembered direction
        lda A1ESCAPE_H
        cmp #1
        beq ua_cont_left
        jsr move_right
        bcc ua_horiz_done1
        jsr move_left           // right blocked, try left
        bcs ua_horiz_done1
        lda #1
        sta A1ESCAPE_H
ua_horiz_done1:
        jmp ua_done
ua_cont_left:
        jsr move_left
        bcc ua_horiz_done2
        jsr move_right          // left blocked, try right
        bcs ua_horiz_done2
        lda #2
        sta A1ESCAPE_H
ua_horiz_done2:
        jmp ua_done

ua_normal_move:
        // Normal movement - try Y direction first
        lda TEMP+2
        cmp A1Y
        beq ua_try_x            // Y aligned, try X
        bcc ua_try_up
        jsr move_down
        bcc ua_norm_done1
        jmp ua_escape_horiz     // Y blocked, start horizontal escape
ua_try_up:
        jsr move_up
        bcc ua_norm_done1
        jmp ua_escape_horiz     // Y blocked, start horizontal escape
ua_norm_done1:
        jmp ua_done

ua_try_x:
        // Only try X when Y is already aligned
        lda TEMP+1
        cmp A1X
        bne ua_try_x_move
        jmp ua_done             // both aligned, at target
ua_try_x_move:
        bcc ua_try_left
        jsr move_right
        bcc ua_norm_done2
        jmp ua_escape_vert      // X blocked, start vertical escape
ua_try_left:
        jsr move_left
        bcc ua_norm_done2
        jmp ua_escape_vert      // X blocked, start vertical escape
ua_norm_done2:
        jmp ua_done

ua_escape_vert:
        // X blocked - escape vertically, remember direction
        lda A1ESCAPE_V
        cmp #1
        beq ua_esc_goup         // was escaping up, continue
        cmp #2
        beq ua_esc_godown       // was escaping down, continue
        // No escape direction set - pick randomly
        lda $d012
        and #1
        beq ua_esc_godown
ua_esc_goup:
        jsr move_up
        bcc ua_esc_up_ok
        jsr move_down           // up blocked, try down
        bcs ua_escv_done1
        lda #2
        sta A1ESCAPE_V
ua_escv_done1:
        jmp ua_done
ua_esc_up_ok:
        lda #1
        sta A1ESCAPE_V
        jmp ua_done
ua_esc_godown:
        jsr move_down
        bcc ua_esc_down_ok
        jsr move_up             // down blocked, try up
        bcs ua_escv_done2
        lda #1
        sta A1ESCAPE_V
ua_escv_done2:
        jmp ua_done
ua_esc_down_ok:
        lda #2
        sta A1ESCAPE_V
        jmp ua_done

ua_escape_horiz:
        // Y blocked - escape horizontally, remember direction
        lda A1ESCAPE_H
        cmp #1
        beq ua_esc_goleft       // was escaping left, continue
        cmp #2
        beq ua_esc_goright      // was escaping right, continue
        // No escape direction set - pick randomly
        lda $d012
        and #1
        beq ua_esc_goright
ua_esc_goleft:
        jsr move_left
        bcc ua_esc_left_ok
        jsr move_right          // left blocked, try right
        bcs ua_esch_done1
        lda #2
        sta A1ESCAPE_H
ua_esch_done1:
        jmp ua_done
ua_esc_left_ok:
        lda #1
        sta A1ESCAPE_H
        jmp ua_done
ua_esc_goright:
        jsr move_right
        bcc ua_esc_right_ok
        jsr move_left           // right blocked, try left
        bcs ua_esch_done2
        lda #1
        sta A1ESCAPE_H
ua_esch_done2:
        jmp ua_done
ua_esc_right_ok:
        lda #2
        sta A1ESCAPE_H
ua_done:
        rts

// Movement functions with boundary and obstacle checking
// Return: carry clear = moved, carry set = blocked

move_left:
        lda A1X
        beq ml_blocked          // at left edge (X=0)
        sec
        sbc #1                  // proposed new X
        sta XPOS
        lda A1Y
        sta YPOS
        jsr is_blocked
        bcs ml_blocked          // blocked by obstacle
        dec A1X
        clc                     // success
        rts
ml_blocked:
        sec                     // failed
        rts

move_right:
        lda A1X
        cmp #[SCREEN_WIDTH-1]
        beq mr_blocked          // at right edge
        clc
        adc #1                  // proposed new X
        sta XPOS
        lda A1Y
        sta YPOS
        jsr is_blocked
        bcs mr_blocked          // blocked by obstacle
        inc A1X
        clc                     // success
        rts
mr_blocked:
        sec                     // failed
        rts

move_up:
        lda A1Y
        beq mu_blocked          // at top edge (Y=0)
        lda A1X
        sta XPOS
        lda A1Y
        sec
        sbc #1                  // proposed new Y
        sta YPOS
        jsr is_blocked
        bcs mu_blocked          // blocked by obstacle
        dec A1Y
        clc                     // success
        rts
mu_blocked:
        sec                     // failed
        rts

move_down:
        lda A1Y
        cmp #[SCREEN_HEIGHT-1]
        beq md_blocked          // at bottom edge
        lda A1X
        sta XPOS
        lda A1Y
        clc
        adc #1                  // proposed new Y
        sta YPOS
        jsr is_blocked
        bcs md_blocked          // blocked by obstacle
        inc A1Y
        clc                     // success
        rts
md_blocked:
        sec                     // failed
        rts

// Find closest tile using Manhattan distance
find_closest_tile:
        // Calculate distance to T1
        sec
        lda A1X
        sbc T1X
        bpl fct_store_x1
        eor #$FF                // negate (two's complement)
        clc
        adc #1
fct_store_x1:
        tax                     // X difference in X register
        sec
        lda A1Y
        sbc T1Y
        bpl fct_store_y1
        eor #$FF
        clc
        adc #1
fct_store_y1:
        sta TEMP                // Y difference in TEMP
        txa
        clc
        adc TEMP                // distance to T1 in A
        pha                     // now on stack
        // Calculate distance to T2
        sec
        lda A1X
        sbc T2X
        bpl fct_store_x2
        eor #$FF
        clc
        adc #1
fct_store_x2:
        tax                     // X difference in X register
        sec
        lda A1Y
        sbc T2Y
        bpl fct_store_y2
        eor #$FF
        clc
        adc #1
fct_store_y2:
        sta TEMP                // Y difference in TEMP
        txa
        clc
        adc TEMP                // distance to T2 in A
        sta TEMP                // now in TEMP
        clc
        pla                     // distance 1 now in A
        cmp TEMP                // d1 - d2
        bpl fct_take_t2         // d1 > d2 -> go to T2
        lda #$1
        sta A1TILENO
        lda T1X
        sta A1TILEX
        lda T1Y
        sta A1TILEY
        jmp fct_out
fct_take_t2:
        lda #$2
        sta A1TILENO
        lda T2X
        sta A1TILEX
        lda T2Y
        sta A1TILEY
fct_out:
        rts
