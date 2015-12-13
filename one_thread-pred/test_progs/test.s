
 	data = 0x1000
	lda     $r2,1
	lda     $r3,data
loop1:	blbs    $r2,loop2
	addq    $r3,0x8,$r3
loop2:	subq    $r2,0x1,$r2
	cmple   $r2,0xf,$r1
	call_pal        0x555
