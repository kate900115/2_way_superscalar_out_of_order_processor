


        
	lda	$r2,2
	lda	$r1,0x1000
	stq 	$r2,0($r1)
	ldq	$r3,0($r1)
	addq	$r3,0x1,$r4
	lda	$r7,2
	ldq	$r5,0($r1)
	addq	$r7,$r5,$r6
	call_pal        0x555
