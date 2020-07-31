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
RES			EQU	8									;8=lores, 4=hires

LINE_WIDTH		EQU	WIDTH/8

RASTER_VECTORS_CL	EQU	$7001

PLOTS_NR		equ	14

BACKGROUND_COLOR	equ	$0223

; DEBUG_COLORS		EQU	1

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

		move.w			#$0000,BPLCON0(a6)						; ilość bitplanów
		move.w			#$0000,BPLCON1(a6)						; poziomy skrol = 0
		move.w			#PF2PRI,BPLCON2(a6)						; playfield 2 z przodu
		move.w			#$0000,BPL1MOD(a6)						; modulo1
		move.w			#$0000,BPL2MOD(a6)						; modulo2
		move.w			#(XSTRT+(YSTRT*256)),DIWSTRT(a6)				; DIWSTRT - górny-lewy róg ekranu (2c81)
		move.w			#((XSTOP-256)+(YSTOP-256)*256),DIWSTOP(a6)			; DIWSTOP - dolny-prawy róg ekranu (c8d1)
		move.w			#(HSTRT/2-RES),DDFSTRT(a6)					; DDFSTRT
		move.w			#((HSTRT/2-RES)+(8*((WIDTH/16)-1))),DDFSTOP(a6)			; DDFSTOP

	; ---------------------------------------------------------------------
        ; DMA i IRQ
	; ---------------------------------------------------------------------

		move.w			#%1000000111000000,DMACON(a6)					; DMA set ON
		move.w			#%0000000000111111,DMACON(a6)					; DMA set OFF
		move.w			#%1100000000000000,INTENA(a6)					; IRQ set ON
		move.w			#%0011111111111111,INTENA(a6)					; IRQ set OFF

	; ---------------------------------------------------------------------
        ; Stworzenie copperlisty
	; ---------------------------------------------------------------------

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

	; kolory logo
	
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

	; -----------------------------------------------------------------------------
	; --- vector + scroll ---
	; -----------------------------------------------------------------------------

		move.w			#$6200+DBLPF,d0
		move.l			#cl_vector_bitplanes_nr+2,a0
		move.w			d0,(a0)

	; bitplan 3
		move.l			#buf+4*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*02,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*03,a0
		move.w			d0,(a0)
	; bitplan 4
		move.l			#buf+5*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*06,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*07,a0
		move.w			d0,(a0)
	; bitplan 5
		move.l			#buf+6*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*10,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*11,a0
		move.w			d0,(a0)

	; kolory vector
	
		move.w			vector_colors+2*00,d0
		move.l			#cl_vector_colors+2+4*00,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*01,d0
		move.l			#cl_vector_colors+2+4*01,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*02,d0
		move.l			#cl_vector_colors+2+4*02,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*03,d0
		move.l			#cl_vector_colors+2+4*03,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*04,d0
		move.l			#cl_vector_colors+2+4*04,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*05,d0
		move.l			#cl_vector_colors+2+4*05,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*06,d0
		move.l			#cl_vector_colors+2+4*06,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*07,d0
		move.l			#cl_vector_colors+2+4*07,a0
		move.w			d0,(a0)

	; kolory scroll
	
		move.w			vector_colors+2*08,d0
		move.l			#cl_vector_colors+2+4*08,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*09,d0
		move.l			#cl_vector_colors+2+4*09,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*10,d0
		move.l			#cl_vector_colors+2+4*10,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*11,d0
		move.l			#cl_vector_colors+2+4*11,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*12,d0
		move.l			#cl_vector_colors+2+4*12,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*13,d0
		move.l			#cl_vector_colors+2+4*13,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*14,d0
		move.l			#cl_vector_colors+2+4*14,a0
		move.w			d0,(a0)

		move.w			vector_colors+2*15,d0
		move.l			#cl_vector_colors+2+4*15,a0
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
raster:
		move.l			VPOSR(a6),d0
		and.l			#$1ff00,d0
		cmp.l			#300<<8,d0
		bne			raster

	; ---------------------------------------------------------------------
	; ustawienie adresów dla bitplanów vectora
	; ---------------------------------------------------------------------

		move.l			buf_index,d1

	; bitplan 0
		move.l			#buf_tab_bitplane0,a0
		move.l			(a0,d1),d0
		move.l			#cl_vector_address+2+4*00,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*01,a0
		move.w			d0,(a0)
	; bitplan 1
		move.l			#buf_tab_bitplane1,a0
		move.l			(a0,d1),d0
		move.l			#cl_vector_address+2+4*04,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*05,a0
		move.w			d0,(a0)
	; bitplan 2
		move.l			#buf_tab_bitplane2,a0
		move.l			(a0,d1),d0
		move.l			#cl_vector_address+2+4*08,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*09,a0
		move.w			d0,(a0)

	; ---------------------------------------------------------------------
	; uruchomienie copperlisty
	; ---------------------------------------------------------------------

		move.l			#cl,COP1LCH(a6)

	; ---------------------------------------------------------------------
	; odtworzenie muzyki
	; ---------------------------------------------------------------------

		jsr			mt_music
		lea			CUSTOM,a6							; przywracamy CUSTOM

	; ---------------------------------------------------------------------
	; FX
	; ---------------------------------------------------------------------

		jsr			my_fx

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
		jsr			-222(a6)							; LoadView
		jsr			-270(a6)							; WaitTOF
		jsr			-270(a6)							; WaitTOF
		move.l			$4,a6
		jsr			-138(a6)							; Permit
		rts

; =============================================================================
; Efekt
; =============================================================================

my_fx:

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

		addi.l			#3,ax
		addi.l			#4,ay
		addi.l			#5,az

		andi.l			#1023,ax
		andi.l			#1023,ay
		andi.l			#1023,az

		; obroty punktów + presp
		
		move.l			#0,pi
lp1:		move.l			pi,a1
		move.l			#px,a0
		move.l			(a0,a1),d0
		move.l			#py,a0
		move.l			(a0,a1),d1
		move.l			#pz,a0
		move.l			(a0,a1),d2

		move.l			#sinus,a0
		move.l			#cosinus,a1

		jsr			rotate
		jsr			persp

		addi.l			#160,d0
		add.l			zoomx,d0
		addi.l			#80,d1

		move.l			pi,a1
		move.l			#pxa,a2
		move.l			d0,(a2,a1)
		move.l			#pya,a3
		move.l			d1,(a3,a1)
	
		addi.l			#4,pi
		cmpi.l			#4*PLOTS_NR,pi
		bne			lp1

		; czyszczenie i rysowanie

		move.l			buf_index,d0
		move.l			#buf_tab,a0
		move.l			(a0,d0),a2
		move.l			#WIDTH/8*HEIGHT,d1
		jsr			clear
		jsr			draw_lines

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

		; 6 przednia szpica

		move.l			pxa+00*4,d0
		move.l			pya+00*4,d1
		move.l			pxa+12*4,d2
		move.l			pya+12*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		move.l			pxa+01*4,d0
		move.l			pya+01*4,d1
		move.l			pxa+12*4,d2
		move.l			pya+12*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		move.l			pxa+02*4,d0
		move.l			pya+02*4,d1
		move.l			pxa+12*4,d2
		move.l			pya+12*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		move.l			pxa+03*4,d0
		move.l			pya+03*4,d1
		move.l			pxa+12*4,d2
		move.l			pya+12*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		; 6 tylna szpica

		move.l			pxa+04*4,d0
		move.l			pya+04*4,d1
		move.l			pxa+13*4,d2
		move.l			pya+13*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		move.l			pxa+05*4,d0
		move.l			pya+05*4,d1
		move.l			pxa+13*4,d2
		move.l			pya+13*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		move.l			pxa+06*4,d0
		move.l			pya+06*4,d1
		move.l			pxa+13*4,d2
		move.l			pya+13*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

		move.l			pxa+07*4,d0
		move.l			pya+07*4,d1
		move.l			pxa+13*4,d2
		move.l			pya+13*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line

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
		move.w			(a0,d3),d4							; sin
		move.l			d4,d5
		move.w			(a1,d3),d6							; cos
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

		divs			#256,d4
		andi.l			#$ffff,d4
		ext.l			d4

		divs			#256,d5
		andi.l			#$ffff,d5
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
		move.w			(a0,d3),d4							; sin
		move.l			d4,d5
		move.w			(a1,d3),d6							; cos
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
		divs			#256,d4
		andi.l			#$ffff,d4
		ext.l			d4

		divs			#256,d5
		andi.l			#$ffff,d5
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
		move.w			(a0,d3),d4							; sin
		move.l			d4,d5
		move.w			(a1,d3),d6							; cos
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
		divs			#512,d4
		andi.l			#$ffff,d4
		ext.l			d4

		divs			#512,d5
		andi.l			#$ffff,d5
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
		move.l			#300,d3
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

		sub.w			d0,d2								; obliczamy różnicę x -> dx
		bmi			xneg								; jeżeli ujemna to oktant 3,4,5,6

		sub.w			d1,d3								; obliczamy różnicę y calculate dy, dx jest dodatnie więc oktant 1,2,7,8
		bmi			yneg								; jeżeli dy ujemne oktant 7,8
		cmp.w			d3,d2								; porównanie dx i dy - rozróżnienie pomiędzy oktantami 1,2
		bmi			ygtx								; jeżeli y > x oktant 2
		moveq.l			#OCTANT1+LINEMODE,d5						; jeżeli nie to otkant 1
		bra			lineagain
ygtx:
		exg			d2,d3								; x musi być większe od y - zamiana
		moveq.l			#OCTANT2+LINEMODE,d5						; wybór oktant 2
		bra			lineagain
yneg:
		neg.w			d3								; abs(dy)
		cmp.w			d3,d2								; sprawdzamy pomedzy 7 i 8
		bmi			ynygtx								; jeżeli y > x to oktant 7
		moveq.l			#OCTANT8+LINEMODE,d5						; nie - 8
		bra			lineagain
ynygtx:
		exg			d2,d3								; x musi być większe od y - zamiana
		moveq.l			#OCTANT7+LINEMODE,d5						; wybór oktant 7
		bra			lineagain
xneg:
		neg.w			d2								; dx było ujemne więc negujemy, jesteśmy w oktant 3,4,5,6
		sub.w			d1,d3								; obliczamy dy
		bmi			xyneg								; jeżeli ujemne oktant 5,6
		cmp.w			d3,d2								; jeżeli nie to 3,4
		bmi			xnygtx								; jeżeli y > x, oktant 3
		moveq.l			#OCTANT4+LINEMODE,d5						; jeżeli nie to 4
		bra			lineagain
xnygtx:
		exg			d2,d3								; x musi być większe od y - zamiana
		moveq.l			#OCTANT3+LINEMODE,d5						; wybór oktant 3
		bra			lineagain
xyneg:
		neg.w			d3								; y było ujemne więc negujemy, jesteśmy w oktant 5,6
		cmp.w			d3,d2								; jeżeli y > x
		bmi			xynygtx								; oktant 6
		moveq.l			#OCTANT5+LINEMODE,d5						; nie - oktant 5
		bra			lineagain
xynygtx:
		exg			d2,d3								; x musi być większe od y - zamiana
		moveq.l			#OCTANT6+LINEMODE,d5						; wybór oktant 6

lineagain:
	; obliczamy początek (bajt w którym zaczynamy rysować)

		ror.l			#4,d0								; move upper four bits into hi word
		add.w			d0,d0								; mnożenie x 2

		mulu.w			d4,d1								; Obliczamy y1 * WIDTH
		add.l			d1,a0								; ptr += (x1 >> 3)
		add.w			d0,a0								; ptr += y1 * width

		swap			d0								; get the four bits of x1
		or.w			#$BFA,d0							; or with USEA, USEC, USED, F=A+C

		lsl.w			#2,d3								; Y = 4 * Y
		add.w			d2,d2								; X = 2 * X
		move.w			d2,d1								; set up size word
		lsl.w			#5,d1								; shift five left
		add.w			#$42,d1								; and add 1 to height, 2 to width
		
		M_BLITTER_WAIT
		
		move.w			d3,BLTBMOD(a6)							; B mod = 4 * Y
		sub.w			d2,d3
		ext.l			d3
		move.l			d3,BLTAPT(a6)							; A ptr = 4 * Y - 2 * X



		bpl			lineover							; if negative,
		or.w			#SIGNFLAG,d5							; set sign bit in con1
lineover:
		; or.w			#2,d5										; SING bit for filling
		
		move.w			d0,BLTCON0(a6)							; write control registers
		move.w			d5,BLTCON1(a6)
		move.w			d4,BLTCMOD(a6)							; C mod = bitplane width
		move.w			d4,BLTDMOD(a6)							; D mod = bitplane width
		sub.w			d2,d3
		move.w			d3,BLTAMOD(a6)							; A mod = 4 * Y - 4 * X
		move.w			#$8000,BLTADAT(a6)						; A data = 0x8000
		moveq.l			#-1,d5								; Set masks to all ones
		move.l			d5,BLTAFWM(a6)							; we can hit both masks at once
		move.l			a0,BLTCPT(a6)							; Pointer to first pixel to set
		move.l			a0,BLTDPT(a6)
		move.w			d1,BLTSIZE(a6)							; Start blit
		rts											; and return, blit still in progress.
        
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

		clr.w			BLTDMOD(a6)							;destination modulo
		move.l			#$01000000,BLTCON0(a6)						;set operation type in BLTCON0/1
		lsr.l			d1
		move.l			a2,BLTDPTH(a6)							;destination address
		move.w			d1,BLTSIZE(a6)							;blitter operation size

		rts

; =============================================================================
; DANE
; =============================================================================

		CNOP			0,4
		; duże tablice
		include			"sincos.i"

		CNOP			0,4
AdrMulTab
		dc.l			0

		CNOP			0,4
buf_nr		dc.b			0

; 		CNOP			0,4
; tab:		dc.b			$80,$40,$20,$10,$08,$04,$02,$01

		CNOP			0,4
zoomx:		dc.l			0
zoomz:		dc.l			0
zoomx_index:	
		dc.l			0
zoomz_index:	
		dc.l			0
pi:		dc.l			0

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

ax:		dc.l			0
ay:		dc.l			0
az:		dc.l			0

		CNOP			0,4

buf_index_max		EQU	16

buf_index:	dc.l			0

buf_tab:
		dc.l			buf+0*WIDTH/8*HEIGHT
		dc.l			buf+1*WIDTH/8*HEIGHT
		dc.l			buf+2*WIDTH/8*HEIGHT
		dc.l			buf+3*WIDTH/8*HEIGHT

buf_tab_bitplane0:
		dc.l			buf+1*WIDTH/8*HEIGHT
		dc.l			buf+2*WIDTH/8*HEIGHT
		dc.l			buf+3*WIDTH/8*HEIGHT
		dc.l			buf+0*WIDTH/8*HEIGHT

buf_tab_bitplane1:
		dc.l			buf+2*WIDTH/8*HEIGHT
		dc.l			buf+3*WIDTH/8*HEIGHT
		dc.l			buf+0*WIDTH/8*HEIGHT
		dc.l			buf+1*WIDTH/8*HEIGHT

buf_tab_bitplane2:
		dc.l			buf+3*WIDTH/8*HEIGHT
		dc.l			buf+0*WIDTH/8*HEIGHT
		dc.l			buf+1*WIDTH/8*HEIGHT
		dc.l			buf+2*WIDTH/8*HEIGHT


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

; =============================================================================
; CHIP RAM
; =============================================================================

		Section			ChipRAM,Data_c

; -----------------------------------------------------------------------------
; Bitmapa
; -----------------------------------------------------------------------------

		CNOP			0,4
fonts:	
		incbin			"gfx/fonty_dark.raw"

		CNOP			0,4
logo_bitplanes:
		incbin			"gfx/SAMAR_logo_32col.raw"

empty_buf1:
		blk.b			WIDTH/8*HEIGHT,0

		CNOP			0,4
buf:
		blk.b			WIDTH/8*HEIGHT,0
buf2:
		blk.b			WIDTH/8*HEIGHT,0
buf3:
		blk.b			WIDTH/8*HEIGHT,0
buf4:
		blk.b			WIDTH/8*HEIGHT,0

fonty_bitplanes:
		incbin			"gfx/fonty_dark.raw"

	; bufor żeby nie nachodziło na dalsze regiony
empty_buf2:
		blk.b			WIDTH/8*HEIGHT,0

		CNOP			0,4
logo_colors:	
		incbin			"gfx/SAMAR_logo_32col.pal"

		CNOP			0,4
vector_colors:
		dc.w			BACKGROUND_COLOR,$0511,$0633,$0755,$0877,$0999,$0bbb,$0ddd
		incbin			"gfx/fonty_dark.pal"

; -----------------------------------------------------------------------------
; copperlista
; -----------------------------------------------------------------------------

		CNOP			0,4
cl:

cl_logo_bitplanes_nr:
		dc.w			BPLCON0,0
		; dc.w			BPLCON1,0

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

cl_logo_colors:
		dc.w			COLOR00,0
		dc.w			COLOR01,0
		dc.w			COLOR02,0
		dc.w			COLOR03,0
		dc.w			COLOR04,0
		dc.w			COLOR05,0
		dc.w			COLOR06,0
		dc.w			COLOR07,0
		dc.w			COLOR08,0
		dc.w			COLOR09,0
		dc.w			COLOR10,0
		dc.w			COLOR11,0
		dc.w			COLOR12,0
		dc.w			COLOR13,0
		dc.w			COLOR14,0
		dc.w			COLOR15,0
		dc.w			COLOR16,0
		dc.w			COLOR17,0
		dc.w			COLOR18,0
		dc.w			COLOR19,0
		dc.w			COLOR20,0
		dc.w			COLOR21,0
		dc.w			COLOR22,0
		dc.w			COLOR23,0
		dc.w			COLOR24,0
		dc.w			COLOR25,0
		dc.w			COLOR26,0
		dc.w			COLOR27,0
		dc.w			COLOR28,0
		dc.w			COLOR29,0
		dc.w			COLOR30,0
		dc.w			COLOR31,0

		; --- vector ---
		dc.w			RASTER_VECTORS_CL-2,$ff00					; czekam na raster

cl_vector_colors:
		dc.w			COLOR00,0
		dc.w			COLOR01,0
		dc.w			COLOR02,0
		dc.w			COLOR03,0
		dc.w			COLOR04,0
		dc.w			COLOR05,0
		dc.w			COLOR06,0
		dc.w			COLOR07,0
		dc.w			COLOR08,0
		dc.w			COLOR09,0
		dc.w			COLOR10,0
		dc.w			COLOR11,0
		dc.w			COLOR12,0
		dc.w			COLOR13,0
		dc.w			COLOR14,0
		dc.w			COLOR15,0

		dc.w			RASTER_VECTORS_CL,$ff00						; czekam na raster

cl_vector_bitplanes_nr:
		dc.w			BPLCON0,0
; cl_scroll:
; 		dc.w			BPLCON1,$00f0

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

		dc.l			$fffffffe							; tymczasowo

; =============================================================================
; MUZA
; =============================================================================

		CNOP			0,4
		include			"ProTracker_v2.3a.s"

