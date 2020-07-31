; =============================================================================
; Makra
; =============================================================================

	MACRO		M_DEBUG_COLOR mycol
	ifd		DEBUG_COLORS
	move.l		#mycol,$dff180
	endif
	ENDM

; =============================================================================

	MACRO		M_BLITTER_WAIT
	ifd		DEBUG_COLORS
	move.l		#0,$dff180
	endif

	tst		DMACONR(a6)
.lp	btst		#DMAB_BLTDONE-8,DMACONR(a6)
	bne		.lp

	ifd		DEBUG_COLORS
	move.l		BACKGROUND_COLOR,$dff180
	endif
	ENDM

