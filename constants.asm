// constants.asm - All constants and variables for TileWorld C64

// Screen constants
.const SCREEN_WIDTH = 40
.const SCREEN_HEIGHT = 24
.const CHAR_DOT = $2E
.const CHAR_AGENT = $01
.const CHAR_HOLE = 81
.const CHAR_OBSTACLE = $A6
.const NUM_OBSTACLES = 5

// Zero-page variables for plotting (must stay here for indirect addressing)
.var IAL = $FB
.var XPOS = $FD
.var YPOS = $FF
.var CODE = $02

// Game state in high memory (safe from BASIC ROM conflicts)
.var TEMP = $4030

.var A1X = $4000
.var A1Y = $4001
.var A1HASTILE = $4002
.var A1SCORE = $4003        // 16-bit: $4003 (low) and $4004 (high)
.var A1TILENO = $4005
.var A1TILEX = $4006
.var A1TILEY = $4007

.var T1X = $4010
.var T1Y = $4011
.var T1SCORE = $4012
.var T2X = $4013
.var T2Y = $4014
.var T2SCORE = $4015

.var H1X = $4020
.var H1Y = $4021

// Obstacle positions
.var OBS_X = $4040          // NUM_OBSTACLES bytes: X positions
.var OBS_Y = $4045          // NUM_OBSTACLES bytes: Y positions

// Escape direction memory: 0=none, 1=left/up, 2=right/down
.var A1ESCAPE_H = $404A     // horizontal escape
.var A1ESCAPE_V = $404B     // vertical escape

// ROM routine addresses
.var SETCURSOR = $E50A
.var INPRNT = $BDCD
