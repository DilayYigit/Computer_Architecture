.data

menuOption: .asciiz "Enter the option: "
option1: .asciiz "1- Allocate an array with proper size that user enter \n"
option2: .asciiz "2- Display desired elements of the matrix by specifying its row and column member \n"
option3: .asciiz "3- Find the summation of matrix elements row-major (row by row) summation \n"
option4: .asciiz "4- Find the summation of matrix elements column-major (column by column) summation \n"
column: .asciiz "Enter the column index: "
row: .asciiz "Enter the row index: "
rowOrColumn: .asciiz "Enter 1 for row and 2 for column: \n"
matrixSize: .asciiz "Enter the size: "
nl: .asciiz "\n"
sum: .asciiz "Sum: "
space: .asciiz " "
	
	.text
menu:
	li $v0, 4
	la $a0, option1
	syscall
	li $v0, 4
	la $a0, option2
	syscall
	li $v0, 4
	la $a0, option3
	syscall
	li $v0, 4
	la $a0, option4
	syscall
	li $v0, 4
	la $a0, menuOption
	syscall

	li $v0, 5
	syscall
	
	beq $v0, 1, allocateArray
	beq $v0, 2, displayElements
	beq $v0, 3, columnMajor
	beq $v0, 4, rowMajor
	
	li $v0, 10
	syscall 

allocateArray:

	li $v0, 4
	la $a0, matrixSize
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0
	
	mul $a1, $s1, $s1
	mul $a0, $a1, 4
	
	li $v0, 9
	syscall 
	
	move $s0, $v0
	move $s4, $v0
	
	li $t0, 1
	li $t1, 0
	
	loopCreation: 
	beq $t1, $a1, doneCreate
	sw $t0, ($s0)
	add $s0, $s0, 4
	add $t0, $t0, 1
	add $t1, $t1, 1
	j loopCreation
	
	doneCreate:
	add $s0, $s4, 0
	
	j menu
	
	displayElements:
	li $v0, 4
	la $a0, rowOrColumn
	syscall
	li $v0, 5
	syscall
	
	beq $v0, 1, r
	beq $v0, 2, c
	
	j menu
	
	r:
	li $v0, 4
	la $a0, row
	syscall
	li $v0, 5
	syscall
	
	move $t0, $v0
	sub $t0, $t0, 1
	
	mul $t0, $t0, 4
	
	li $t1, 0
	
	loopR: 
	beq $t1, $s1, done_display
	
	mul $t2, $t1, 4
	mul $t2, $t2, $s1
	
	add $t3, $t2, $t0
	
	add $s0, $t3, $s0
	lw $t4, ($s0)
	
	move $a0, $t4
	li $v0, 1   
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
		
	add $s0, $s4, 0
	add $t1, $t1, 1
	j loopR 
	
	c:
	li $v0, 4
	la $a0, column
	syscall
	li $v0, 5
	syscall
	
	move $t0, $v0
	sub $t0, $t0, 1
	mul $t0, $t0, 4
	mul $t0, $s1, $t0
	
	li $t1, 0
	
	loopC: beq $t1, $s1, done_display
	
	mul $t2, $t1, 4
	
	add $t3, $t2, $t0
	
	add $s0, $t3, $s0
	lw $t4, ($s0)
	
	move $a0, $t4
	li $v0, 1  
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
		
	add $s0, $s4, 0
	add $t1, $t1, 1
	j loopC
	
	done_display:
	
	j menu
	
rowMajor:
	li $t0, 0
	outerLoop: 
	
	beq $t0, $s1, outerLoop_done
	
	mul $t1, $t0, 4
	li $t2, 0
	li $t5, 0
	
	innerLoop: beq $t2, $s1, innerLoop_done
	
	mul $t3, $t2, 4
	mul $t3, $t3, $s1
	add $t6, $t1, $t3 
	
	add $s0, $t6, $s0
	lw $t4, ($s0)
	
	add $t5, $t5, $t4
	
	add $s0, $s4, 0
	
	add $t2, $t2, 1
	j innerLoop
	
	innerLoop_done:
	
	li $v0, 4
	la $a0, sum
	syscall
	
	move $a0, $t5
	li $v0, 1   
	syscall
	
	li $v0, 4
	la $a0, nl
	syscall
	
	add $t0, $t0, 1
	j outerLoop
	
	outerLoop_done:
	add $s0, $s4, 0
	j menu
	
columnMajor:
	li $t0, 0	
	loop_ColMajor: beq $t0, $s1, loop_ColMajor_done
	
	li $t3, 0
	li $t1, 0
	
	innerLoop_ColMajor: 
	beq $t1, $s1, innerLoop_ColMajor_done
	lw $t2, ($s0)
	add $t3, $t3, $t2
	add $s0, $s0, 4
	add $t1, $t1, 1
	
	j innerLoop_ColMajor
	
	innerLoop_ColMajor_done:
	li $v0, 4
	la $a0, sum
	syscall
	
	move $a0, $t3
	li $v0, 1  
	syscall
	
	li $v0, 4
	la $a0, nl
	syscall
	
	add $t0, $t0, 1
	j loop_ColMajor
	
	loop_ColMajor_done:
	add $s0, $s4, 0
	j menu
	

