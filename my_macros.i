; =============================================================================
; Makra
; =============================================================================

	MACRO		M_BLITTER_WAIT
	inline
	tst		DMACONR(a6)
.lp	btst		#DMAB_BLTDONE-8,DMACONR(a6)
	bne		.lp
	einline
	ENDM

