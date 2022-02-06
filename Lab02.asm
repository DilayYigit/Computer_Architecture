	.text
	
main:
	li $v0, 4
	la $a0, printMain
	syscall
	
	# read array size
	li $v0, 5
	syscall
	mul $s0, $s0, 4 # s0 = array size

	# dynamic array creation
	li $v0, 9 
	move $a0, $s0
	syscall
	
	add $s1, $v0, $zero # s1 = beginning loc of the array
	
	li $s7, 0 # loop counter
	
	jal monitor
	
	li $v0, 4
	la $a0, printSortedArray
	syscall
	
	printLoop:
		beq $s0, $zero, printMedianMax
		
		li $v0, 1
		lw $a0, 0($s1)
		syscall 
		
		addi $s1, $s1, 4
		j printLoop
	
	printMedianMax:
	
	li $v0, 4
	la $a0, printMedian
	syscall
	
	la $a0, ($v0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, printMax
	syscall
	
	la $a0, ($v1)
	li $v0, 1
	syscall

	li $v0, 10
	syscall
monitor:
	li $v0, 4
	la $a0, printMonitor
	syscall
	
	move $t1, $s1
	
	loopInit: 
		beq $s7, $s0, doneInitialize
		
		li $v0, 5
		syscall
		
		sw $v0, 0($t1)
		
		addi $s7, $s7, 1
		addi $t1, $t1, 4
		j loopInit
	
	doneInitialize: 
		
	move $a0, $s1 # a0 = the beginning address of the array
	lw $a1, ($s0) # a1 = array size
	
	j bubbleSort
	
	
bubbleSort:	
	addi $s7, $s7, -1
	beq $s7, $zero,  medianMax
	innerLoop: 
		beq $a1, $zero, bubbleSort
	
		lw $s5, 0($a0)
		lw $s6, 4($a0)
		
		addi $a0, $a0, 4
		subi $a1, $a1, 1
		ble $s5, $s6, innerLoop
		
		addi $a0, $a0, -4
		sw $s6, 0($a0)
		sw $s5, 4($a0)
		addi $a0, $a0, 4
		
		j innerLoop
	
	j bubbleSort
				
medianMax:
	div $s4, $s0, 2
	li $t0, 4
	addi $s4, $s4, 1
	mul $s4, $s4, $t0 # median
	mul $s3, $s0, $t0 # max
	
	lw $v0, ($s4)
	lw $v1, ($s3)
	
	jr $ra
	
	.data
printMain:
	.asciiz "Enter the array size: \n"
printMonitor:
	.asciiz "Enter array inputs: \n"
printSortedArray: 
	.asciiz "After Bubble Sort: \n"
printMedian: 
	.asciiz "Median: \n"
printMax: 
	.asciiz "Max: \n"
		 
