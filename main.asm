// main.asm - TileWorld C64 Main Entry Point

#import "constants.asm"

BasicUpstart2(start)

start:
        jsr init_screen
        jsr init_obstacles
        jsr draw_obstacles

init_objects:
        lda #0
        sta A1SCORE
        sta A1SCORE + 1
        sta A1HASTILE
        sta A1TILENO
        sta A1ESCAPE_H          // no horizontal escape
        sta A1ESCAPE_V          // no vertical escape

        // Initialize tile 1 (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta T1X
        lda YPOS
        sta T1Y
        ldx #6
        jsr rnd
        sta T1SCORE

        // Initialize tile 2 (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta T2X
        lda YPOS
        sta T2Y
        ldx #6
        jsr rnd
        sta T2SCORE

        // Initialize hole (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta H1X
        lda YPOS
        sta H1Y

        // Initialize agent (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta A1X
        lda YPOS
        sta A1Y

        jsr draw_agent
        jsr draw_tile1
        jsr draw_tile2
        jsr draw_hole

// Main game loop
game_loop:
        jsr print_score
        jsr move_agent

        // Check if agent reached tile (only if not carrying one)
        lda A1HASTILE
        cmp #1
        beq check_hole

        lda A1TILEX
        cmp A1X
        bne game_loop
        lda A1TILEY
        cmp A1Y
        bne game_loop

        // Agent picked up tile
        lda #1
        sta A1HASTILE
        lda A1TILENO
        cmp #1
        bne create_t2

        // Create new tile 1 (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta T1X
        lda YPOS
        sta T1Y
        jmp check_hole

create_t2:
        // Create new tile 2 (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta T2X
        lda YPOS
        sta T2Y

check_hole:
        jsr draw_tile1
        jsr draw_tile2

        lda H1X
        cmp A1X
        bne game_loop
        lda H1Y
        cmp A1Y
        bne game_loop

        // Agent arrived at hole - add score
        lda A1TILENO
        cmp #1
        bne score_t2

        // Score from tile 1
        clc
        lda A1SCORE
        adc T1SCORE
        sta A1SCORE
        lda A1SCORE+1
        adc #0
        sta A1SCORE+1
        ldx #6
        jsr rnd
        sta T1SCORE
        jmp create_hole

score_t2:
        // Score from tile 2
        clc
        lda A1SCORE
        adc T2SCORE
        sta A1SCORE
        lda A1SCORE+1
        adc #0
        sta A1SCORE+1
        ldx #6
        jsr rnd
        sta T2SCORE

create_hole:
        lda #0
        sta A1HASTILE
        sta A1TILENO

        // Create new hole (not on obstacle)
        jsr rnd_free_pos
        lda XPOS
        sta H1X
        lda YPOS
        sta H1Y
        jsr draw_hole
        jmp game_loop

// Include other modules
#import "utils.asm"
#import "screen.asm"
#import "objects.asm"
#import "agent.asm"
