	.data
rTypeText:
	.asciiz "R-type: "
iTypeText:
	.asciiz "I-type: "
	
newLine: 
	.asciiz "\n"
	
	.text
	
begin:
	la $a0, begin
	la $a1, end
	jal instructionCount
	move $s0, $v0
	move $s1, $v1
	
	addi $t0, $t0, 1
	
	li $v0, 4
	la $a0, rTypeText
	syscall
	
	move $a0, $s0
	l˝ $v0, 1
	syscall
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	li $v0, 4
	la $a0, iTypeText
	syscall
	
	move $a0, $s1
	l˝ $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
instructionCount:

	addi $sp, $sp, -24
	sw $s0, 20($sp)
	sw $s1, 16($sp) 
	sw $s2, 12($sp) 
	sw $s3, 8($sp) 
	sw $s4, 4($sp) 
	sw $ra, 0($sp)

	move $s0, $a0
	move $s1, $a1
	li $s3, 0 # R type
	li $s4, 0 # I type
	
	
loop:
	bgt $s0, $s1, end
	
	lw $s2, 0($s0)
	srl $s2, $s2, 26 # opcode
	
	beq $s2, $zero, addR
	beq $s2, 2, jump
	beq $s2, 3, jump
	jal addI
	addi $s0, $s0, 4
	j loop
	
addR:
	addi $s3, $s3, 1
	addi $s0, $s0, 4
	j loop
	
jump: 
	addi $s0, $s0, 4
	j loop
	
addI:
	addi $s4, $s4, 1
	jr $ra
	
end:	
	move $v0, $s3
	move $v1, $s4
	lw	$ra, 0($sp)
	lw 	$s4, 4($sp)
	lw	$s3, 8($sp)
	lw	$s2, 12($sp)
	lw	$s1, 16($sp)
	lw	$s0, 20($sp)
	addi	$sp, $sp, 24
	jr	$ra

#---------------------------------------------
	.data
print1:
	.asciiz "Enter num1: "
print2: 
	.asciiz "Enter num2: "
print3:
	.asciiz "Result: "

	.text
	
division:
li $s2, 0
	li $v0, 4
	la $a0, print1
	syscall
	
	li $v0, 5
	syscall
	
	move $s0, $v0
	
	li $v0, 4
	la $a0, print2
	syscall
	
	li $v0, 5
	syscall
	
	move $s1, $v0
	
	beq $s0, $zero, end
	beq $s1, $zero, end
	
loop:
	blt $s0, $s1, printResult
	addi $s2, $s2, 1
	sub $s3, $s0, $s1
	move $s0, $s3
	j loop
	
	
printResult:
	li $v0, 4
	la $a0, print3
	syscall
	
	add $a0, $zero, $s2
	li $v0, 1
	syscall
	
	j division
	
end:
	li $v0, 10 
	syscall

	
	
#--------------------------------------------

	.text
# CS224, Program to be used in Lab3
# October 22, 2021

	jal generate
	move $a0, $v0 # points to the header
	
	move $a1, $v0
	jal 	printLinkedList
	jal reversePrint
	
# Stop. 
	li	$v0, 10
	syscall

generate:

	addi $sp, $sp, -24
	sw $s0, 20($sp) # size
	sw $s1, 16($sp) # counter
	sw $s2, 12($sp) # node counter
	sw $s3, 8($sp) # head node
	sw $s4, 4($sp) # data counter
	sw $ra, 0($sp)
	
	li $v0, 4
	la $a0, print1
	syscall
	
	li $v0, 5
	syscall
	
	move $s0, $v0 # s0 = size
	li $s1, 1 # s1 = loop counter
	
	# create head node
	li $v0, 9
	li $a0, 8 # 4 for data, 4 for linker
	syscall
	
	move $s2, $v0 # s2 = points first and last node
	move $s3, $v0 # s3 = points header (do not change)
	
	# sw $v0, 0($s2)
	
	li $v0, 4
	la $a0, print2
	syscall
	
	li $v0, 5
	syscall
	
	move $t0, $v0 
	sw $t0, 4($s2)
	
	# addi $s2, $s2, 8
	
creationLoop:
	
	beq $s1, $s0, doneCreation

	li $v0, 9
	li $a0, 8 # 4 for data, 4 for linker
	syscall
	
	sw $v0, 0($s2) # link pointer
	
	move $s2, $v0 # move pointer to the new node
	
	li $v0, 5
	syscall
	
	move $t0, $v0 # t0 = data value
	
	sw $t0, 4($s2) 
	
	addi $s1, $s1, 1
	j creationLoop
	
doneCreation:	
	sw $zero, 0($s2)
	move $v0, $s3 # v0 = points to the header
	lw $ra, 0($sp)
	lw $s4, 4($sp)
	lw $s3, 8($sp)
	lw $s2, 12($sp)
	lw $s1, 16($sp)
	lw $s0, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra 

#=========================================================
printLinkedList:
# Print linked list nodes in the following format
# --------------------------------------
# Node No: xxxx (dec)
# Address of Current Node: xxxx (hex)
# Address of Next Node: xxxx (hex)
# Data Value of Current Node: xxx (dec)
# --------------------------------------

# Save $s registers used
	addi	$sp, $sp, -20
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	sw	$s3, 4($sp)
	sw	$ra, 0($sp) 	# Save $ra just in case we may want to call a subprogram

# $a0: points to the linked list.
# $s0: Address of current
# s1: Address of next
# $2: Data of current
# $s3: Node counter: 1, 2, ...
	move $s0, $a0	# $s0: points to the current node.
	li   $s3, 0
printNextNode:
	beq	$s0, $zero, printedAll
				# $s0: Address of current node
	lw	$s1, 0($s0)	# $s1: Address of  next node
	lw	$s2, 4($s0)	# $s2: Data of current node
	addi	$s3, $s3, 1
# $s0: address of current node: print in hex.
# $s1: address of next node: print in hex.
# $s2: data field value of current node: print in decimal.
	la	$a0, line
	li	$v0, 4
	syscall		# Print line seperator
	

	la	$a0, addressOfCurrentNodeLabel
	li	$v0, 4
	syscall
	
	move	$a0, $s0	# $s0: Address of current node
	li	$v0, 34
	syscall

	la	$a0, addressOfNextNodeLabel
	li	$v0, 4
	syscall
	move	$a0, $s1	# $s0: Address of next node
	li	$v0, 34
	syscall	
	
	la	$a0, dataValueOfCurrentNode
	li	$v0, 4
	syscall
		
	move	$a0, $s2	# $s2: Data of current node
	li	$v0, 1		
	syscall	

# Now consider next node.
	move	$s0, $s1	# Consider next node.
	j	printNextNode
printedAll:
# Restore the register values
	lw	$ra, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw	$s1, 12($sp)
	lw	$s0, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra
#=========================================================	

reversePrint:
	# Save $s registers used
	addi	$sp, $sp, -20
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	sw	$s3, 4($sp)
	sw	$ra, 0($sp) 	# Save $ra just in case we may want to call a subprogram

# $a0: points to the linked list.
# $s0: Address of current
# s1: Address of next
# $2: Data of current
# $s3: Node counter: 1, 2, ...
	move $s0, $a1	# $s0: points to the current node.
	li   $s3, 0
printNextNode2:
	lw	$s1, 0($s0)	# $s1: Address of  next node
	lw	$s2, 4($s0)	# $s2: Data of current node
	
	beq	$s1, $zero, printedAll2 # $s0: Address of current node

	addi	$s3, $s3, 1
	move	$a1, $s1
	jal reversePrint

	
printedAll2:

# $s0: address of current node: print in hex.
# $s1: address of next node: print in hex.
# $s2: data field value of current node: print in decimal.
	la	$a0, line
	li	$v0, 4
	syscall		# Print line seperator
	
	
	la	$a0, addressOfCurrentNodeLabel
	li	$v0, 4
	syscall
	
	move	$a0, $s0	# $s0: Address of current node
	li	$v0, 34
	syscall

	la	$a0, addressOfNextNodeLabel
	li	$v0, 4
	syscall
	move	$a0, $s1	# $s0: Address of next node
	li	$v0, 34
	syscall	
	
	la	$a0, dataValueOfCurrentNode
	li	$v0, 4
	syscall
		
	move	$a0, $s2	# $s2: Data of current node
	li	$v0, 1		
	syscall	

# Now consider next node.
	move	$s0, $s1	# Consider next node.
# Restore the register values
	lw	$ra, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw	$s1, 12($sp)
	lw	$s0, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra
		
	.data
	
print1:
	.asciiz "Enter a size: "
print2:
	.asciiz "Enter inputs: "
	
	
line:	
	.asciiz "\n --------------------------------------"

nodeNumberLabel:
	.asciiz	"\n Node No.: "
	
addressOfCurrentNodeLabel:
	.asciiz	"\n Address of Current Node: "
	
addressOfNextNodeLabel:
	.asciiz	"\n Address of Next Node: "
	
dataValueOfCurrentNode:
	.asciiz	"\n Data Value of Current Node: "

