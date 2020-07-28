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

		INCLUDE			"my_macros.i"

CIAAPRA		EQU	$bfe001

AllocMem	EQU	-198
OpenLibrary	EQU	-552
LoadView	EQU	-222
WaitTOF		EQU	-270
Forbid		EQU	-132

XSTRT		EQU	129
XSTOP		EQU	129+320
YSTRT		EQU	44
YSTOP		EQU	44+256
HSTRT		EQU	129
WIDTH		EQU	320
HEIGHT		EQU	256
RES		EQU	8													;8=lores, 4=hires

LINE_WIDTH	EQU	WIDTH/8

RASTER_VECTORS	EQU	$6f
RASTER_SCROLL	EQU	$ff
	
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

		move.w			#$0000,BPLCON0(a6)									; ilość bitplanów
		move.w			#$0000,BPLCON1(a6)									; poziomy skrol = 0
		move.w			#$0000,BPL1MOD(a6)									; modulo1
		move.w			#$0000,BPL2MOD(a6)									; modulo2
		move.w			#(XSTRT+(YSTRT*256)),DIWSTRT(a6)							; DIWSTRT - górny-lewy róg ekranu (2c81)
		move.w			#((XSTOP-256)+(YSTOP-256)*256),DIWSTOP(a6)						; DIWSTOP - dolny-prawy róg ekranu (c8d1)
		move.w			#(HSTRT/2-RES),DDFSTRT(a6)								; DDFSTRT
		move.w			#((HSTRT/2-RES)+(8*((WIDTH/16)-1))),DDFSTOP(a6)						; DDFSTOP

	; ---------------------------------------------------------------------
        ; DMA i IRQ
	; ---------------------------------------------------------------------

		move.w			#%1000000111000000,DMACON(a6)								; DMA set ON
		move.w			#%0000000000111111,DMACON(a6)								; DMA set OFF
		move.w			#%1100000000000000,INTENA(a6)								; IRQ set ON
		move.w			#%0011111111111111,INTENA(a6)								; IRQ set OFF

	; ---------------------------------------------------------------------
        ; Stworzenie copperlisty
	; ---------------------------------------------------------------------

	; ilość bitplanów

		move.w			#$6000,d0
		move.l			#cl_logo_bitplanes_nr+2,a0
		move.w			d0,(a0)

		move.w			#$3000,d0
		move.l			#cl_vector_bitplanes_nr+2,a0
		move.w			d0,(a0)

		move.w			#$3000,d0
		move.l			#cl_scroll_bitplanes_nr+2,a0
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
	; logo bitplan 5
		move.l			#logo_bitplanes+5*WIDTH/8*HEIGHT,d0
		move.l			#cl_logo_address+2+4*10,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_logo_address+2+4*11,a0
		move.w			d0,(a0)

	; scroll bitplan 0
		move.l			#logo_bitplanes+0*WIDTH/8*HEIGHT+RASTER_SCROLL*WIDTH/8*HEIGHT,d0
		move.l			#cl_scroll_address+2+4*00,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_scroll_address+2+4*01,a0
		move.w			d0,(a0)

	; scroll bitplan 1
		move.l			#logo_bitplanes+0*WIDTH/8*HEIGHT+RASTER_SCROLL*WIDTH/8*HEIGHT,d0
		move.l			#cl_scroll_address+2+4*02,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_scroll_address+2+4*03,a0
		move.w			d0,(a0)

	; scroll bitplan 2
		move.l			#logo_bitplanes+0*WIDTH/8*HEIGHT+RASTER_SCROLL*WIDTH/8*HEIGHT,d0
		move.l			#cl_scroll_address+2+4*04,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_scroll_address+2+4*05,a0
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
	
		move.w			scroll_colors+2*00,d0
		move.l			#cl_scroll_colors+2+4*00,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*01,d0
		move.l			#cl_scroll_colors+2+4*01,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*02,d0
		move.l			#cl_scroll_colors+2+4*02,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*03,d0
		move.l			#cl_scroll_colors+2+4*03,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*04,d0
		move.l			#cl_scroll_colors+2+4*04,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*05,d0
		move.l			#cl_scroll_colors+2+4*05,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*06,d0
		move.l			#cl_scroll_colors+2+4*06,a0
		move.w			d0,(a0)

		move.w			scroll_colors+2*07,d0
		move.l			#cl_scroll_colors+2+4*07,a0
		move.w			d0,(a0)

	; =====================================================================
	; main loop
	; =====================================================================

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
	; wybór bufora
	; ---------------------------------------------------------------------

	; w zależności od bufora
		btst			#1,buf_nr
		beq			copper_buf2

	; bitplan 0
		move.l			#buf1+0*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*00,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*01,a0
		move.w			d0,(a0)
	; bitplan 1
		move.l			#buf1+1*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*02,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*03,a0
		move.w			d0,(a0)
	; bitplan 2
		move.l			#buf1+2*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*04,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*05,a0
		move.w			d0,(a0)

		jmp			copper_buf0

copper_buf2:

	; bitplan 0
		move.l			#buf2+0*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*00,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*01,a0
		move.w			d0,(a0)
	; bitplan 1
		move.l			#buf2+1*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*02,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*03,a0
		move.w			d0,(a0)
	; bitplan 2
		move.l			#buf2+2*WIDTH/8*HEIGHT+RASTER_VECTORS*WIDTH/8*HEIGHT,d0
		move.l			#cl_vector_address+2+4*04,a0
		move.w			d0,(a0)
		swap			d0
		move.l			#cl_vector_address+2+4*05,a0
		move.w			d0,(a0)

copper_buf0:

	; ---------------------------------------------------------------------
	; uruchomienie copperlisty
	; ---------------------------------------------------------------------

		move.l			#cl,COP1LCH(a6)

	; ---------------------------------------------------------------------
	; odtworzenie muzyki
	; ---------------------------------------------------------------------

		jsr			mt_music
		lea			CUSTOM,a6										; przywracamy CUSTOM

	; ---------------------------------------------------------------------
	; FX
	; ---------------------------------------------------------------------

		jsr			my_fx
		bchg			#1,buf_nr

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
		jsr			-222(a6)										; LoadView
		jsr			-270(a6)										; WaitTOF
		jsr			-270(a6)										; WaitTOF
		move.l			$4,a6
		jsr			-138(a6)										; Permit
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

		clr.l			d1
		move.l			#zoomx_tab,a0
		move.l			zoomx_index,d0
		move.w			(a0,d0),d1
		ext.l			d1
		move.l			d1,zoomx
		addi.l			#2,d0
		andi.l			#1023,d0
		move.l			d0,zoomx_index

		addi.l			#4,ax
		addi.l			#3,ay
		addi.l			#1,az

		andi.l			#1023,ax
		andi.l			#1023,ay
		andi.l			#1023,az

		btst			#1,buf_nr
		beq			my_fx_buf1
		jmp			my_fx_buf2

; =============================================================================
; Efekt bufor 1
; =============================================================================

my_fx_buf1:

		move.l			#buf1,a1
		move.l			#WIDTH/8*HEIGHT,d1
		jsr			clear

		M_BLITTER_WAIT
		
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

		move.l			pi,a1
		move.l			#pxa,a2
		move.l			d0,(a2,a1)
		move.l			#pya,a3
		move.l			d1,(a3,a1)
	
		addi.l			#4,pi
		cmpi.l			#4*12,pi
		bne			lp1

waitb2:		btst			#6,DMACONR
		bne.s			waitb2

		move.l			#0,pi
lp12:		move.l			pi,a1
		move.l			#pxa,a2
		move.l			(a2,a1),d0
		move.l			#pya,a3
		move.l			(a3,a1),d1

		; sprawdzenie czy punkt poza ekranem i dodanie do środka
		cmpi.l			#-128,d1
		ble			poza1
		cmpi.l			#128,d1
		bge			poza1

		addi.l			#160,d0
		; add.l		zoomx,d0
		bmi			poza1
		cmpi.l			#320,d0
		bge			poza1

		addi.l			#128,d1
		move.l			#buf1,a0

		move.l			d0,(a2,a1)
		move.l			d1,(a3,a1)

		; jsr		plot
		bra			dal1
poza1:
		move.l			#0,(a2,a1)
		move.l			#0,(a3,a1)
dal1:
		addi.l			#4,pi
		cmpi.l			#4*12,pi
		bne			lp12

		move.l			#buf1,a2
		jsr			draw_lines

		; kopiuj i wypełnij
		move.l			#buf1,a2
		move.l			#bitplane_vector1,a3
		jsr			copy_and_fill

		rts

; =============================================================================
; Efekt bufor 2
; =============================================================================

my_fx_buf2:

		move.l			#buf2,a1
		move.l			#320/8*256,d1
		jsr			clear

		M_BLITTER_WAIT

		move.l			#0,pi
lp2:		move.l			pi,a1
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

		move.l			pi,a1
		move.l			#pxa,a2
		move.l			d0,(a2,a1)
		move.l			#pya,a3
		move.l			d1,(a3,a1)

		addi.l			#4,pi
		cmpi.l			#4*12,pi
		bne			lp2

waitb3:		btst			#6,DMACONR
		bne.s			waitb3

		move.l			#0,pi
lp22:		move.l			pi,a1
		move.l			#pxa,a2
		move.l			(a2,a1),d0
		move.l			#pya,a3
		move.l			(a3,a1),d1

		; sprawdzenie czy punkt poza ekranem i dodanie do środka

		cmpi.l			#-128,d1
		ble			poza2
		cmpi.l			#128,d1
		bge			poza2

		addi.l			#160,d0
		; add.l		zoomx,d0
		bmi			poza2
		cmpi.l			#320,d0
		bge			poza2

		addi.l			#128,d1
		move.l			#buf2,a0

		move.l			d0,(a2,a1)
		move.l			d1,(a3,a1)

		; jsr		plot
		bra			dal2
poza2:	
		move.l			#0,(a2,a1)
		move.l			#0,(a3,a1)
dal2:

		addi.l			#4,pi
		cmpi.l			#4*12,pi
		bne			lp22

		move.l			#buf2,a2
		jsr			draw_lines

		; kopiuj i wypełnij
		move.l			#buf2,a2
		move.l			#bitplane_vector2,a3
		jsr			copy_and_fill

		rts

; =============================================================================
; Draw lines
; Input:  d0=x1 d1=y1 d2=x2 d3=y2 d4=width a0=aptr
; =============================================================================

draw_lines:

		move.l			pxa+00*4,d0
		beq			ln1
		move.l			pya+00*4,d1
		move.l			pxa+01*4,d2
		beq			ln1
		move.l			pya+01*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line
ln1:

		move.l			pxa+01*4,d0
		beq			ln2
		move.l			pya+01*4,d1
		move.l			pxa+03*4,d2
		beq			ln2
		move.l			pya+03*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line
ln2:

		move.l			pxa+03*4,d0
		beq			ln3
		move.l			pya+03*4,d1
		move.l			pxa+02*4,d2
		beq			ln3
		move.l			pya+02*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line
ln3:

		move.l			pxa+02*4,d0
		beq			ln4
		move.l			pya+02*4,d1
		move.l			pxa+00*4,d2
		beq			ln4
		move.l			pya+00*4,d3
		move.l			#LINE_WIDTH,d4
		jsr			line
ln4:

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
		move.w			(a0,d3),d4										; sin
		move.l			d4,d5
		move.w			(a1,d3),d6										; cos
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
		move.w			(a0,d3),d4										; sin
		move.l			d4,d5
		move.w			(a1,d3),d6										; cos
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
		move.w			(a0,d3),d4										; sin
		move.l			d4,d5
		move.w			(a1,d3),d6										; cos
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

plot:

		move.l			#tab,a1
	
		move.l			d0,d2
		andi.l			#7,d2

		lsr.l			#3,d0
		mulu			#WIDTH/8,d1
		add.l			d1,d0

		move.b			(a1,d2),d4
		move.b			(a0,d0),d5
		or.b			d4,d5
		move.b			d5,(a0,d0)

		rts

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

		sub.w			d0,d2											; calculate dx
		bmi			xneg											; if negative, octant is one of [3,4,5,6]
		sub.w			d1,d3											; calculate dy   ''   is one of [1,2,7,8]
		bmi			yneg											; if negative, octant is one of [7,8]
		cmp.w			d3,d2											; cmp |dx|,|dy|  ''   is one of [1,2]
		bmi			ygtx											; if y>x, octant is 2
		moveq.l			#OCTANT1+LINEMODE,d5									; otherwise octant is 1
		bra			lineagain										; go to the common section
ygtx:
		exg			d2,d3											; X must be greater than Y
		moveq.l			#OCTANT2+LINEMODE,d5									; we are in octant 2
		bra			lineagain										; and common again.
yneg:
		neg.w			d3											; calculate abs(dy)
		cmp.w			d3,d2											; cmp |dx|,|dy|, octant is [7,8]
		bmi			ynygtx											; if y>x, octant is 7
		moveq.l			#OCTANT8+LINEMODE,d5									; otherwise octant is 8
		bra			lineagain
ynygtx:
		exg			d2,d3											; X must be greater than Y
		moveq.l			#OCTANT7+LINEMODE,d5									; we are in octant 7
		bra			lineagain
xneg:
		neg.w			d2											; dx was negative! octant is [3,4,5,6]
		sub.w			d1,d3											; we calculate dy
		bmi			xyneg											; if negative, octant is one of [5,6]
		cmp.w			d3,d2											; otherwise it's one of [3,4]
		bmi			xnygtx											; if y>x, octant is 3
		moveq.l			#OCTANT4+LINEMODE,d5									; otherwise it's 4
		bra			lineagain
xnygtx:
		exg			d2,d3											; X must be greater than Y
		moveq.l			#OCTANT3+LINEMODE,d5									; we are in octant 3
		bra			lineagain
xyneg:
		neg.w			d3											; y was negative, in one of [5,6]
		cmp.w			d3,d2											; is y>x?
		bmi			xynygtx											; if so, octant is 6
		moveq.l			#OCTANT5+LINEMODE,d5									; otherwise, octant is 5
		bra			lineagain
xynygtx:
		exg			d2,d3											; X must be greater than Y
		moveq.l			#OCTANT6+LINEMODE,d5									; we are in octant 6
lineagain:
		mulu.w			d4,d1											; Calculate y1 * width
		ror.l			#4,d0											; move upper four bits into hi word
		add.w			d0,d0											; multiply by 2
		add.l			d1,a0											; ptr += (x1 >> 3)
		add.w			d0,a0											; ptr += y1 * width
		swap			d0											; get the four bits of x1
		or.w			#$BFA,d0										; or with USEA, USEC, USED, F=A+C
		lsl.w			#2,d3											; Y = 4 * Y
		add.w			d2,d2											; X = 2 * X
		move.w			d2,d1											; set up size word
		lsl.w			#5,d1											; shift five left
		add.w			#$42,d1											; and add 1 to height, 2 to width
		
		M_BLITTER_WAIT
		
		move.w			d3,BLTBMOD(a6)										; B mod = 4 * Y
		sub.w			d2,d3
		ext.l			d3
		move.l			d3,BLTAPT(a6)										; A ptr = 4 * Y - 2 * X
		bpl			lineover										; if negative,
		or.w			#SIGNFLAG,d5										; set sign bit in con1
lineover:
		or.w			#2,d5											; SING bit for filling
		
		move.w			d0,BLTCON0(a6)										; write control registers
		move.w			d5,BLTCON1(a6)
		move.w			d4,BLTCMOD(a6)										; C mod = bitplane width
		move.w			d4,BLTDMOD(a6)										; D mod = bitplane width
		sub.w			d2,d3
		move.w			d3,BLTAMOD(a6)										; A mod = 4 * Y - 4 * X
		move.w			#$8000,BLTADAT(a6)									; A data = 0x8000
		moveq.l			#-1,d5											; Set masks to all ones
		move.l			d5,BLTAFWM(a6)										; we can hit both masks at once
		move.l			a0,BLTCPT(a6)										; Pointer to first pixel to set
		move.l			a0,BLTDPT(a6)
		move.w			d1,BLTSIZE(a6)										; Start blit
		rts														; and return, blit still in progress.
        
; =============================================================================
; Copy and fill
; a2 - bufor z linią
; a3 - bufor docelowy
; =============================================================================

copy_and_fill:

		M_BLITTER_WAIT

		add.l			#WIDTH/8*HEIGHT,a2
		add.l			#WIDTH/8*HEIGHT,a3
		move.l			a2,BLTAPT(a6)
		move.l			a3,BLTDPT(a6)
		move.l			#WIDTH/8,BLTAMOD(a6)
		move.l			#WIDTH/8,BLTDMOD(a6)
		move.l			#$ffffffff,BLTAFWM(a6)
		move.w			#$09f0,BLTCON0(a6)
		move.w			#FILL_XOR+BLITREVERSE,BLTCON1(a6)
		move.l			#HEIGHT,d0
		lsl.l			#5,d0
		or.l			#WIDTH/8,d0
		move.w			d0,BLTSIZE(a6)

		rts

; =============================================================================
; Czyszczenie bitplanu
; =============================================================================

clear:
		M_BLITTER_WAIT

		clr.w			BLTDMOD(a6)										;destination modulo
		move.l			#$01000000,BLTCON0(a6)									;set operation type in BLTCON0/1
		lsr.l			d1
		move.l			a1,BLTDPTH(a6)										;destination address
		move.w			d1,BLTSIZE(a6)										;blitter operation size

		rts

; =============================================================================
; DANE
; =============================================================================

		CNOP			0,4
AdrMulTab
		dc.l			0
		CNOP			0,4
buf_nr		dc.b			0
		CNOP			0,4
tab:		dc.b			$80,$40,$20,$10,$08,$04,$02,$01

		CNOP			0,4
zoomx:		dc.l			0
zoomz:		dc.l			0
zoomx_index:	
		dc.l			0
zoomz_index:	
		dc.l			0
pi:		dc.l			0

px:
		dc.l			-200,200
		dc.l			-200,200
		dc.l			-200,200
		dc.l			-200,200
		dc.l			-200,200
		dc.l			0,0
py:
		dc.l			200,200
		dc.l			-200,-200
		dc.l			200,200
		dc.l			-200,-200
		dc.l			0,0
		dc.l			-200,200
pz:
		dc.l			-200,-200
		dc.l			-200,-200
		dc.l			200,200
		dc.l			200,200
		dc.l			0,0
		dc.l			0,0

pxa:
		blk.l			12,0
pya:
		blk.l			12,0

ax:		dc.l			0
ay:		dc.l			0
az:		dc.l			0

sinus:	
		dc.w			0,2,4,6,8,10,11,13,15,17,19,21,23,24,26,28
		dc.w			30,32,34,35,37,39,41,43,44,46,48,50,52,54,55,57
		dc.w			59,61,63,64,66,68,70,72,73,75,77,79,80,82,84,86
		dc.w			88,89,91,93,95,96,98,100,102,103,105,107,108,110,112,114
		dc.w			115,117,119,120,122,124,125,127,129,130,132,134,135,137,139,140
		dc.w			142,143,145,147,148,150,151,153,155,156,158,159,161,162,164,166
		dc.w			167,169,170,172,173,175,176,178,179,181,182,183,185,186,188,189
		dc.w			191,192,194,195,196,198,199,200,202,203,205,206,207,209,210,211
		dc.w			212,214,215,216,218,219,220,221,223,224,225,226,227,229,230,231
		dc.w			232,233,234,236,237,238,239,240,241,242,243,244,245,247,248,249
		dc.w			250,251,252,253,254,255,256,256,257,258,259,260,261,262,263,264
		dc.w			265,266,266,267,268,269,270,270,271,272,273,274,274,275,276,276
		dc.w			277,278,279,279,280,281,281,282,282,283,284,284,285,285,286,286
		dc.w			287,287,288,288,289,289,290,290,291,291,292,292,292,293,293,294
		dc.w			294,294,295,295,295,296,296,296,296,297,297,297,297,298,298,298
		dc.w			298,298,299,299,299,299,299,299,299,299,299,299,299,299,299,299
cosinus:
		dc.w			299,299,299,299,299,299,299,299,299,299,299,299,299,298,298,298
		dc.w			298,298,298,297,297,297,297,296,296,296,295,295,295,295,294,294
		dc.w			293,293,293,292,292,291,291,291,290,290,289,289,288,288,287,287
		dc.w			286,286,285,284,284,283,283,282,281,281,280,280,279,278,277,277
		dc.w			276,275,275,274,273,272,272,271,270,269,268,268,267,266,265,264
		dc.w			263,262,262,261,260,259,258,257,256,255,254,253,252,251,250,249
		dc.w			248,247,246,245,244,243,242,241,240,238,237,236,235,234,233,232
		dc.w			230,229,228,227,226,224,223,222,221,219,218,217,216,214,213,212
		dc.w			210,209,208,207,205,204,202,201,200,198,197,196,194,193,191,190
		dc.w			189,187,186,184,183,181,180,178,177,175,174,172,171,169,168,166
		dc.w			165,163,162,160,159,157,155,154,152,151,149,148,146,144,143,141
		dc.w			139,138,136,135,133,131,130,128,126,125,123,121,119,118,116,114
		dc.w			113,111,109,108,106,104,102,101,99,97,95,94,92,90,88,87
		dc.w			85,83,81,80,78,76,74,72,71,69,67,65,63,62,60,58
		dc.w			56,54,53,51,49,47,45,44,42,40,38,36,34,33,31,29
		dc.w			27,25,23,22,20,18,16,14,12,11,9,7,5,3,1,0
		dc.w			0,-1,-3,-5,-7,-9,-11,-12,-14,-16,-18,-20,-22,-23,-25,-27
		dc.w			-29,-31,-33,-34,-36,-38,-40,-42,-44,-45,-47,-49,-51,-53,-54,-56
		dc.w			-58,-60,-62,-63,-65,-67,-69,-71,-72,-74,-76,-78,-80,-81,-83,-85
		dc.w			-87,-88,-90,-92,-94,-95,-97,-99,-101,-102,-104,-106,-108,-109,-111,-113
		dc.w			-114,-116,-118,-119,-121,-123,-125,-126,-128,-130,-131,-133,-135,-136,-138,-139
		dc.w			-141,-143,-144,-146,-148,-149,-151,-152,-154,-155,-157,-159,-160,-162,-163,-165
		dc.w			-166,-168,-169,-171,-172,-174,-175,-177,-178,-180,-181,-183,-184,-186,-187,-189
		dc.w			-190,-191,-193,-194,-196,-197,-198,-200,-201,-202,-204,-205,-207,-208,-209,-210
		dc.w			-212,-213,-214,-216,-217,-218,-219,-221,-222,-223,-224,-226,-227,-228,-229,-230
		dc.w			-232,-233,-234,-235,-236,-237,-238,-240,-241,-242,-243,-244,-245,-246,-247,-248
		dc.w			-249,-250,-251,-252,-253,-254,-255,-256,-257,-258,-259,-260,-261,-262,-262,-263
		dc.w			-264,-265,-266,-267,-268,-268,-269,-270,-271,-272,-272,-273,-274,-275,-275,-276
		dc.w			-277,-277,-278,-279,-280,-280,-281,-281,-282,-283,-283,-284,-284,-285,-286,-286
		dc.w			-287,-287,-288,-288,-289,-289,-290,-290,-291,-291,-291,-292,-292,-293,-293,-293
		dc.w			-294,-294,-295,-295,-295,-295,-296,-296,-296,-297,-297,-297,-297,-298,-298,-298
		dc.w			-298,-298,-298,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299
		dc.w			-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-299,-298,-298
		dc.w			-298,-298,-298,-297,-297,-297,-297,-296,-296,-296,-296,-295,-295,-295,-294,-294
		dc.w			-294,-293,-293,-292,-292,-292,-291,-291,-290,-290,-289,-289,-288,-288,-287,-287
		dc.w			-286,-286,-285,-285,-284,-284,-283,-282,-282,-281,-281,-280,-279,-279,-278,-277
		dc.w			-276,-276,-275,-274,-274,-273,-272,-271,-270,-270,-269,-268,-267,-266,-266,-265
		dc.w			-264,-263,-262,-261,-260,-259,-258,-257,-256,-256,-255,-254,-253,-252,-251,-250
		dc.w			-249,-248,-247,-245,-244,-243,-242,-241,-240,-239,-238,-237,-236,-234,-233,-232
		dc.w			-231,-230,-229,-227,-226,-225,-224,-223,-221,-220,-219,-218,-216,-215,-214,-212
		dc.w			-211,-210,-209,-207,-206,-205,-203,-202,-200,-199,-198,-196,-195,-194,-192,-191
		dc.w			-189,-188,-186,-185,-183,-182,-181,-179,-178,-176,-175,-173,-172,-170,-169,-167
		dc.w			-166,-164,-162,-161,-159,-158,-156,-155,-153,-151,-150,-148,-147,-145,-143,-142
		dc.w			-140,-139,-137,-135,-134,-132,-130,-129,-127,-125,-124,-122,-120,-119,-117,-115
		dc.w			-114,-112,-110,-108,-107,-105,-103,-102,-100,-98,-96,-95,-93,-91,-89,-88
		dc.w			-86,-84,-82,-80,-79,-77,-75,-73,-72,-70,-68,-66,-64,-63,-61,-59
		dc.w			-57,-55,-54,-52,-50,-48,-46,-44,-43,-41,-39,-37,-35,-34,-32,-30
		dc.w			-28,-26,-24,-23,-21,-19,-17,-15,-13,-11,-10,-8,-6,-4,-2,0
		dc.w			0,2,4,6,8,10,11,13,15,17,19,21,23,24,26,28
		dc.w			30,32,34,35,37,39,41,43,44,46,48,50,52,54,55,57
		dc.w			59,61,63,64,66,68,70,72,73,75,77,79,80,82,84,86
		dc.w			88,89,91,93,95,96,98,100,102,103,105,107,108,110,112,114
		dc.w			115,117,119,120,122,124,125,127,129,130,132,134,135,137,139,140
		dc.w			142,143,145,147,148,150,151,153,155,156,158,159,161,162,164,166
		dc.w			167,169,170,172,173,175,176,178,179,181,182,183,185,186,188,189
		dc.w			191,192,194,195,196,198,199,200,202,203,205,206,207,209,210,211
		dc.w			212,214,215,216,218,219,220,221,223,224,225,226,227,229,230,231
		dc.w			232,233,234,236,237,238,239,240,241,242,243,244,245,247,248,249
		dc.w			250,251,252,253,254,255,256,256,257,258,259,260,261,262,263,264
		dc.w			265,266,266,267,268,269,270,270,271,272,273,274,274,275,276,276
		dc.w			277,278,279,279,280,281,281,282,282,283,284,284,285,285,286,286
		dc.w			287,287,288,288,289,289,290,290,291,291,292,292,292,293,293,294
		dc.w			294,294,295,295,295,296,296,296,296,297,297,297,297,298,298,298
		dc.w			298,298,299,299,299,299,299,299,299,299,299,299,299,299,299,299

zoomx_tab:
		dc.w			0,1,3,5,7,9,11,12,14,16,18,20,22,23,25,27
		dc.w			29,31,32,34,36,38,40,41,43,45,47,48,50,52,54,55
		dc.w			57,59,60,62,64,65,67,69,70,72,74,75,77,78,80,81
		dc.w			83,85,86,88,89,90,92,93,95,96,98,99,100,102,103,104
		dc.w			106,107,108,110,111,112,113,114,116,117,118,119,120,121,122,123
		dc.w			124,125,126,127,128,129,130,131,132,133,134,134,135,136,137,138
		dc.w			138,139,140,140,141,141,142,143,143,144,144,145,145,146,146,146
		dc.w			147,147,147,148,148,148,148,149,149,149,149,149,149,149,149,149
		dc.w			149,149,149,149,149,149,149,149,149,149,148,148,148,148,147,147
		dc.w			147,146,146,145,145,144,144,143,143,142,142,141,141,140,139,139
		dc.w			138,137,136,136,135,134,133,132,132,131,130,129,128,127,126,125
		dc.w			124,123,122,121,120,118,117,116,115,114,113,111,110,109,108,106
		dc.w			105,104,102,101,100,98,97,96,94,93,91,90,88,87,85,84
		dc.w			82,81,79,78,76,74,73,71,70,68,66,65,63,61,60,58
		dc.w			56,54,53,51,49,48,46,44,42,40,39,37,35,33,32,30
		dc.w			28,26,24,22,21,19,17,15,13,11,10,8,6,4,2,0
		dc.w			0,-2,-4,-6,-8,-10,-11,-13,-15,-17,-19,-21,-22,-24,-26,-28
		dc.w			-30,-32,-33,-35,-37,-39,-40,-42,-44,-46,-48,-49,-51,-53,-54,-56
		dc.w			-58,-60,-61,-63,-65,-66,-68,-70,-71,-73,-74,-76,-78,-79,-81,-82
		dc.w			-84,-85,-87,-88,-90,-91,-93,-94,-96,-97,-98,-100,-101,-102,-104,-105
		dc.w			-106,-108,-109,-110,-111,-113,-114,-115,-116,-117,-118,-120,-121,-122,-123,-124
		dc.w			-125,-126,-127,-128,-129,-130,-131,-132,-132,-133,-134,-135,-136,-136,-137,-138
		dc.w			-139,-139,-140,-141,-141,-142,-142,-143,-143,-144,-144,-145,-145,-146,-146,-147
		dc.w			-147,-147,-148,-148,-148,-148,-149,-149,-149,-149,-149,-149,-149,-149,-149,-149
		dc.w			-149,-149,-149,-149,-149,-149,-149,-149,-149,-148,-148,-148,-148,-147,-147,-147
		dc.w			-146,-146,-146,-145,-145,-144,-144,-143,-143,-142,-141,-141,-140,-140,-139,-138
		dc.w			-138,-137,-136,-135,-134,-134,-133,-132,-131,-130,-129,-128,-127,-126,-125,-124
		dc.w			-123,-122,-121,-120,-119,-118,-117,-116,-114,-113,-112,-111,-110,-108,-107,-106
		dc.w			-104,-103,-102,-100,-99,-98,-96,-95,-93,-92,-90,-89,-88,-86,-85,-83
		dc.w			-81,-80,-78,-77,-75,-74,-72,-70,-69,-67,-65,-64,-62,-60,-59,-57
		dc.w			-55,-54,-52,-50,-48,-47,-45,-43,-41,-40,-38,-36,-34,-32,-31,-29
		dc.w			-27,-25,-23,-22,-20,-18,-16,-14,-12,-11,-9,-7,-5,-3,-1,0

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
logo_bitplanes:	
		incbin			"gfx/logo.raw"

		CNOP			0,4
bitplane_vector1:
		blk.b			WIDTH/8*HEIGHT,0

		CNOP			0,4
bitplane_vector2:
		blk.b			WIDTH/8*HEIGHT,0

		CNOP			0,4
buf1:
		blk.b			3*320*256/8,0

		CNOP			0,4
buf2:
		blk.b			3*320*256/8,0

		CNOP			0,4
logo_colors:	
		incbin			"gfx/logo.pal"

		CNOP			0,4
vector_colors:
		incbin			"gfx/logo.pal"
		; dc.w			$0000,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff

		CNOP			0,4
scroll_colors:
		incbin			"gfx/logo.pal"
		; dc.w			$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff

; -----------------------------------------------------------------------------
; copperlista
; -----------------------------------------------------------------------------

		CNOP			0,4
cl:

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

cl_logo_bitplanes_nr:
		dc.w			BPLCON0,0

		; vector

		dc.w			RASTER_VECTORS << 8 + 1,$ff00								; czekam na raster

cl_vector_address:
		dc.w			BPL1PTL,0
		dc.w			BPL1PTH,0
		dc.w			BPL2PTL,0
		dc.w			BPL2PTH,0
		dc.w			BPL3PTL,0
		dc.w			BPL3PTH,0

cl_vector_colors:
		dc.w			COLOR00,0
		dc.w			COLOR01,0
		dc.w			COLOR02,0
		dc.w			COLOR03,0
		dc.w			COLOR04,0
		dc.w			COLOR05,0
		dc.w			COLOR06,0
		dc.w			COLOR07,0

cl_vector_bitplanes_nr:
		dc.w			BPLCON0,0

		; scroll

		dc.w			RASTER_SCROLL << 8 + 1,$ff00								; czekam na raster

cl_scroll_address:
		dc.w			BPL1PTL,0
		dc.w			BPL1PTH,0
		dc.w			BPL2PTL,0
		dc.w			BPL2PTH,0
		dc.w			BPL3PTL,0
		dc.w			BPL3PTH,0

cl_scroll_colors:
		dc.w			COLOR00,0
		dc.w			COLOR01,0
		dc.w			COLOR02,0
		dc.w			COLOR03,0
		dc.w			COLOR04,0
		dc.w			COLOR05,0
		dc.w			COLOR06,0
		dc.w			COLOR07,0

cl_scroll_bitplanes_nr:
		dc.w			BPLCON0,0

		dc.l			$fffffffe

; =============================================================================
; MUZA
; =============================================================================
		CNOP			0,4
		include			"fasttracker_player.i"

