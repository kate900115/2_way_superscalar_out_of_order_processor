/*
	TEST PROGRAM #2: compute even numbers that are less than 16


	long output[16];
	
	void
	main(void)
	{
	  long i,j;
	
	  for (i=0,j=0; i < 16; i++)
	    {
	      if ((i & 1) == 0)
	        output[j++] = i;
	    }
	}
*/
	data = 0x1000
	fbeq    $f31,fork
	lda     $r2,0
	lda     $r3,data
loop1:	blbs    $r2,loop2
	stq     $r2,0($r3)
	addq    $r3,0x8,$r3
loop2:	addq    $r2,0x1,$r2
	cmple   $r2,0xf,$r1
	bne     $r1,loop1
	call_pal        0x555
fork:   lda     $r1,0x8		#0	0
        lda     $r2,0x27bb	#4	4
	call_pal        0x555	#152	98
