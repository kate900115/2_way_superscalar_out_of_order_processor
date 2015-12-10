/*
	TEST PROGRAM #1: copy memory contents of 16 elements starting at
			 address 0x1000 over to starting address 0x1100. 
	

	long output[16];

	void
	main(void)
	{
	  long i;
	  *a = 0x1000;
          *b = 0x1100;
	 
	  for (i=0; i < 16; i++)
	    {
	      a[i] = i*10; 
	      b[i] = a[i]; 
	    }
	}
*/
	data = 0x1000
	lda	$r5,0
	lda	$r3,data
        lda	$r1,0
        addq	$r1,$r3,$r4
        lda	$r5,0
        lda	$r2,0
        lda	$r2,0
        lda	$r2,0
        lda	$r2,0
	call_pal        0x555

