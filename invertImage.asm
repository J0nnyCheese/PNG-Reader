
#################################invert Image######################
.data
.text
.globl invert_image
invert_image:
	# $a0 -> image struct
	#############return###############
	# $v0 -> new inverted image
	############################
	# Add Code
	
	#li $a1, 4
	#li $a2, 7
	#jal get_pixel
	
	#move $a0,$s0		# set value at (4,7) to 45
	#li $a1,4
	#li $a2,7
	#li $a3,45
	#jal set_pixel
	
	
	move $s1, $a0	# $s1 = address of struct

	addi $s1, $s1, -4
	lw $s3, ($s1)	# $s3 = width = 24
	
	addi $s1, $s1, -4
	lw $s4, ($s1)	# $s4 = height = 7
	
	addi $s1, $s1, -4 
	move $t6, $s1	# save a copy of address of max_value because we need to update it after the inversion
	lw $s5, ($s1)	# $s5 = max_value = 15
	
	mult $s3, $s4
	mflo $s6 	# $s6 = max index in pixel array
	
	addi $t7, $0, 0	# $t7 = index counter 
	addi $t5, $0, 0 # $t5 = smallest pixel value
	
loop:
	addi $s1, $s1, -1
	lb $t0, ($s1)	# $t0 = pixel
	sub $t1, $s5, $t0 # $t1 = max_value - pixel
	sb $t1, ($s1)
	
	slt $t2, $t0, $t5	# find the smallest of the old pgm file ==> it will the largest pixel value in the inverted pic
	beq $t2, 1, update_old_min_value
	
conti:	beq $t7, $s6, exit_loop
	addi $t7, $t7, 1
	j loop
	
update_old_min_value:
	move $t5, $t0
	j conti
	
	
exit_loop:
	sub $t7, $s5, $t5	# new max_value = old max_value - old min_value
	sw $t7, ($t6)	# update the new max_value
	jr $ra
