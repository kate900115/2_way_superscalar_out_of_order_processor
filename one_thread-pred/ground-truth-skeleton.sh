for file in `ls test_progs`; do
	file=$(echo $file | cut -d'.' -f1)
	echo "Assembling $file"
	# How do you assemble a testcase?
	./vs-asm < ./test_progs/$file.s > program.mem
	echo "Running $file"
	# How do you run a testcase?
	make > ./output/$file.out
	echo "Saving $file output"
	# How do you want to save the output?
	cp ./program.out ./output/$file.program.out
	cp ./processor.out ./output/$file.pipeline.out
	cp ./writeback.out ./output/$file.writeback.out
	# What files do you want to save?
	if diff ./output/$file.writeback.out ./output_truth/$file.writeback.out
	then
		echo "$file.writeback.out pass!"
	else
		echo "$file.writeback.out fail!"
	fi
#	D=$(diff ./output/$file.program.out ../project3_ori/output/$file.program.out | grep "@@@")
#	if [ "$D" != "" ]
#	then
#		echo "$file.program.out fail!"
#	else
#		echo "$file.program.out pass!"
#	fi
done
