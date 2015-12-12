


	lda	$r1,1
	lda	$r2,2
	addq	$r1,$r2,$r3
	lda	$r3,2
	lda	$r4,2
	lda	$r5,2
	lda	$r6,2
	lda	$r7,2
        addq	$r3,$r1,$r4
	addq	$r3,$r1,$r5
	addq	$r1,$r2,$r6
	addq	$r1,$r6,$r7
	addq	$r1,$r6,$r8
	call_pal        0x555
