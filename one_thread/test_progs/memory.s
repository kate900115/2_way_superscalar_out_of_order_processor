


       
	lda	$r2,4
	lda	$r1,0X1000
	stq 	$r2,8($r1)
	ldq	$r3,8($r1)
	addq	$r3,$r2,$r4
	ldq	$r5,8($r1)
	addq	$r2,$r5,$r6
	call_pal        0x555
