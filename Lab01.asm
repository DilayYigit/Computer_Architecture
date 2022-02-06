##
## Program1.asm - prints out "hello world"
##
##	a0 - points to the string
##

#################################
#				#
#	text segment		#
#				#
#################################

	.text		
	.globl __start 

__start:		# execution starts here
	la $a0,str	# put string address into a0
	li $v0,4	# system call to print
	syscall		#   out a string

	li $v0,10  # system call to exit
	syscall	#    bye bye


#################################
#				#
#     	 data segment		#
#				#
#################################

	.data
str:	.asciiz "Hello Murat Hocam\n"
n:	.word	10

##
## end of file Program1.asm

---------------------------------------------------------
##
## Program2.asm asks user for temperature in Celsius,
##  converts to Fahrenheit, prints the result.
##
##	v0 - reads in Celsius
##	t0 - holds Fahrenheit result
##	a0 - points to output strings
##

#################################
#				#
#	text segment		#
#				#
#################################

	.text		
	.globl __start	

__start:
	la $a0,prompt	# output prompt message on terminal
	li $v0,4	# syscall 4 prints the string
	syscall

	li $v0, 5	# syscall 5 reads an integer
	syscall

	mul $t0,$v0,9	# to convert,multiply by 9,
	div $t0,$t0,5	# divide by 5, then
	add $t0,$t0,32	# add 32

	la $a0,ans1	# print string before result
	li $v0,4
	syscall

	move $a0,$t0	# print integer result
	li $v0,1		# using syscall 1
	syscall

	la $a0,endl	# system call to print
	li $v0,4		# out a newline
	syscall

	li $v0,10		# system call to exit
	syscall		#    bye bye


#################################
#				#
#     	 data segment		#
#				#
#################################

	.data
prompt:	.asciiz "Enter temperature (Celsius): "
ans1:	.asciiz "The temperature in Fahrenheit is "
endl:	.asciiz "\n"

##
## end of file Program2.asm


---------------------------------------------------------
##
##	Program3.asm is a loop implementation
##	of the Fibonacci function
##        

#################################
#				#
#	text segment		#
#				#
#################################

	.text		
.globl __start
 
__start:		# execution starts here
	li $a0,7	# to calculate fib(7)
	jal fib		# call fib
	move $a0,$v0	# print result
	li $v0, 1
	syscall

	la $a0,endl	# print newline
	li $v0,4
	syscall

	li $v0,10
	syscall	# bye bye

#------------------------------------------------


fib:	move $v0,$a0	# initialise last element
	blt $a0,2,done	# fib(0)=0, fib(1)=1

	li $v0,0	# second last element
	li $t0,1	# last element

loop:	add $t1,$v0,$t0	# get next value
	move $v0,$t0	# update second last
	move $t0,$t1	# update last element
	subi $a0,$a0,1	# decrement count
	bgt $a0,$zero,loop	# exit loop when count=0
done:	jr $ra

#################################
#				#
#     	 data segment		#
#				#
#################################

	.data
endl:	.asciiz "\n"

##
## end of Program3.asm

---------------------------------------------------------
	.data
print1:
	.asciiz "Enter a: "
print2:
	.asciiz "Enter b: "
result:
	.asciiz "Result: "
	
	.text
	li $v0, 4
	la $a0, print1
	syscall
	
	li $v0, 5
	syscall
	move $t1, $v0 #t1 = a
	
	li $v0, 4
	la $a0, print2
	syscall
	
	li $v0, 5
	syscall
	move $t2, $v0 #t2 = b
	
	sub $t3, $t1, $t2 #t3 = a - b
	
	mult $t3, $t2
	mflo $t4
	
	add $t5, $t4, $t1
	
	div $t5, $t2
	mfhi $t6
	
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall

---------------------------------------------------------
	
	.data
array: 	
	.space 400
printFirst:
	.asciiz "Enter the number of elements: "
printSecond: 
	.asciiz "Enter the elements: "
printResult1:
	.asciiz "Sum: "
printEven:
	.asciiz "Even sum: "
printOdd:
	.asciiz "Odd sum: "
printDivisible:
	.asciiz "Counter: "
printMenu: 
	.asciiz "1.Sum 2.Even/Odd 3.Display 4.Quit"
	
	.text
	li $v0, 4
	la $a0, printFirst
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0 #t0 = number of elements
	
	li $v0, 4
	la $a0, printSecond
	syscall
		
	li $t1, 0 # t1 = counter for loop
	li $t2, 0 # t2 = counter for adresses
	li $t4, 0 # t4 = sum 
	li $s2, 2
	
loop1: 	
	li $v0, 5
	syscall
	
	sw $v0, array($t2)
	
	addi $t2, $t2, 4 # adr = adr + 4
	addi $t1, $t1, 1 # counter++
	bne $t0, $t1, loop1
	
menu:
	li $v0, 4
	la $a0, printMenu
	syscall
	
	li $v0, 5
	syscall
	move $t9, $v0
	li $t5, 1
	li $t6, 2
	li $t7, 3
	li $t8, 4
	li $a2, 0
	beq $t9, $t5, loopA  
	beq $t9, $t6, loopB  
	beq $t9, $t7, loopC
	beq $t9, $t8, quit   
	
loopA: 
	subi $t2, $t2, 4
	lw $t3, array($t2)
	jal sum
	bne $t2, $zero, loopA
	j print1
sum:
	ble $t3, $t0, done1
	add $t4, $t4, $t3 
	jr $ra 
done1: 
	jr $ra 

print1:	
	li $v0, 4
	la $a0, printResult1
	syscall
	
	move $a0, $t4
	
	li $v0, 1
	syscall
	
	j menu
	
loopB:
	subi $t2, $t2, 4
	lw $t3, array($t2)
	jal evenCheck
	bne $t2, $zero, loopB
	j print2

evenCheck: 
	div $t3, $s2
	mfhi $t4
	bne $t4, $zero, odd
	add $s0, $s0, $t3
	jr $ra
odd:
	add $s1, $s1, $t3
	jr $ra
	
print2: 
	li $v0, 4
	la $a0, printEven
	syscall
	
	move $a0, $s0
	
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, printOdd
	syscall
	
	move $a0, $s1
	
	li $v0, 1
	syscall
	
	j menu
	
loopC:
	subi $t2, $t2, 4
	lw $t3, array($t2)
	jal check
	bne $t2, $zero, loopC
	j print3
	
check:
	div $t3, $t0
	mfhi $s3
	bne $s3, $zero, done2
	addi $a2, $a2, 1
	jr $ra
	
done2:
	jr $ra
	
print3:
	li $v0, 4
	la $a0, printDivisible
	syscall
	
	move $a0, $a2
	
	li $v0, 1
	syscall
	
	j menu
	
quit: 	
	li $v0, 10
	syscall
