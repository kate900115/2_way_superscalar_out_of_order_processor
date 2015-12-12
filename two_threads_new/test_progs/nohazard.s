




	

	lda	$r1,1
	lda	$r2,2
	lda	$r3,2
	lda	$r4,2
	lda	$r5,2
	lda	$r6,2
	lda	$r7,2
	addq	$r1,$r2,$r3
	addq	$r2,0x8,$r2
	addq	$r1,0x8,$r1
	call_pal        0x555
