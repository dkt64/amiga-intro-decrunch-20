; =============================================================================
; Makra
; =============================================================================

	MACRO		M_BLITTER_WAIT
	tst		DMACONR(a6)
.lp	btst		#DMAB_BLTDONE-8,DMACONR(a6)
	bne		.lp
	ENDM

	MACRO		M_DEBUG_COLOR mycol
	ifd		DEBUG_COLORS
	move.l		#mycol,$dff180
	endif
	ENDM
