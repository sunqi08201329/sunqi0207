# Testing command line arguments with ARGV and ARGC using a for loop. 

BEGIN{ 
	for(i=0;i < ARGC;i++)
		printf("argv[%d] is %s\n", i, ARGV[i])
		printf("The number of arguments, ARGC=%d\n", ARGC) 
}
