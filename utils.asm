// utils.asm - Utility functions for TileWorld C64

// Random number generator
// Input: X = max value (exclusive)
// Output: A = random number 0 to max-1
rnd:
        stx TEMP
rnd_loop:
        lda $d012
        eor $dc04
        sbc $dc05
        cmp TEMP
        bcs rnd_loop
        rts

// Wait for vertical blank for smooth 50/60Hz updates
wait_vsync:
        lda $d011
        bpl wait_vsync          // wait until raster line > 255
vsync_wait2:
        lda $d011
        bmi vsync_wait2         // wait until raster line < 256 (new frame)
        rts

// Check if position is blocked by an obstacle
// Input: XPOS, YPOS = position to check
// Output: Carry set if blocked, clear if free
is_blocked:
        ldx #[NUM_OBSTACLES-1]
is_blocked_loop:
        lda OBS_X,x
        cmp XPOS
        bne is_blocked_next
        lda OBS_Y,x
        cmp YPOS
        beq is_blocked_yes      // found collision
is_blocked_next:
        dex
        bpl is_blocked_loop
        clc                     // not blocked (carry clear)
        rts
is_blocked_yes:
        sec                     // blocked (carry set)
        rts

// Generate random X,Y that's not on an obstacle
// Output: XPOS, YPOS = free position
rnd_free_pos:
rnd_free_loop:
        ldx #SCREEN_WIDTH
        jsr rnd
        sta XPOS
        ldx #SCREEN_HEIGHT
        jsr rnd
        sta YPOS
        jsr is_blocked
        bcs rnd_free_loop       // blocked, try again
        rts
