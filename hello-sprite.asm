; Hello Sprite
; originl version February 17, 2007
; John Harrison
; An extension of Hello World, based mostly from GALP

;* 2008-May-01 --- V1.0a
;*                 replaced reference of hello-sprite.inc with sprite.inc

INCLUDE "gbhw.inc" ; standard hardware definitions from devrs.com
INCLUDE "ibmpc1.inc" ; ASCII character set from devrs.com
INCLUDE "sprite.inc" ; specific defs

LayerGrassStart EQU $0a * 8
LayerTrackStart EQU $0c * 8
ScreenHeight EQU $12 * 8

; create variables. make sure to use tab (why??)
	SpriteAttr Sprite0
	LoByteVar VBLANKED
	LoWordVar scrollX

; IRQs
SECTION "Vblank", HOME[$0040]
	jp DMACODELOC
SECTION "LCDC", HOME[$0048]
	jp LCDC_STAT
SECTION "Timer_Overflow", HOME[$0050]
	reti
SECTION "Serial", HOME[$0058]
	reti
SECTION "p1thru4", HOME[$0060]
	reti

; boot loader jumps to here.
SECTION "start", HOME[$0100]
nop
jp begin

; *****************************************************************************
; header and and hardcoded data
; *****************************************************************************
	ROM_HEADER ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE
INCLUDE "memory.asm"
TileData:
	chr_IBMPC1 1, 4 ; some character set
TileDataEnd:
Title:
	;  [                    ] 20tiles
	DB "                                "
	DB "                                "
	DB "                                "
	DB "                                "
	DB "                                "
	DB "                                "
	
	DB "                                "
	DB $85,$86,$87,$88,$85,$86,$87,$88,$85,$86,$87,$88,$85,$86,$87,$88,$85,$86,$87,$88,$85,$86,$87,$88,$85,$86,$87,$88,$85,$86,$87,$88
	DB $89,$8a,$8b,$8c,$89,$8a,$8b,$8c,$89,$8a,$8b,$8c,$89,$8a,$8b,$8c,$89,$8a,$8b,$8c,$89,$8a,$8b,$8c,$89,$8a,$8b,$8c,$89,$8a,$8b,$8c
	DB $8d,$8e,$8f,$90,$8d,$8e,$8f,$90,$8d,$8e,$8f,$90,$8d,$8e,$8f,$90,$8d,$8e,$8f,$90,$8d,$8e,$8f,$90,$8d,$8e,$8f,$90,$8d,$8e,$8f,$90
	
	DB $82,$81,$82,$80,$80,$81,$82,$81,$80,$82,$80,$81,$80,$80,$80,$82,$82,$80,$81,$82,$82,$80,$82,$82,$82,$82,$81,$80,$82,$80,$80,$81
	DB $81,$80,$81,$80,$82,$82,$82,$81,$80,$82,$81,$82,$80,$81,$80,$81,$81,$81,$80,$81,$81,$80,$81,$80,$82,$82,$82,$81,$82,$82,$82,$82
	DB $82,$80,$82,$81,$82,$82,$80,$81,$82,$81,$80,$81,$81,$80,$80,$81,$81,$82,$80,$82,$80,$82,$80,$81,$82,$80,$80,$80,$80,$80,$81,$80
	DB $81,$82,$82,$81,$82,$81,$82,$80,$80,$82,$82,$82,$80,$82,$80,$82,$81,$81,$82,$81,$80,$80,$81,$80,$80,$80,$80,$80,$80,$81,$80,$80
	DB $80,$80,$80,$82,$81,$80,$82,$81,$81,$81,$80,$80,$81,$81,$80,$82,$82,$82,$80,$80,$80,$81,$82,$82,$82,$80,$81,$81,$80,$80,$82,$81
	
	DB $83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83
	DB $84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84,$84
	
	DB $81,$82,$80,$82,$82,$81,$82,$81,$82,$81,$82,$80,$81,$82,$80,$81,$80,$80,$82,$80,$80,$82,$80,$80,$81,$81,$81,$81,$80,$81,$80,$82
TitleEnd:
GameTile:
GameTile_Dirt0:		incbin "tile_dirt0.png.2bp"
GameTile_Dirt1:		incbin "tile_dirt1.png.2bp"
GameTile_Dirt2:		incbin "tile_dirt2.png.2bp"
GameTile_TrackHi:	incbin "tile_trackhi.png.2bp"
GameTile_TrackLow:	incbin "tile_tracklow.png.2bp"
GameTileMnt:
GameTile_Mnt00:		incbin "tile_mnt00.png.2bp"
GameTile_Mnt10:		incbin "tile_mnt10.png.2bp"
GameTile_Mnt20:		incbin "tile_mnt20.png.2bp"
GameTile_Mnt30:		incbin "tile_mnt30.png.2bp"
GameTile_Mnt01:		incbin "tile_mnt01.png.2bp"
GameTile_Mnt11:		incbin "tile_mnt11.png.2bp"
GameTile_Mnt21:		incbin "tile_mnt21.png.2bp"
GameTile_Mnt31:		incbin "tile_mnt31.png.2bp"
GameTile_Mnt02:		incbin "tile_mnt02.png.2bp"
GameTile_Mnt12:		incbin "tile_mnt12.png.2bp"
GameTile_Mnt22:		incbin "tile_mnt22.png.2bp"
GameTile_Mnt32:		incbin "tile_mnt32.png.2bp"
GameTileMntEnd:
GameTileEnd:

; *****************************************************************************
; Initialization
; *****************************************************************************
begin:
	nop
	di
	ld sp, $ffff			; set the stack pointer to highest mem location + 1

; NEXT FOUR LINES FOR SETTING UP SPRITES *hs*
	call initdma			; move routine to HRAM
	ld a, IEF_LCDC | IEF_VBLANK
	ld [rIE], a				; ENABLE VBLANK INTERRUPT (and lcdc)
	ei						; LET THE INTS FLY

init:
	ld a, %11100100		; Window palette colors, from darkest to lightest
	ld [rBGP], a		; set background and window pallette
	ldh [rOBP0], a		; set sprite pallette 0
	ldh [rOBP1], a		; 1 (choose palette 0 or 1 when describing the sprite)
	
	ld a, 0				; SET SCREEN TO TO UPPER RIGHT HAND CORNER
	ld [rSCX], a
	ld [rSCY], a
	
	call StopLCD		; YOU CAN NOT LOAD $8000 WITH LCD ON
	ld hl, TileData
	ld de, _VRAM		; $8000
	ld bc, TileDataEnd - TileData
	call mem_CopyMono	; load tile data
	
	ld hl, GameTile
	ld de, _VRAM + $800
	ld bc, GameTileEnd - GameTile
	call mem_CopyVRAM
	
	ld a, 0
	ld hl, OAMDATALOC
	ld bc, OAMDATALENGTH
	call mem_Set		; *hs* erase sprite table

	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
	ld [rLCDC], a		; LCD back on

	ld a, 32			; ascii for space
	ld hl, _SCRN0
	ld bc, SCRN_VX_B * SCRN_VY_B
	call mem_SetVRAM
; *****************************************************************************
; Main code
; *****************************************************************************
; general init
	ld a, $0
	ld [Sprite0YAddr], a
	ld [Sprite0XAddr], a
	ld [Sprite0TileNum], a
	ld [Sprite0Flags], a
	ld [scrollX], a

; write those tiles from ROM!
	ld hl,Title
	ld de, _SCRN0+(SCRN_VY_B*0)
	ld bc, TitleEnd-Title
	call mem_CopyVRAM
	
;um hi, make hblank trigger lcdc interrupt
	ld	a, STATF_MODE00
	ld	[rSTAT], a

; you want sound? too bad. here crash.
	ld a, $00 ;$80
	ld [rNR52], a ; turn OFF sound system
	
	ld a, $ff
	ld [rNR50], a ; turn on both speakers
	
	ld a, $ff
	ld [rNR51], a ; direct all channels to all speakers
	
; sound ch1
	ld a, %00000000
	ld [rNR10], a ; no sweep
	
	ld a, %01111111 ; DDLLLLLL - Duty (00:12.5% 01:25% 10:50% 11:75%), length
	ld [rNR11], a ; set duty and length 
	
	ld a, %00111000 ; VVVVDSSS - initial value, 0=dec 1=inc, num of env sweep
	ld [rNR12], a ; envelope
	
	ld a, %01111111
	ld [rNR13], a ; lo frequency
	
	ld a, %10000110 ; IC...FFF - Initial, counter, hi frequency
	ld [rNR14], a ; pull the trigger

; sprite metadata
	PutSpriteYAddr Sprite0, 0	; set Sprite0 location to 0,0
	PutSpriteXAddr Sprite0, 0
	ld a, 1						; happy face :-)
	ld [Sprite0TileNum], a		; tile address
	ld a, %00000000				; gbhw.inc 33-42
	ld [Sprite0Flags], a

MainLoop:
	halt
	nop					; always put NOP after HALT
	
	ld a, [VBLANKED]
	or a				; V-Blank interrupt ?
	jr z, MainLoop		; No, some other interrupt
	xor a
	ld [VBLANKED], a	; clear flag
	
	; 16-bit scroller variable increment 
	ld a, [scrollX]
	ld c, a
	ld a, [scrollX+1]
	ld b, a
	inc bc
	ld a, b
	ld [scrollX+1], a
	ld a, c
	ld [scrollX], a
	
	srl b
	rr c
	srl b
	rr c				; mountains move at 1/4 pixels per second
	ld a, c
	ld [rSCX], a
	
	call	GetKeys
	
	push	af
	and	PADF_RIGHT
	call	nz,right
	pop	af
	
	push	af
	and	PADF_LEFT
	call	nz,left
	pop	af
	
	push	af
	and	PADF_UP
	call	nz,up
	pop	af
	
	push	af
	and	PADF_DOWN
	call	nz,down
	pop	af
	
	push	af
	and	PADF_START
	call	nz,Yflip
	pop	af
	
	jr	MainLoop

right:
	GetSpriteXAddr Sprite0
	cp SCRN_X - 8	; already on RHS of screen?
	ret z
	inc a
	PutSpriteXAddr Sprite0, a
	ret
left:
	GetSpriteXAddr Sprite0
	cp 0			; already on LHS of screen?
	ret z
	dec a
	PutSpriteXAddr Sprite0, a
	ret
up:
	GetSpriteYAddr Sprite0
	cp 0			; already at top of screen?
	ret z
	dec a
	PutSpriteYAddr Sprite0, a
	ret
down:
	GetSpriteYAddr Sprite0
	cp SCRN_Y - 8	; already at bottom of screen?
	ret z
	inc a
	PutSpriteYAddr Sprite0, a
	ret
Yflip:
	ld a, [Sprite0Flags]
	xor OAMF_YFLIP	; toggle flip of sprite vertically
	ld [Sprite0Flags], a
	ret

; *hs* START
initdma:
	ld de, DMACODELOC
	ld hl, dmacode
	ld bc, dmaend-dmacode
	call mem_CopyVRAM	; copy when VRAM is available
	ret
dmacode:
	push af
	push bc
	push de
	push hl
	
	ld a, OAMDATALOCBANK	; bank where OAM DATA is stored
	ldh [rDMA], a			; Start DMA
	ld a, $28				; 160ns
dma_wait:
	dec a
	jr nz, dma_wait
	
	ld a, 1				; yes, mister halt, this is vblank calling.
	ld [VBLANKED], a
	
	pop hl
	pop de
	pop bc
	pop af
	reti
dmaend:
; *hs* END

LCDC_STAT:
	push af
	push hl
	push de
	push bc
	
	ld a, [rLY]			; read scanline
	ld h, 80-1			; -1 because I'm using way too many clock cycles
	cp h
	jp C, endLCDC		; if scanLine < 80, go to the end
	
	ld h, 122
	cp h
	jp NC, endLCDC		; if scanline >= 122, go to the end
	
	ld hl, 0			; clear hl dunno...
	
	sub 75
	ld h, a				; h = scanline - 56
	
	ld a, [scrollX]
	ld e, a
	ld a, [scrollX+1]
	ld d, a				; de = scrollX 16bit
	
	ld a, h				; a = (scanline - 56)
	sra a				; a = (scanline - 56) >> 1
	ld c, a				; h = ^^
	ld b, 0
	call Mul16			; hl = (scrollX * (scanline - 56) >> 1)
	
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l				; hl = (scrollX * (scanline - 56) >> 1) >> 3
	
	ld a, l				; a = low order bits
	
	ld [rSCX], a		; then set it as scroll var
	
endLCDC:
	pop bc
	pop de
	pop hl
	pop af
	reti

Mul8b:					; this routine performs the operation HL=H*E
	ld d, 0				; clearing D and L
	ld l, d
	ld b, 8				; we have 8 bits
Mul8bLoop:
	add hl, hl			; advancing a bit
	jp nc, Mul8bSkip	; if zero, we skip the addition (jp is used for speed)
	add hl, de			; adding to the product if necessary
Mul8bSkip:
	dec b
	jp nz, Mul8bLoop
	ret

Mul16:					; This routine performs the operation DEHL=BC*DE
	ld hl, 0
	ld a, 16
Mul16Loop:
	add hl, hl
	rl e
	rl d
	jp nc, NoMul16
	add hl, bc
	jp nc, NoMul16
	inc de				; This instruction (with the jump) is like an "ADC DE,0"
NoMul16:
	dec a
	jp nz, Mul16Loop
	ret

;Div8:				; this routine performs the operation HL=HL/D
;	xor a			; clearing the upper 8 bits of AHL
;	ld b,16			; the length of the dividend (16 bits)
;Div8Loop:
;	add hl,hl		; advancing a bit
;	rla
;	cp d			; checking if the divisor divides the digits chosen (in A)
;	jp c,Div8NextBit; if not, advancing without subtraction
;	sub d			; subtracting the divisor
;	inc l			; and setting the next digit of the quotient
;Div8NextBit:
;	djnz Div8Loop
;	ret

; GetKeys: adapted from APOCNOW.ASM and gbspec.txt
GetKeys:			; gets keypress
	ld a, P1F_5		; set bit 5
	ld [rP1], a		; select P14 by setting it low
	ld a, [rP1]
 	ld a, [rP1]		; wait a few cycles
	cpl				; complement A. "You are a very very nice Accumulator..."
	and $0f			; look at only the first 4 bits
	swap a			; move bits 3-0 into 7-4
	ld b,a			; and store in b

 	ld a, P1F_4		; select P15
 	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]		; wait for the bouncing to stop
	cpl				; as before, complement...
	and $0f			; and look only for the last 4 bits
	or b			; combine with the previous result
	ret				; do we need to reset joypad? (gbspec line 1082)

; StopLCD:
; turn off LCD if it is on and wait until the LCD is off
StopLCD:
	ld a,[rLCDC]
	rlca			; Put the high bit of LCDC into the Carry flag
	ret nc			; Screen is off already. Exit.
.wait:				; Loop until we are in VBlank
	ld a, [rLY]
	cp 145			; Is display on scan line 145 yet?
	jr nz, .wait	; no, keep waiting
	ld a, [rLCDC]	; Turn off the LCD
	res 7, a		; Reset bit 7 of LCDC
	ld [rLCDC], a
	ret
