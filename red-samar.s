; =============================================================================
; Code by DKT/Samar
; 2020-07-23
; =============================================================================
; Stałe
; =============================================================================

			INCDIR			"include"
		
			INCLUDE			"hw.i"
			INCLUDE			"funcdef.i"
			INCLUDE			"hardware/cia.i"
			INCLUDE			"hardware/blit.i"
			INCLUDE			"hardware/dmabits.i"
			INCLUDE			"graphics/display.i"

			INCLUDE			"my_macros.i"

CIAAPRA			EQU	$bfe001

AllocMem		EQU	-198
OpenLibrary		EQU	-552
LoadView		EQU	-222
WaitTOF			EQU	-270
Forbid			EQU	-132

XSTRT			EQU	129
XSTOP			EQU	129+320
YSTRT			EQU	44
YSTOP			EQU	44+256
HSTRT			EQU	129
WIDTH			EQU	320
HEIGHT			EQU	256
RES			EQU	8												;8=lores, 4=hires

LINE_WIDTH		EQU	WIDTH/8

RASTER_VECTORS_CL	EQU	$7001
VECTOR_BTPL_OFFSET	EQU	0
VECTOR_Y_OFFSET		EQU	90
VECTOR_MAX_ZOOM		EQU	350

PLOTS_NR		equ	14

BACKGROUND_COLOR	equ	$0223

; =============================================================================
; Start programu
; =============================================================================

init:
	; ---------------------------------------------------------------------
	; zapis rejestrów do późniejszeo odtworzenia
	; ---------------------------------------------------------------------

			lea			CUSTOM,a6
			move.w			DMACONR(a6),d0
			or.w			#$8000,d0
			move.w			d0,olddmareq
			move.w			INTENAR(a6),d0
			or.w			#$8000,d0
			move.w			d0,oldintena
			move.w			INTREQR(a6),d0
			or.w			#$8000,d0
			move.w			d0,oldintreq
			move.w			ADKCONR(a6),d0
			or.w			#$8000,d0
			move.w			d0,oldadkcon

	; ---------------------------------------------------------------------
	; zapis copperlisty i ekranu do późniejszeo odtworzenia
	; ---------------------------------------------------------------------

			move.l			$4,a6
			move.l			#gfxname,a1
			moveq			#0,d0
			jsr			OpenLibrary(a6)
			move.l			d0,gfxbase
			move.l			d0,a6
			move.l			34(a6),oldview
			move.l			38(a6),oldcopper

			move.l			#0,a1
			jsr			LoadView(a6)
			jsr			WaitTOF(a6)
			jsr			WaitTOF(a6)
			move.l			$4,a6
			jsr			Forbid(a6)

	; ---------------------------------------------------------------------
	; inicjacja muzy
	; ---------------------------------------------------------------------

			jsr			mt_init

	; ---------------------------------------------------------------------
	; konfiuracja ekranu
	; ---------------------------------------------------------------------

			lea			CUSTOM,a6

			move.w			#$0000,BPLCON0(a6)								; ilość bitplanów
			move.w			#$0000,BPLCON1(a6)								; poziomy skrol = 0
			; move.w			#PF2PRI+$3f,BPLCON2(a6)								; playfield 2 z przodu
			move.w			#4,BPLCON2(a6)									; playfield 2 z przodu
			; move.w			#$0000,BPLCON2(a6)								; playfield 2 z przodu
			move.w			#$0000,BPL1MOD(a6)								; modulo1
			move.w			#$0000,BPL2MOD(a6)								; modulo2
			move.w			#(XSTRT+(YSTRT*256)),DIWSTRT(a6)						; DIWSTRT - górny-lewy róg ekranu (2c81)
			move.w			#((XSTOP-256)+(YSTOP-256)*256),DIWSTOP(a6)					; DIWSTOP - dolny-prawy róg ekranu (c8d1)
			move.w			#(HSTRT/2-RES),DDFSTRT(a6)							; DDFSTRT
			move.w			#((HSTRT/2-RES)+(8*((WIDTH/16)-1))),DDFSTOP(a6)					; DDFSTOP

	; ---------------------------------------------------------------------
        ; DMA i IRQ
	; ---------------------------------------------------------------------

			move.l			#empty_sprite,SPR0PTH
			move.l			#empty_sprite,SPR1PTH
			move.l			#empty_sprite,SPR2PTH
			move.l			#empty_sprite,SPR3PTH
			move.l			#empty_sprite,SPR4PTH
			move.l			#empty_sprite,SPR5PTH
			move.l			#empty_sprite,SPR6PTH
			move.l			#empty_sprite,SPR7PTH

			move.w			#%1000000111100000,DMACON(a6)							; DMA set ON
			move.w			#%0000000000011111,DMACON(a6)							; DMA set OFF
			move.w			#%1100000000000000,INTENA(a6)							; IRQ set ON
			move.w			#%0011111111111111,INTENA(a6)							; IRQ set OFF

	; ---------------------------------------------------------------------
        ; Stworzenie copperlisty
	; ---------------------------------------------------------------------

	; -- sprites ---

			move.l			#sprite1_data,d0
			move.l			#cl_sprite+2+4*00,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*01,a0
			move.w			d0,(a0)

			move.l			#sprite2_data,d0
			move.l			#cl_sprite+2+4*02,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*03,a0
			move.w			d0,(a0)

			move.l			#sprite3_data,d0
			move.l			#cl_sprite+2+4*04,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*05,a0
			move.w			d0,(a0)

			move.l			#sprite4_data,d0
			move.l			#cl_sprite+2+4*06,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*07,a0
			move.w			d0,(a0)

			move.l			#empty_sprite,d0
			move.l			#cl_sprite+2+4*08,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*09,a0
			move.w			d0,(a0)

			move.l			#empty_sprite,d0
			move.l			#cl_sprite+2+4*10,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*11,a0
			move.w			d0,(a0)

			move.l			#empty_sprite,d0
			move.l			#cl_sprite+2+4*12,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*13,a0
			move.w			d0,(a0)

			move.l			#empty_sprite,d0
			move.l			#cl_sprite+2+4*14,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_sprite+2+4*15,a0
			move.w			d0,(a0)

	; -- logo ---

			move.w			#$5200,d0
			move.l			#cl_logo_bitplanes_nr+2,a0
			move.w			d0,(a0)

	; logo bitplan 0
			move.l			#logo_bitplanes+0*WIDTH/8*HEIGHT,d0
			move.l			#cl_logo_address+2+4*00,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_logo_address+2+4*01,a0
			move.w			d0,(a0)
	; logo bitplan 1
			move.l			#logo_bitplanes+1*WIDTH/8*HEIGHT,d0
			move.l			#cl_logo_address+2+4*02,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_logo_address+2+4*03,a0
			move.w			d0,(a0)
	; logo bitplan 2
			move.l			#logo_bitplanes+2*WIDTH/8*HEIGHT,d0
			move.l			#cl_logo_address+2+4*04,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_logo_address+2+4*05,a0
			move.w			d0,(a0)
	; logo bitplan 3
			move.l			#logo_bitplanes+3*WIDTH/8*HEIGHT,d0
			move.l			#cl_logo_address+2+4*06,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_logo_address+2+4*07,a0
			move.w			d0,(a0)
	; logo bitplan 4
			move.l			#logo_bitplanes+4*WIDTH/8*HEIGHT,d0
			move.l			#cl_logo_address+2+4*08,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_logo_address+2+4*09,a0
			move.w			d0,(a0)

	; -----------------------------------------------------------------------------
	; --- vector + scroll ---
	; -----------------------------------------------------------------------------

	; --- scroll bitplanes ---

			move.w			#$6200+DBLPF,d0
			move.l			#cl_vector_bitplanes_nr+2,a0
			move.w			d0,(a0)

	; bitplan 3
			move.l			#buf5,d0
			move.l			#cl_vector_address+2+4*00,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_vector_address+2+4*01,a0
			move.w			d0,(a0)
	; bitplan 4
			move.l			#buf6,d0
			move.l			#cl_vector_address+2+4*04,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_vector_address+2+4*05,a0
			move.w			d0,(a0)
	; bitplan 5
			move.l			#buf7,d0
			move.l			#cl_vector_address+2+4*08,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_vector_address+2+4*09,a0
			move.w			d0,(a0)

	; =====================================================================
	; main loop
	; =====================================================================

		; move.l			#fonts+0*WIDTH/8*HEIGHT,d0
		; move.l			#buf+4*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8,d1
		; move.l			#WIDTH/8*HEIGHT,d2
		; jsr			copy

		; move.l			#fonts+1*WIDTH/8*HEIGHT,d0
		; move.l			#buf+5*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8,d1
		; move.l			#WIDTH/8*HEIGHT,d2
		; jsr			copy

		; move.l			#fonts+2*WIDTH/8*HEIGHT+WIDTH/16+2,d0
		; move.l			#buf+6*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8,d1
		; move.l			#WIDTH/8*HEIGHT,d2
		; jsr			copy

mainloop:

	; ---------------------------------------------------------------------
	; czekanie na nową ramkę
	; ---------------------------------------------------------------------

raster1:
			move.l			VPOSR(a6),d0
			and.l			#$1ff00,d0
			cmp.l			#300<<8,d0
			bne			raster1
raster2:
			move.l			VPOSR(a6),d0
			and.l			#$1ff00,d0
			cmp.l			#301<<8,d0
			bne			raster2

	; ---------------------------------------------------------------------
	; uruchomienie copperlisty
	; ---------------------------------------------------------------------

			move.l			#cl,COP1LCH(a6)

	; ---------------------------------------------------------------------
	; ustawienie adresów dla bitplanów vectora
	; ---------------------------------------------------------------------

			move.l			buf_index,d1

	; bitplan 0
			move.l			#buf_tab_bitplane0,a0
			move.l			(a0,d1),d0
			move.l			#cl_vector_address+2+4*02,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_vector_address+2+4*03,a0
			move.w			d0,(a0)
	; bitplan 1
			move.l			#buf_tab_bitplane1,a0
			move.l			(a0,d1),d0
			move.l			#cl_vector_address+2+4*06,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_vector_address+2+4*07,a0
			move.w			d0,(a0)
	; bitplan 2
			move.l			#buf_tab_bitplane2,a0
			move.l			(a0,d1),d0
			move.l			#cl_vector_address+2+4*10,a0
			move.w			d0,(a0)
			swap			d0
			move.l			#cl_vector_address+2+4*11,a0
			move.w			d0,(a0)

	; ---------------------------------------------------------------------
	; odtworzenie muzyki
	; ---------------------------------------------------------------------

			jsr			mt_music
			lea			CUSTOM,a6									; przywracamy CUSTOM

			addi.l			#1,time
			
	; ---------------------------------------------------------------------
	; timeline
	; ---------------------------------------------------------------------

		; rytm

			move.w			mt_PatternPos,d0
			bne			zmiana1
			cmp			pattern_pos_prev,d0
			beq			zmiana1
			neg.l			ax_add
			neg.l			ay_add
			neg.l			az_add
zmiana1:
			move			d0,pattern_pos_prev

	; ---------------------------------------------------------------------

		; show logo

			cmpi.l			#200,time
			bne			zmiana2

			jsr			show_logo

zmiana2:

	; ---------------------------------------------------------------------

		; show dycp

			cmpi.l			#370,time
			bcs			zmiana3

			jsr			my_fx
zmiana3:

	; ---------------------------------------------------------------------

		; show dycp

			cmpi.l			#370,time
			bne			zmiana32

			jsr			show_scroll
zmiana32:

	; ---------------------------------------------------------------------

		; show vector

			cmpi.l			#970,time
			bne			zmiana4

			jsr			show_vector

zmiana4:

	; ---------------------------------------------------------------------
	; sprawdzenie myszki i joya (wyjście z programu)
	; ---------------------------------------------------------------------

			btst.b			#6,CIAAPRA
			beq			exit
			btst.b			#7,CIAAPRA
			beq			exit
			jmp			mainloop

	; ---------------------------------------------------------------------
	; wyjście z aplikacji
	; ---------------------------------------------------------------------
exit:
			move.w			#$7fff,DMACON(a6)
			move.w			olddmareq,DMACON(a6)
			move.w			#$7fff,INTENA(a6)
			move.w			oldintena,INTENA(a6)
			move.w			#$7fff,INTREQ(a6)
			move.w			oldintreq,INTREQ(a6)
			move.w			#$7fff,ADKCON(a6)
			move.w			oldadkcon,ADKCON(a6)
			move.l			oldcopper,COP1LCH(a6)
			move.l			gfxbase,a6
			move.l			oldview,a1
			jsr			-222(a6)									; LoadView
			jsr			-270(a6)									; WaitTOF
			jsr			-270(a6)									; WaitTOF
			move.l			$4,a6
			jsr			-138(a6)									; Permit
			moveq.l			#0,d0
			rts

; =============================================================================
; Obrót punktu
; d0 - x
; d1 - y
; d2 - z
; kąty w zmiennych ax,ay,az
; =============================================================================

			MACRO			M_ROTATE
	; Rotation about the x axis:
	; x' = x
	; y' = cos(xangle) * y - sin(xangle) * z
	; z' = sin(xangle) * y + cos(xangle) * z
			clr.l			d4
			clr.l			d6
			move.l			ax,d3
			asl			#1,d3
			move.w			(a0,d3),d4									; sin
			move.l			d4,d5
			move.w			(a1,d3),d6									; cos
			move.l			d6,d7
	; y
			muls			d1,d6
			muls			d2,d4
			sub.l			d6,d4
	; z
			muls			d1,d5
			muls			d2,d7
			add.l			d7,d5
	; przepisanie

			lsr.l			#8,d4
			; andi.l			#$ffff,d4
			ext.l			d4

			lsr.l			#8,d5
			; andi.l			#$ffff,d5
			ext.l			d5

			move.l			d4,d1
			move.l			d5,d2

	; Rotation about the y axis:
	; x'' = cos(yangle) * x' + sin(yangle) * z'
	; y'' = y'
	; z'' = cos(yangle) * z' - sin(yangle) * x'
			clr.l			d4
			clr.l			d6
			move.l			ay,d3
			asl			#1,d3
			move.w			(a0,d3),d4									; sin
			move.l			d4,d5
			move.w			(a1,d3),d6									; cos
			move.l			d6,d7
	; x
			muls			d0,d6
			muls			d2,d4
			add.l			d6,d4
	; z
			muls			d2,d7
			muls			d0,d5
			sub.l			d7,d5
	; przepisanie
			lsr.l			#8,d4
			; andi.l			#$ffff,d4
			ext.l			d4

			lsr.l			#8,d5
			; andi.l			#$ffff,d5
			ext.l			d5

			move.l			d4,d0
			move.l			d5,d2

	; Rotation about the z axis:
	; x''' = cos(zangle) * x'' - (sin(zangle) * y''
	; y''' = sin(zangle) * x'' + (cos(zangle) * y''
	; z''' = z''
			clr.l			d4
			clr.l			d6
			move.l			az,d3
			asl			#1,d3
			move.w			(a0,d3),d4									; sin
			move.l			d4,d5
			move.w			(a1,d3),d6									; cos
			move.l			d6,d7
	; x
			muls			d0,d6
			muls			d1,d4
			sub.l			d6,d4
	; y
			muls			d0,d5
			muls			d1,d7
			add.l			d7,d5
	; przepisanie
			lsr.l			#8,d4
			lsr.l			#1,d4
			; andi.l			#$ffff,d4
			ext.l			d4

			lsr.l			#8,d5
			lsr.l			#1,d5
			; andi.l			#$ffff,d5
			ext.l			d5

			move.l			d4,d0
			move.l			d5,d1

			ENDM

; =============================================================================
; Perspektywa
; d0 - x
; d1 - y
; d2 - z
; =============================================================================
; X2D:=x*d/(z-z0);
; Y2D:=y*d/(z-z0);

			MACRO			M_PERSP
	; d
			move.l			#VECTOR_MAX_ZOOM,d3
	; x*d
			muls			d3,d0
	; y*d
			muls			d3,d1

	; z-z0
			subi.l			#2000,d2
			add.w			zoomz,d2

			divs			d2,d0
			divs			d2,d1

			; andi.l			#$ffff,d0
			ext.l			d0
			; andi.l			#$ffff,d1
			ext.l			d1
	
			ENDM

; =============================================================================
; Efekt
; =============================================================================

my_fx:

		; dycp

			jsr			dycp

		; czyszczenie

			move.l			buf_index,d0
			move.l			#buf_tab,a0
			move.l			(a0,d0),a2
			move.l			#WIDTH/8*HEIGHT-$40*WIDTH/8,d1
			jsr			clear

		; obliczenia 

			clr.l			d1
			move.l			#cosinus,a0
			move.l			zoomz_index,d0
			move.w			(a0,d0),d1
			lsl.l			#2,d1
			move.w			d1,zoomz
			addi.l			#4,d0
			andi.l			#2047,d0
			move.l			d0,zoomz_index

		; clr.l			d1
		; move.l			#zoomx_tab,a0
		; move.l			zoomx_index,d0
		; move.w			(a0,d0),d1
		; ext.l			d1
		; move.l			d1,zoomx
		; addi.l			#2,d0
		; andi.l			#1023,d0
		; move.l			d0,zoomx_index

			move.l			ax_add,d0
			add.l			d0,ax
			move.l			ay_add,d0
			add.l			d0,ay
			move.l			az_add,d0
			add.l			d0,az

			andi.l			#1023,ax
			andi.l			#1023,ay
			andi.l			#1023,az

		; obroty punktów + presp
		
			move.l			#0,pi
lp1:			move.l			pi,a1
			move.l			#px,a0
			move.l			(a0,a1),d0
			move.l			#py,a0
			move.l			(a0,a1),d1
			move.l			#pz,a0
			move.l			(a0,a1),d2

			move.l			#sinus,a0
			move.l			#cosinus,a1

			M_ROTATE
			; jsr			rotate
			M_PERSP
			; jsr			persp

			addi.l			#160,d0
			add.l			zoomx,d0
			addi.l			#VECTOR_Y_OFFSET,d1

			move.l			pi,a1
			move.l			#pxa,a2
			move.l			d0,(a2,a1)
			move.l			#pya,a3
			move.l			d1,(a3,a1)
	
			addi.l			#4,pi
			cmpi.l			#4*PLOTS_NR,pi
			bne			lp1


		; rysowanie linii
		
			move.l			buf_index,d0
			move.l			#buf_tab,a0
			move.l			(a0,d0),a2
			jsr			draw_lines

		; koniec my_fx


			addi.l			#4,buf_index
			cmpi.l			#buf_index_max,buf_index
			bne			b1
			move.l			#0,buf_index
b1:

			rts

; =============================================================================
; Draw lines
; Input:  d0=x1 d1=y1 d2=x2 d3=y2 d4=width a0=aptr
; =============================================================================

draw_lines:

		; 1 przód

			move.l			pxa+00*4,d0
			move.l			pya+00*4,d1
			move.l			pxa+01*4,d2
			move.l			pya+01*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+01*4,d0
			move.l			pya+01*4,d1
			move.l			pxa+03*4,d2
			move.l			pya+03*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+03*4,d0
			move.l			pya+03*4,d1
			move.l			pxa+02*4,d2
			move.l			pya+02*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+02*4,d0
			move.l			pya+02*4,d1
			move.l			pxa+00*4,d2
			move.l			pya+00*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; 2 tył

			move.l			pxa+04*4,d0
			move.l			pya+04*4,d1
			move.l			pxa+05*4,d2
			move.l			pya+05*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+05*4,d0
			move.l			pya+05*4,d1
			move.l			pxa+07*4,d2
			move.l			pya+07*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+07*4,d0
			move.l			pya+07*4,d1
			move.l			pxa+06*4,d2
			move.l			pya+06*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+06*4,d0
			move.l			pya+06*4,d1
			move.l			pxa+04*4,d2
			move.l			pya+04*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; 3 połączenie przód-tył

			move.l			pxa+00*4,d0
			move.l			pya+00*4,d1
			move.l			pxa+04*4,d2
			move.l			pya+04*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+01*4,d0
			move.l			pya+01*4,d1
			move.l			pxa+05*4,d2
			move.l			pya+05*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+02*4,d0
			move.l			pya+02*4,d1
			move.l			pxa+06*4,d2
			move.l			pya+06*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+03*4,d0
			move.l			pya+03*4,d1
			move.l			pxa+07*4,d2
			move.l			pya+07*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; 4 lewa szpica

			move.l			pxa+00*4,d0
			move.l			pya+00*4,d1
			move.l			pxa+08*4,d2
			move.l			pya+08*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+02*4,d0
			move.l			pya+02*4,d1
			move.l			pxa+08*4,d2
			move.l			pya+08*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+04*4,d0
			move.l			pya+04*4,d1
			move.l			pxa+08*4,d2
			move.l			pya+08*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+06*4,d0
			move.l			pya+06*4,d1
			move.l			pxa+08*4,d2
			move.l			pya+08*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; 5 prawa szpica

			move.l			pxa+01*4,d0
			move.l			pya+01*4,d1
			move.l			pxa+09*4,d2
			move.l			pya+09*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+03*4,d0
			move.l			pya+03*4,d1
			move.l			pxa+09*4,d2
			move.l			pya+09*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+05*4,d0
			move.l			pya+05*4,d1
			move.l			pxa+09*4,d2
			move.l			pya+09*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+07*4,d0
			move.l			pya+07*4,d1
			move.l			pxa+09*4,d2
			move.l			pya+09*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; 6 górna szpica

			move.l			pxa+00*4,d0
			move.l			pya+00*4,d1
			move.l			pxa+10*4,d2
			move.l			pya+10*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+01*4,d0
			move.l			pya+01*4,d1
			move.l			pxa+10*4,d2
			move.l			pya+10*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+04*4,d0
			move.l			pya+04*4,d1
			move.l			pxa+10*4,d2
			move.l			pya+10*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+05*4,d0
			move.l			pya+05*4,d1
			move.l			pxa+10*4,d2
			move.l			pya+10*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; 6 dolna szpica

			move.l			pxa+02*4,d0
			move.l			pya+02*4,d1
			move.l			pxa+11*4,d2
			move.l			pya+11*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+03*4,d0
			move.l			pya+03*4,d1
			move.l			pxa+11*4,d2
			move.l			pya+11*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+06*4,d0
			move.l			pya+06*4,d1
			move.l			pxa+11*4,d2
			move.l			pya+11*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

			move.l			pxa+07*4,d0
			move.l			pya+07*4,d1
			move.l			pxa+11*4,d2
			move.l			pya+11*4,d3
			move.l			#LINE_WIDTH,d4
			jsr			line

		; ; 6 przednia szpica

		; 	move.l			pxa+00*4,d0
		; 	move.l			pya+00*4,d1
		; 	move.l			pxa+12*4,d2
		; 	move.l			pya+12*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; 	move.l			pxa+01*4,d0
		; 	move.l			pya+01*4,d1
		; 	move.l			pxa+12*4,d2
		; 	move.l			pya+12*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; 	move.l			pxa+02*4,d0
		; 	move.l			pya+02*4,d1
		; 	move.l			pxa+12*4,d2
		; 	move.l			pya+12*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; 	move.l			pxa+03*4,d0
		; 	move.l			pya+03*4,d1
		; 	move.l			pxa+12*4,d2
		; 	move.l			pya+12*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; ; 6 tylna szpica

		; 	move.l			pxa+04*4,d0
		; 	move.l			pya+04*4,d1
		; 	move.l			pxa+13*4,d2
		; 	move.l			pya+13*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; 	move.l			pxa+05*4,d0
		; 	move.l			pya+05*4,d1
		; 	move.l			pxa+13*4,d2
		; 	move.l			pya+13*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; 	move.l			pxa+06*4,d0
		; 	move.l			pya+06*4,d1
		; 	move.l			pxa+13*4,d2
		; 	move.l			pya+13*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

		; 	move.l			pxa+07*4,d0
		; 	move.l			pya+07*4,d1
		; 	move.l			pxa+13*4,d2
		; 	move.l			pya+13*4,d3
		; 	move.l			#LINE_WIDTH,d4
		; 	jsr			line

			rts


; =============================================================================
; Obrót punktu
; d0 - x
; d1 - y
; d2 - z
; kąty w zmiennych ax,ay,az
; =============================================================================

rotate:
	; Rotation about the x axis:
	; x' = x
	; y' = cos(xangle) * y - sin(xangle) * z
	; z' = sin(xangle) * y + cos(xangle) * z
			clr.l			d4
			clr.l			d6
			move.l			ax,d3
			asl			#1,d3
			move.w			(a0,d3),d4									; sin
			move.l			d4,d5
			move.w			(a1,d3),d6									; cos
			move.l			d6,d7
	; y
			muls			d1,d6
			muls			d2,d4
			sub.l			d6,d4
	; z
			muls			d1,d5
			muls			d2,d7
			add.l			d7,d5
	; przepisanie

			lsr.l			#8,d4
			; andi.l			#$ffff,d4
			ext.l			d4

			lsr.l			#8,d5
			; andi.l			#$ffff,d5
			ext.l			d5

			move.l			d4,d1
			move.l			d5,d2

	; Rotation about the y axis:
	; x'' = cos(yangle) * x' + sin(yangle) * z'
	; y'' = y'
	; z'' = cos(yangle) * z' - sin(yangle) * x'
			clr.l			d4
			clr.l			d6
			move.l			ay,d3
			asl			#1,d3
			move.w			(a0,d3),d4									; sin
			move.l			d4,d5
			move.w			(a1,d3),d6									; cos
			move.l			d6,d7
	; x
			muls			d0,d6
			muls			d2,d4
			add.l			d6,d4
	; z
			muls			d2,d7
			muls			d0,d5
			sub.l			d7,d5
	; przepisanie
			lsr.l			#8,d4
			; andi.l			#$ffff,d4
			ext.l			d4

			lsr.l			#8,d5
			; andi.l			#$ffff,d5
			ext.l			d5

			move.l			d4,d0
			move.l			d5,d2

	; Rotation about the z axis:
	; x''' = cos(zangle) * x'' - (sin(zangle) * y''
	; y''' = sin(zangle) * x'' + (cos(zangle) * y''
	; z''' = z''
			clr.l			d4
			clr.l			d6
			move.l			az,d3
			asl			#1,d3
			move.w			(a0,d3),d4									; sin
			move.l			d4,d5
			move.w			(a1,d3),d6									; cos
			move.l			d6,d7
	; x
			muls			d0,d6
			muls			d1,d4
			sub.l			d6,d4
	; y
			muls			d0,d5
			muls			d1,d7
			add.l			d7,d5
	; przepisanie
			lsr.l			#8,d4
			lsr.l			#1,d4
			; andi.l			#$ffff,d4
			ext.l			d4

			lsr.l			#8,d5
			lsr.l			#1,d5
			; andi.l			#$ffff,d5
			ext.l			d5

			move.l			d4,d0
			move.l			d5,d1

			rts

; =============================================================================
; Perspektywa
; d0 - x
; d1 - y
; d2 - z
; =============================================================================
; X2D:=x*d/(z-z0);
; Y2D:=y*d/(z-z0);

persp:
	; d
			move.l			#VECTOR_MAX_ZOOM,d3
	; x*d
			muls			d3,d0
	; y*d
			muls			d3,d1

	; z-z0
			subi.l			#2000,d2
			add.w			zoomz,d2

			divs			d2,d0
			divs			d2,d1

			andi.l			#$ffff,d0
			ext.l			d0
			andi.l			#$ffff,d1
			ext.l			d1
	
			rts

; =============================================================================
; Rysuj punkt na bitpanie 320x200
; adres bitplanu w a0
; =============================================================================

; plot:

; 		move.l			#tab,a1
	
; 		move.l			d0,d2
; 		andi.l			#7,d2

; 		lsr.l			#3,d0
; 		mulu			#WIDTH/8,d1
; 		add.l			d1,d0

; 		move.b			(a1,d2),d4
; 		move.b			(a0,d0),d5
; 		or.b			d4,d5
; 		move.b			d5,(a0,d0)

; 		rts

; =============================================================================
; Rysowanie planu
;
;   This example uses the line draw mode of the blitter
;   to draw a line.  The line is drawn with no pattern
;   and a simple `or' blit into a single bitplane.
;   (Link with amiga.lib)
;
;   Input:  d0=x1 d1=y1 d2=x2 d3=y2 d4=width a0=aptr
;
; =============================================================================

line:
			movea.l			a2,a0

			sub.w			d0,d2										; obliczamy różnicę x -> dx
			bmi			xneg										; jeżeli ujemna to oktant 3,4,5,6

			sub.w			d1,d3										; obliczamy różnicę y calculate dy, dx jest dodatnie więc oktant 1,2,7,8
			bmi			yneg										; jeżeli dy ujemne oktant 7,8
			cmp.w			d3,d2										; porównanie dx i dy - rozróżnienie pomiędzy oktantami 1,2
			bmi			ygtx										; jeżeli y > x oktant 2
			moveq.l			#OCTANT1+LINEMODE,d5								; jeżeli nie to otkant 1
			bra			lineagain
ygtx:
			exg			d2,d3										; x musi być większe od y - zamiana
			moveq.l			#OCTANT2+LINEMODE,d5								; wybór oktant 2
			bra			lineagain
yneg:
			neg.w			d3										; abs(dy)
			cmp.w			d3,d2										; sprawdzamy pomedzy 7 i 8
			bmi			ynygtx										; jeżeli y > x to oktant 7
			moveq.l			#OCTANT8+LINEMODE,d5								; nie - 8
			bra			lineagain
ynygtx:
			exg			d2,d3										; x musi być większe od y - zamiana
			moveq.l			#OCTANT7+LINEMODE,d5								; wybór oktant 7
			bra			lineagain
xneg:
			neg.w			d2										; dx było ujemne więc negujemy, jesteśmy w oktant 3,4,5,6
			sub.w			d1,d3										; obliczamy dy
			bmi			xyneg										; jeżeli ujemne oktant 5,6
			cmp.w			d3,d2										; jeżeli nie to 3,4
			bmi			xnygtx										; jeżeli y > x, oktant 3
			moveq.l			#OCTANT4+LINEMODE,d5								; jeżeli nie to 4
			bra			lineagain
xnygtx:
			exg			d2,d3										; x musi być większe od y - zamiana
			moveq.l			#OCTANT3+LINEMODE,d5								; wybór oktant 3
			bra			lineagain
xyneg:
			neg.w			d3										; y było ujemne więc negujemy, jesteśmy w oktant 5,6
			cmp.w			d3,d2										; jeżeli y > x
			bmi			xynygtx										; oktant 6
			moveq.l			#OCTANT5+LINEMODE,d5								; nie - oktant 5
			bra			lineagain
xynygtx:
			exg			d2,d3										; x musi być większe od y - zamiana
			moveq.l			#OCTANT6+LINEMODE,d5								; wybór oktant 6

lineagain:
	; obliczamy początek (bajt w którym zaczynamy rysować)

			ror.l			#4,d0										; move upper four bits into hi word
			add.w			d0,d0										; mnożenie x 2

			mulu.w			d4,d1										; Obliczamy y1 * WIDTH
			add.l			d1,a0										; ptr += (x1 >> 3)
			add.w			d0,a0										; ptr += y1 * width

			swap			d0										; get the four bits of x1
			or.w			#$BFA,d0									; or with USEA, USEC, USED, F=A+C

			lsl.w			#2,d3										; Y = 4 * Y
			add.w			d2,d2										; X = 2 * X
			move.w			d2,d1										; set up size word
			lsl.w			#5,d1										; shift five left
			add.w			#$42,d1										; and add 1 to height, 2 to width
		
			M_BLITTER_WAIT
		
			move.w			d3,BLTBMOD(a6)									; B mod = 4 * Y
			sub.w			d2,d3
			ext.l			d3
			move.l			d3,BLTAPT(a6)									; A ptr = 4 * Y - 2 * X



			bpl			lineover									; if negative,
			or.w			#SIGNFLAG,d5									; set sign bit in con1
lineover:
		; or.w			#2,d5										; SING bit for filling
		
			move.w			d0,BLTCON0(a6)									; write control registers
			move.w			d5,BLTCON1(a6)
			move.w			d4,BLTCMOD(a6)									; C mod = bitplane width
			move.w			d4,BLTDMOD(a6)									; D mod = bitplane width
			sub.w			d2,d3
			move.w			d3,BLTAMOD(a6)									; A mod = 4 * Y - 4 * X
			move.w			#$8000,BLTADAT(a6)								; A data = 0x8000
			moveq.l			#-1,d5										; Set masks to all ones
			move.l			d5,BLTAFWM(a6)									; we can hit both masks at once
			move.l			a0,BLTCPT(a6)									; Pointer to first pixel to set
			move.l			a0,BLTDPT(a6)
			move.w			d1,BLTSIZE(a6)									; Start blit
			rts													; and return, blit still in progress.
        
; =============================================================================
; Copy and fill
; a2 - bufor z linią
; a3 - bufor docelowy
; =============================================================================

; copy_and_fill:

; 		M_BLITTER_WAIT

; 		add.l			#WIDTH/8*HEIGHT,a2
; 		add.l			#WIDTH/8*HEIGHT,a3
; 		move.l			a2,BLTAPT(a6)
; 		move.l			a3,BLTDPT(a6)
; 		move.l			#WIDTH/8,BLTAMOD(a6)
; 		move.l			#WIDTH/8,BLTDMOD(a6)
; 		move.l			#$ffffffff,BLTAFWM(a6)
; 		move.w			#$09f0,BLTCON0(a6)
; 		move.w			#FILL_XOR+BLITREVERSE,BLTCON1(a6)
; 		move.l			#HEIGHT,d0
; 		lsl.l			#5,d0
; 		or.l			#WIDTH/8,d0
; 		move.w			d0,BLTSIZE(a6)

; 		rts


; =============================================================================
; Copy
; d0 - bufor src
; d1 - bufor dst
; d2 - size
; =============================================================================

copy:

			M_BLITTER_WAIT

			move.l			d0,BLTAPT(a6)
			move.l			d1,BLTDPT(a6)
			clr.w			BLTAMOD(a6)
			clr.w			BLTDMOD(a6)
			clr.w			BLTCON1(a6)
			move.w			#$09f0,BLTCON0(a6)
			lsr.l			d2
			move.w			d2,BLTSIZE(a6)

			rts

; =============================================================================
; Czyszczenie bitplanu
; =============================================================================

clear:
			M_BLITTER_WAIT

			clr.w			BLTDMOD(a6)									;destination modulo
			move.l			#$01000000,BLTCON0(a6)								;set operation type in BLTCON0/1
			lsr.l			d1
			move.l			a2,BLTDPTH(a6)									;destination address
			move.w			d1,BLTSIZE(a6)									;blitter operation size

			rts

; =============================================================================
; Copy shifted char to btpl
; d0 - char nr
; d1 - poz y
; a1 - 1st btpl address
; =============================================================================

; put_char_blitter:

			MACRO			M_PUT_CHAR_BLITTER

			lsl.l			#2,d0
			move.l			#char_tab,a0
			move.l			(a0,d0),a2
			move.l			a1,d6
			add.l			d1,a1

			M_BLITTER_WAIT
			move.w			#WIDTH/8-4,BLTAMOD(a6)
			move.w			#WIDTH/8-4,BLTDMOD(a6)
			clr.w			BLTCON1(a6)
			move.w			#$09f0,BLTCON0(a6)
			move.l			#$ffffffff,BLTAFWM(a6)

			move.l			a2,BLTAPT(a6)
			move.l			a1,BLTDPT(a6)
			move.w			#$0702,BLTSIZE(a6)

			add.l			#WIDTH/8*HEIGHT,a1
			add.l			#WIDTH/8*HEIGHT,a2
			M_BLITTER_WAIT
			move.l			a2,BLTAPT(a6)
			move.l			a1,BLTDPT(a6)
			move.w			#$0702,BLTSIZE(a6)

			add.l			#WIDTH/8*HEIGHT,a1
			add.l			#WIDTH/8*HEIGHT,a2
			M_BLITTER_WAIT
			move.l			a2,BLTAPT(a6)
			move.l			a1,BLTDPT(a6)
			move.w			#$0702,BLTSIZE(a6)

			move.l			d6,a1

			ENDM
			; rts

; =============================================================================
; DYCP
; =============================================================================

dycp:

			; --- czyszczenie starego ---

			move.l			#txt_spaces,a3
			move.l			#0,d3
			move.l			dycp_sin_index,d4
			move.l			#sinus_dycp,a4
			add.l			d4,a4

			move.l			#fonty_bitplanes,a1
			add.l			dycp_half,a1

dycp_lp1:		clr.l			d0
			move.b			(a3,d3),d0
			clr.l			d2
			move.b			(a4),d2
			add.l			#16,a4
			mulu.w			#WIDTH/8,d2
			move.l			#0,d1
			add.l			d2,d1
			; jsr			put_char
			M_PUT_CHAR_BLITTER
			add.l			#4,a1
			add.l			#1,d3
			cmp.l			#10,d3
			bne			dycp_lp1

			; --- ruch ---

			addi.l			#2,dycp_sin_index
			andi.l			#$ff,dycp_sin_index

			sub.l			#2,dycp_scroll
			bpl			dy1
			move.l			#15,dycp_scroll
			eor.l			#2,dycp_half
			beq			dycp_no_new_char

			addi.l			#14,dycp_sin_index
			andi.l			#$ff,dycp_sin_index

			move.b			txt_temp+1,d0
			move.b			d0,txt_temp+0
			move.b			txt_temp+2,d0
			move.b			d0,txt_temp+1
			move.b			txt_temp+3,d0
			move.b			d0,txt_temp+2
			move.b			txt_temp+4,d0
			move.b			d0,txt_temp+3
			move.b			txt_temp+5,d0
			move.b			d0,txt_temp+4
			move.b			txt_temp+6,d0
			move.b			d0,txt_temp+5
			move.b			txt_temp+7,d0
			move.b			d0,txt_temp+6
			move.b			txt_temp+8,d0
			move.b			d0,txt_temp+7
			move.b			txt_temp+9,d0
			move.b			d0,txt_temp+8

			clr.l			d1
			move.l			txt_index,d0
			move.l			#txt_full,a0
			move.b			(a0,d0),d1
			bne			not_txt_end
			move.l			#0,txt_index
			bra			dy1

not_txt_end:		
			move.b			d1,txt_temp+9
			add.l			#1,txt_index

dycp_no_new_char:

dy1:

			; --- drukowanie nowego ---

			move.l			#txt_temp,a3
			move.l			#0,d3
			move.l			dycp_sin_index,d4
			move.l			#sinus_dycp,a4
			add.l			d4,a4

			move.l			#fonty_bitplanes,a1
			add.l			dycp_half,a1

dycp_lp2:		clr.l			d0
			move.b			(a3,d3),d0
			clr.l			d2
			move.b			(a4),d2
			add.l			#16,a4
			mulu.w			#WIDTH/8,d2
			move.l			#0,d1
			add.l			d2,d1
			; jsr			put_char
			M_PUT_CHAR_BLITTER
			add.l			#4,a1
			add.l			#1,d3
			cmp.l			#10,d3
			bne			dycp_lp2


	; ---------------------------------------------------------------------
	; scroll
	; ---------------------------------------------------------------------

			move.l			dycp_scroll,d0
			; lsl.l			#4,d0
			move.l			#cl_scroll+2,a0
			move.w			d0,(a0)

			rts

; =============================================================================
; Copy shifted char to btpl
; d0 - char nr
; d1 - poz y
; a1 - 1st btpl address
; =============================================================================

put_char:
			lsl.l			#2,d0
			move.l			#char_tab,a0
			move.l			(a0,d0),a2
			move.l			a1,d6
			move.l			a2,d7

			move.l			#28,d5
ch1:			move.l			(a2),(a1,d1)
			add.l			#WIDTH/8,a2
			add.l			#WIDTH/8,a1
			sub.l			#1,d5
			bne			ch1

			move.l			d6,a1
			move.l			d7,a2
			add.l			#1*WIDTH/8*HEIGHT,a1
			add.l			#1*WIDTH/8*HEIGHT,a2
			move.l			#28,d5
ch2:			move.l			(a2),(a1,d1)
			add.l			#WIDTH/8,a2
			add.l			#WIDTH/8,a1
			sub.l			#1,d5
			bne			ch2

			move.l			d6,a1
			move.l			d7,a2
			add.l			#2*WIDTH/8*HEIGHT,a1
			add.l			#2*WIDTH/8*HEIGHT,a2
			move.l			#28,d5
ch3:			move.l			(a2),(a1,d1)
			add.l			#WIDTH/8,a2
			add.l			#WIDTH/8,a1
			sub.l			#1,d5
			bne			ch3

			move.l			d6,a1

			rts

; =============================================================================
; kolory logo
; =============================================================================

show_logo:	
			move.w			logo_colors+2*00,d0
			move.l			#cl_logo_colors+2+4*00,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*01,d0
			move.l			#cl_logo_colors+2+4*01,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*02,d0
			move.l			#cl_logo_colors+2+4*02,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*03,d0
			move.l			#cl_logo_colors+2+4*03,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*04,d0
			move.l			#cl_logo_colors+2+4*04,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*05,d0
			move.l			#cl_logo_colors+2+4*05,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*06,d0
			move.l			#cl_logo_colors+2+4*06,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*07,d0
			move.l			#cl_logo_colors+2+4*07,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*08,d0
			move.l			#cl_logo_colors+2+4*08,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*09,d0
			move.l			#cl_logo_colors+2+4*09,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*10,d0
			move.l			#cl_logo_colors+2+4*10,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*11,d0
			move.l			#cl_logo_colors+2+4*11,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*12,d0
			move.l			#cl_logo_colors+2+4*12,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*13,d0
			move.l			#cl_logo_colors+2+4*13,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*14,d0
			move.l			#cl_logo_colors+2+4*14,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*15,d0
			move.l			#cl_logo_colors+2+4*15,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*16,d0
			move.l			#cl_logo_colors+2+4*16,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*17,d0
			move.l			#cl_logo_colors+2+4*17,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*18,d0
			move.l			#cl_logo_colors+2+4*18,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*19,d0
			move.l			#cl_logo_colors+2+4*19,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*20,d0
			move.l			#cl_logo_colors+2+4*20,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*21,d0
			move.l			#cl_logo_colors+2+4*21,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*22,d0
			move.l			#cl_logo_colors+2+4*22,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*23,d0
			move.l			#cl_logo_colors+2+4*23,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*24,d0
			move.l			#cl_logo_colors+2+4*24,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*25,d0
			move.l			#cl_logo_colors+2+4*25,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*26,d0
			move.l			#cl_logo_colors+2+4*26,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*27,d0
			move.l			#cl_logo_colors+2+4*27,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*28,d0
			move.l			#cl_logo_colors+2+4*28,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*29,d0
			move.l			#cl_logo_colors+2+4*29,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*30,d0
			move.l			#cl_logo_colors+2+4*30,a0
			move.w			d0,(a0)

			move.w			logo_colors+2*31,d0
			move.l			#cl_logo_colors+2+4*31,a0
			move.w			d0,(a0)

			rts

; =============================================================================
; kolory vector
; =============================================================================

show_vector:	
			move.w			vector_colors+2*08,d0
			move.l			#cl_vector_colors+2+4*00,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*09,d0
			move.l			#cl_vector_colors+2+4*01,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*10,d0
			move.l			#cl_vector_colors+2+4*02,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*11,d0
			move.l			#cl_vector_colors+2+4*03,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*12,d0
			move.l			#cl_vector_colors+2+4*04,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*13,d0
			move.l			#cl_vector_colors+2+4*05,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*14,d0
			move.l			#cl_vector_colors+2+4*06,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*15,d0
			move.l			#cl_vector_colors+2+4*07,a0
			move.w			d0,(a0)

			rts

show_scroll:

			move.w			vector_colors+2*00,d0
			move.l			#cl_vector_colors+2+4*08,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*01,d0
			move.l			#cl_vector_colors+2+4*09,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*02,d0
			move.l			#cl_vector_colors+2+4*10,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*03,d0
			move.l			#cl_vector_colors+2+4*11,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*04,d0
			move.l			#cl_vector_colors+2+4*12,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*05,d0
			move.l			#cl_vector_colors+2+4*13,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*06,d0
			move.l			#cl_vector_colors+2+4*14,a0
			move.w			d0,(a0)

			move.w			vector_colors+2*07,d0
			move.l			#cl_vector_colors+2+4*15,a0
			move.w			d0,(a0)

			rts

; =============================================================================
; DANE
; =============================================================================

			CNOP			0,4
time:			dc.l			0
dycp_sin_index:		dc.l			0
dycp_scroll:		dc.l			0
dycp_half:		dc.l			2
txt_index:		dc.l			0
		
			include			"txt.s"
			
txt_temp:		dc.b			'          '
txt_spaces:		dc.b			'          '

			CNOP			0,4
		; duże tablice
			include			"sincos.i"

			CNOP			0,4
AdrMulTab
			dc.l			0

			CNOP			0,4
buf_nr			dc.b			0

; 		CNOP			0,4
; tab:		dc.b			$80,$40,$20,$10,$08,$04,$02,$01

			CNOP			0,4
zoomx:			dc.l			0
zoomz:			dc.l			0
zoomx_index:	
			dc.l			0
zoomz_index:	
			dc.l			512

pi:			dc.l			0

px:
			dc.l			-70,70
			dc.l			-70,70
			dc.l			-70,70
			dc.l			-70,70
			dc.l			-400,400
			dc.l			0,0
			dc.l			0,0
py:
			dc.l			70,70
			dc.l			-70,-70
			dc.l			70,70
			dc.l			-70,-70
			dc.l			0,0
			dc.l			400,-400
			dc.l			0,0
pz:
			dc.l			-70,-70
			dc.l			-70,-70
			dc.l			70,70
			dc.l			70,70
			dc.l			0,0
			dc.l			0,0
			dc.l			-400,400

pxa:
			blk.l			14,0
pya:
			blk.l			14,0

			CNOP			0,4

ax:			dc.l			0
ay:			dc.l			0
az:			dc.l			0

ax_add:			dc.l			-4
ay_add:			dc.l			-3
az_add:			dc.l			6

pattern_pos_prev	dc.l			0

			CNOP			0,4

buf_index_max		EQU	16

buf_index:		dc.l			0

buf_tab:
			dc.l			buf0
			dc.l			buf1
			dc.l			buf2
			dc.l			buf3

buf_tab_bitplane0:
			dc.l			buf1
			dc.l			buf2
			dc.l			buf3
			dc.l			buf0

buf_tab_bitplane1:
			dc.l			buf2
			dc.l			buf3
			dc.l			buf0
			dc.l			buf1

buf_tab_bitplane2:
			dc.l			buf3
			dc.l			buf0
			dc.l			buf1
			dc.l			buf2


; -----------------------------------------------------------------------------
; zmienne standardowe
; -----------------------------------------------------------------------------

			CNOP			0,4
oldview:
			dc.l			0
oldcopper:	
			dc.l			0
gfxbase:	
			dc.l			0
frame:          
			dc.l			0

			CNOP			0,4
olddmareq:	
			dc.w			0
oldintreq:	
			dc.w			0
oldintena:	
			dc.w			0
oldadkcon:	
			dc.w			0

			CNOP			0,4
gfxname: 	
			dc.b			'graphics.library',0

			include			"fonts.i"

			CNOP			0,4
char_tab:	
			blk.l			$20,fonty+chr_spacja

		;			$20			$21			$22			$23
			dc.l			fonty+chr_spacja,	fonty+chr_wykrzyknik,	fonty+chr_spacja,	fonty+chr_spacja
		;			$24			$25			$26			$27
			dc.l			fonty+chr_spacja,	fonty+chr_spacja,	fonty+chr_spacja,	fonty+chr_spacja
		;			$28			$29			$2a			$2b
			dc.l			fonty+chr_naw1,		fonty+chr_naw2,		fonty+chr_spacja,	fonty+chr_spacja
		;			$2c			$2d			$2e			$2f
			dc.l			fonty+chr_przecinek,	fonty+chr_spacja,	fonty+chr_kropka,	fonty+chr_spacja

		;			$30			$31			$32			$33
			dc.l			fonty+chr_0,		fonty+chr_1,		fonty+chr_2,		fonty+chr_3
		;			$34			$35			$36			$37
			dc.l			fonty+chr_4,		fonty+chr_5,		fonty+chr_6,		fonty+chr_7
		;			$38			$39			$3a			$3b
			dc.l			fonty+chr_8,		fonty+chr_9,		fonty+chr_spacja,	fonty+chr_spacja
		;			$3c			$3d			$3e			$3f
			dc.l			fonty+chr_spacja,	fonty+chr_spacja,	fonty+chr_spacja,	fonty+chr_pytanie

			blk.l			$20,fonty+chr_spacja

		;			$60			$61			$62			$63
			dc.l			fonty+chr_spacja,	fonty+chr_a,		fonty+chr_b,		fonty+chr_c
		;			$64			$65			$66			$67
			dc.l			fonty+chr_d,		fonty+chr_e,		fonty+chr_f,		fonty+chr_g
		;			$68			$69			$6a			$6b
			dc.l			fonty+chr_h,		fonty+chr_i,		fonty+chr_j,		fonty+chr_k
		;			$6c			$6d			$6e			$6f
			dc.l			fonty+chr_l,		fonty+chr_m,		fonty+chr_n,		fonty+chr_o

		;			$70			$71			$72			$73
			dc.l			fonty+chr_p,		fonty+chr_q,		fonty+chr_r,		fonty+chr_s
		;			$74			$75			$76			$77
			dc.l			fonty+chr_t,		fonty+chr_u,		fonty+chr_v,		fonty+chr_w
		;			$78			$79			$7a			$7b
			dc.l			fonty+chr_x,		fonty+chr_y,		fonty+chr_z,		fonty+chr_spacja
		;			$7c			$7d			$7e			$7f
			dc.l			fonty+chr_spacja,	fonty+chr_spacja,	fonty+chr_spacja,	fonty+chr_spacja

		; ---------------------------------------------------------------------

		; a   b   c   d   e   f   g   h   i   j
		; $61,$62,$63,$64,$65,$66,$67,$68,$69,$6A

		; k   l   m   n   o   p   q   r   s   t
		; $6B,$6C,$6D,$6E,$6F,$70,$71,$72,$73,$74

		; u   v   w   x   y   z   .   ,   !   ?
		; $75,$76,$77,$78,$79,$7a,$2e,$2c,$21,$3f

		; '   "   0   1   2   3   4   5   6   7
		; $20,$20,$30,$31,$32,$33,$34,$35,$36,$37

		; 8   9   @   (   )
		; $38,$39,$40,$28,$29

; =============================================================================
; CHIP RAM
; =============================================================================

			Section			ChipRAM,Data_c

; -----------------------------------------------------------------------------
; Bitmapa
; -----------------------------------------------------------------------------

			CNOP			0,4
fonty:	
			incbin			"gfx/fonty.raw"

			CNOP			0,4
empty_sprite:		dc.l			$40004100
			dc.l			$00000000
			dc.l			0

			CNOP			0,4
sprite1_data:		dc.l			$70403002
			blk.l			$130-$70,$ffffffff
			dc.l			0

sprite2_data:		dc.l			$70483002
			blk.l			$130-$70,$ffffffff
			dc.l			0

sprite3_data:		dc.l			$70d03002
			blk.l			$130-$70,$ffffffff
			dc.l			0

sprite4_data:		dc.l			$70d83002
			blk.l			$130-$70,$ffffffff
			dc.l			0

			CNOP			0,4
logo_bitplanes:
			incbin			"gfx/SAMAR_logo_32col.raw"

	; bufor żeby nie nachodziło na dalsze regiony
; empty_buf1:

			CNOP			0,4
			blk.b			WIDTH/8*$40,0
buf:
buf0:
			blk.b			WIDTH/8*HEIGHT,0
			blk.b			WIDTH/8*$40,0
buf1:
			blk.b			WIDTH/8*HEIGHT,0
			blk.b			WIDTH/8*$40,0
buf2:
			blk.b			WIDTH/8*HEIGHT,0
			blk.b			WIDTH/8*$40,0
buf3:
			blk.b			WIDTH/8*HEIGHT,0
			blk.b			WIDTH/8*$40,0

fonty_bitplanes:
		; incbin			"gfx/fonty_dark.raw"
buf5:
			blk.b			WIDTH/8*HEIGHT,0
buf6:
			blk.b			WIDTH/8*HEIGHT,0
buf7:
			blk.b			WIDTH/8*HEIGHT,0

	; bufor żeby nie nachodziło na dalsze regiony
; empty_buf2:
			blk.b			WIDTH/8*HEIGHT,0

			CNOP			0,4
logo_colors:	
			incbin			"gfx/SAMAR_logo_32col.pal"

			CNOP			0,4
vector_colors:
			incbin			"gfx/fonty.pal"
			dc.w			BACKGROUND_COLOR,$0511,$0633,$0755,$0877,$0999,$0bbb,$0ddd
	
; -----------------------------------------------------------------------------
; copperlista
; -----------------------------------------------------------------------------

			CNOP			0,4
cl:

			; dc.w			$1fc,0
			dc.w			$106,$0c00									;(AGA compat. if any Dual Playf. mode)

cl_logo_bitplanes_nr:
			dc.w			BPLCON0,0
			dc.w			BPLCON1,0

cl_logo_address:
			dc.w			BPL1PTL,0
			dc.w			BPL1PTH,0
			dc.w			BPL2PTL,0
			dc.w			BPL2PTH,0
			dc.w			BPL3PTL,0
			dc.w			BPL3PTH,0
			dc.w			BPL4PTL,0
			dc.w			BPL4PTH,0
			dc.w			BPL5PTL,0
			dc.w			BPL5PTH,0
			dc.w			BPL6PTL,0
			dc.w			BPL6PTH,0

cl_sprite:
			dc.w			SPR0PTL,0
			dc.w			SPR0PTH,0
			dc.w			SPR1PTL,0
			dc.w			SPR1PTH,0
			dc.w			SPR2PTL,0
			dc.w			SPR2PTH,0
			dc.w			SPR3PTL,0
			dc.w			SPR3PTH,0
			dc.w			SPR4PTL,0
			dc.w			SPR4PTH,0
			dc.w			SPR5PTL,0
			dc.w			SPR5PTH,0
			dc.w			SPR6PTL,0
			dc.w			SPR6PTH,0
			dc.w			SPR7PTL,0
			dc.w			SPR7PTH,0

cl_logo_colors:
			dc.w			COLOR00,BACKGROUND_COLOR
			dc.w			COLOR01,BACKGROUND_COLOR
			dc.w			COLOR02,BACKGROUND_COLOR
			dc.w			COLOR03,BACKGROUND_COLOR
			dc.w			COLOR04,BACKGROUND_COLOR
			dc.w			COLOR05,BACKGROUND_COLOR
			dc.w			COLOR06,BACKGROUND_COLOR
			dc.w			COLOR07,BACKGROUND_COLOR
			dc.w			COLOR08,BACKGROUND_COLOR
			dc.w			COLOR09,BACKGROUND_COLOR
			dc.w			COLOR10,BACKGROUND_COLOR
			dc.w			COLOR11,BACKGROUND_COLOR
			dc.w			COLOR12,BACKGROUND_COLOR
			dc.w			COLOR13,BACKGROUND_COLOR
			dc.w			COLOR14,BACKGROUND_COLOR
			dc.w			COLOR15,BACKGROUND_COLOR
			dc.w			COLOR16,BACKGROUND_COLOR
			dc.w			COLOR17,BACKGROUND_COLOR
			dc.w			COLOR18,BACKGROUND_COLOR
			dc.w			COLOR19,BACKGROUND_COLOR
			dc.w			COLOR20,BACKGROUND_COLOR
			dc.w			COLOR21,BACKGROUND_COLOR
			dc.w			COLOR22,BACKGROUND_COLOR
			dc.w			COLOR23,BACKGROUND_COLOR
			dc.w			COLOR24,BACKGROUND_COLOR
			dc.w			COLOR25,BACKGROUND_COLOR
			dc.w			COLOR26,BACKGROUND_COLOR
			dc.w			COLOR27,BACKGROUND_COLOR
			dc.w			COLOR28,BACKGROUND_COLOR
			dc.w			COLOR29,BACKGROUND_COLOR
			dc.w			COLOR30,BACKGROUND_COLOR
			dc.w			COLOR31,BACKGROUND_COLOR

			; dc.l			$fffffffe									; koniec

		; --- vector ---

			dc.w			RASTER_VECTORS_CL-4,$ff00							; czekam na raster

cl_vector_address:
			dc.w			BPL1PTL,0
			dc.w			BPL1PTH,0
			dc.w			BPL2PTL,0
			dc.w			BPL2PTH,0
			dc.w			BPL3PTL,0
			dc.w			BPL3PTH,0
			dc.w			BPL4PTL,0
			dc.w			BPL4PTH,0
			dc.w			BPL5PTL,0
			dc.w			BPL5PTH,0
			dc.w			BPL6PTL,0
			dc.w			BPL6PTH,0

cl_vector_bitplanes_nr:
			dc.w			BPLCON0,0
cl_scroll:
			dc.w			BPLCON1,$000f

cl_vector_colors:
			dc.w			COLOR08,BACKGROUND_COLOR
			dc.w			COLOR09,BACKGROUND_COLOR
			dc.w			COLOR10,BACKGROUND_COLOR
			dc.w			COLOR11,BACKGROUND_COLOR
			dc.w			COLOR12,BACKGROUND_COLOR
			dc.w			COLOR13,BACKGROUND_COLOR
			dc.w			COLOR14,BACKGROUND_COLOR
			dc.w			COLOR15,BACKGROUND_COLOR
			dc.w			COLOR00,BACKGROUND_COLOR
			dc.w			COLOR01,BACKGROUND_COLOR
			dc.w			COLOR02,BACKGROUND_COLOR
			dc.w			COLOR03,BACKGROUND_COLOR
			dc.w			COLOR04,BACKGROUND_COLOR
			dc.w			COLOR05,BACKGROUND_COLOR
			dc.w			COLOR06,BACKGROUND_COLOR
			dc.w			COLOR07,BACKGROUND_COLOR


cl_sprites_colors:
			dc.w			COLOR16,BACKGROUND_COLOR
			dc.w			COLOR17,BACKGROUND_COLOR
			dc.w			COLOR18,BACKGROUND_COLOR
			dc.w			COLOR19,BACKGROUND_COLOR

			dc.w			COLOR20,BACKGROUND_COLOR
			dc.w			COLOR21,BACKGROUND_COLOR
			dc.w			COLOR22,BACKGROUND_COLOR
			dc.w			COLOR23,BACKGROUND_COLOR

			dc.w			COLOR24,BACKGROUND_COLOR
			dc.w			COLOR25,BACKGROUND_COLOR
			dc.w			COLOR26,BACKGROUND_COLOR
			dc.w			COLOR27,BACKGROUND_COLOR

			dc.w			COLOR28,BACKGROUND_COLOR
			dc.w			COLOR29,BACKGROUND_COLOR
			dc.w			COLOR30,BACKGROUND_COLOR
			dc.w			COLOR31,BACKGROUND_COLOR

			; dc.w			RASTER_VECTORS_CL+2,$ff00							; czekam na raster

			; dc.w			$ffdf,$fffe									; allow VPOS>$ff
			dc.l			$fffffffe									; koniec

; =============================================================================
; MUZA
; =============================================================================

			CNOP			0,4
			include			"ProTracker_v2.3a.s"

