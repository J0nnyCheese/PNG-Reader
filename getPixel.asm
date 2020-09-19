
.data
out_of_bound: 	.asciiz "Error in getPixel: pixel index out of bound. Program terminate."


.text
.globl get_pixel
get_pixel:
	# $a0 -> image struct
	# $a1 -> row number - i
	# $a2 -> column number - j
	################return##################
	# $v0 -> value of image at (row,column) start at (0,0)
	#######################################
	# Add Code
	
	
	move $s1, $a0	# $s1 = address of struct
	#mult $a1, $a2
	#mflo $s2	# $s2 offset to the first pixel
	
	addi $s1, $s1, -4
	lw $s3, ($s1)	# $s3 = width = 24
	
	addi $s1, $s1, -4
	lw $s4, ($s1)	# $s4 = height = 7
	
	mult $s3, $s4
	mflo $t1	# $t1 = width * height
	
	addi $s1, $s1, -4 # $s1 align with the start of pixel
	
	mult $a1, $s3
	mflo $t0 # $t0 = i* width
	add $t0, $t0, $a2	# $t0 = i * width + j
	
	# if (i,j) if out of bound -> error; else get value
	slt $t2, $t0, $t1
	bne $t2, 1, error_out_of_bound
	
	sub $s1, $s1, $t0	
	lb $v0, ($s1)			# value of image at (i,j) = $v0

	jr $ra
	
error_out_of_bound:
	li $v0, 4
	la $a0, out_of_bound
	syscall
	
	li $v0, 10
	syscall
	
