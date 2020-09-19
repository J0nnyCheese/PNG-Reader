
#########################Read Image#########################
.data
errorinfor:             .asciiz "When you open the file, there are some errors."
buffer:			.space 2048


.text
		.globl read_image
read_image:
	# $a0 -> input file name
	# $a0 is given
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width; 4 byte
	#       int height; 4 byte
	#	int max_value; 4 byte
	#	char contents[width*height]; 1* width * height bytes
	#	}
	##############################################
	# Add code here
	
	# ***************************
	move $s7, $ra	# save $ra
	# **************************
	
	# a0 already has address of a file
	# open the file
	li $v0, 13           # system call for opening the file
	li $a1, 0           # open for reading	
	li $a2, 0            # ignore mode
	syscall              # Opens file
	move $s0, $v0        # save the file descriptor 

	slt $t0, $s0, $zero	# if ($s0) < 0, return ERROR!
	bne $t0, $zero, Error    # if there are some errors, error statement will be printed
	
	# else, has the fd; read the file
	# read the file (char needed to be converted to int)
	li $v0, 14           # system call for reading the file
	move $a0, $s0        # $a0 -> file descriptor ($s0)
	la $a1, buffer       # $a1 = address of input buffer 
	li $a2, 2048      # $a2 = maximum number of characters to read
	syscall              # read file into buffer
	# now (buffer) = $a1 stores the content
	

	#-----------------initialization for read_chunk-----------------
	addi $a0, $zero, 0	# $a0 = 0 (initialization)
	la $t0, buffer		# $t0 = address of the text
	addi $t0, $t0, 3	# skip the first 3 char, i.e. "P5 "
	addi $t1, $zero, 0	# $t1 = number of digit = 0 (for each chunk of data/number)
	addi $t2, $zero, 32	# $t2 = ' ' = 32 = space
	#---------------------------------------------------------------

make_struct:
	jal read_chunk	# return the width $s1
	move $s1, $a0
	addi $a0, $0, 0	# restore $a0 = 0
	
	jal read_chunk	# return the height $s2
	move $s2, $a0
	addi $a0, $0, 0	# restore $a0 = 0
	
	jal read_chunk	# return the max value $s3
	move $s3, $a0
	addi $a0, $0, 0	# restore $a0 = 0
	
	mult $s1, $s2
	mflo $s4	# return the height*width = $s4
	
	la $s5, ($t0)	# s5 = current reading address of buffer = $t0 in read_chunk
	
	addi $s4, $s4, 12	# s4 = 3 * sizeof(int) byte + $s4 * 1 byte
	
	la $v0, ($sp)	# $v0 will be returned to main
	sub $sp, $sp, $s4	# struct on stack
	addi $t0, $s4, -4	
	add $t0, $t0, $sp	# $t0 = $sp + ($s4 - 4) = address of width
	sw $s1, 0($t0)		# 0($t0) = content of $s1 = width
	sw $s2, -4($t0)		# save height
	sw $s3, -8($t0)		# save max_value
	addi $t0, $t0, -8
	
store_pixel:
	addi $t0, $t0, -1	# char is 1 byte; $t0 = address of each pixel
	slt  $t1, $t0, $sp	# reutrn to main if ($t0 < $sp)
	beq $t1,1, return_main
	lb $s6, ($s5)		# s6 = char; $s5 = current address in buffer
	sb $s6, ($t0)
	addi $s5, $s5, 1	# $s5 ++
	
	j store_pixel
	
	
	
return_main:	
	move $ra, $s7
	jr $ra		# go back to main
	
	
	

read_chunk:	
	#loop until the end of the current char num
	#number stored in $a0
	lb $t3, 0($t0) 		# $t3 = char of a_char[$t0];
	addi $t0, $t0, 1	# $t0 ++

	#if $t3 == ' ' do convert 
	beq $t3, $t2, convert
	#if $t3 = '\n' do convert
	beq $t3, 10, convert
			
	# else
	addi $t1, $t1, 1	# $t1 ++ (number of digit)
	j read_chunk

convert:
	#convert int_buffer into int
	addi $t4, $t0, -2	# $t4 = address of last digit
	lb $t6, ($t4)		# $t6 = content of $t4 in ascii
	addi $t6, $t6, -48	# $t6 = int
	add $a0, $a0, $t6	# $a0 += $t6
	addi $t1, $t1, -1	# $t2 --
		
	addi $t7, $zero, 10	# $t7 = power factor
	addi $t8, $zero, 10	
convert_loop:
	# if $t1 == 0 return the int
	beq $t1, $zero, return_number

	#else loop
	addi $t4, $t4, -1	# $t4 = address of last digit
	lb $t6, 0($t4)		# $t6 = content of $t4 in ascii
	addi $t6, $t6, -48	# $t6 = int
	mult $t6, $t7
	mflo $t6		# $t6 = $t6 * $t7
	mult $t7, $t8
	mflo $t7		# $t7 = $t7 * 10
	add $a0, $a0, $t6	# $a0 += $t6

	addi $t1, $t1, -1	# $t1 --
	j convert_loop
	
	#-----------------
	
	
Error:  li $v0, 4         # system call for print the string
	la $a0, errorinfor    # load the address of error statement
	syscall          # print the string
	
	
	# exit the program
	li $v0, 10
	syscall	  	
	
return_number:	
	jr $ra



	
	

