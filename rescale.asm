
###############################rescale image######################
.data
.text
.globl rescale_image
rescale_image:
	# $a0 -> image struct
	############return###########
	# $v0 -> rescaled image
	######################
	# Add Code
	
	move $s1, $a0	# $s1 = address of struct
	move $t5, $a0	# $t8 = address of struct

	addi $s1, $s1, -4
	lw $s3, ($s1)	# $s3 = width
	
	addi $s1, $s1, -4
	lw $s4, ($s1)	# $s4 = height
	
	addi $s1, $s1, -4 
	lw $s5, ($s1)	# $s5 = old max_value
	
	mult $s3, $s4
	mflo $s6 	# $s6 = max index in pixel array

#--------------------------------------------------
# return $t2 = min_value
find_min:
	addi $t7, $0, 0	# $t7 = index counter (used twice in find_min and update_pixel_loop)
	move $s2, $s1
	addi $s2, $s2, -1	# $s2 = address of each pixel
	addi $t2, $0, 255 # $t6 = initialize min_value to 255
	
compare_loop:
	lb $t4, ($s2)
	slt $t3, $t4, $t2	# if $t4 < $t6, then update_min
	beq $t3, 1, update_min
	j cont_compare_loop
	
update_min:
	move $t2, $t4
	j cont_compare_loop

cont_compare_loop:
	addi $t7, $t7, 1
	beq $t7, $s6, exit_compare_loop
	addi $s2, $s2, -1
	j compare_loop
	
exit_compare_loop:
	# min stored in $t2
#----------------------------------------------------------
	
	
#----------------------------------------------------------
	# $t2 = min_value
	addi $t7, $0, 0		# reset: $t7 = 0 = index counter (used twice in find_min and update_pixel_loop
	sub $t1, $s5, $t2	# $t1 = max - min = diff.
	addi $t3, $0, 0 	# $t3 = updated max value(= 0 initially)
update_pixel_loop:
	addi $s1, $s1, -1
	lb $t0, ($s1)	# $t0 = pixel
	
	#------------------ linear contrast calculation ---------------
	sub $t4, $t0, $t2
	li $t8, 255
	mult $t4, $t8
	mflo $t4	# $t4 = (x - min) * 255
	mtc1 $t4, $f1
	mtc1 $t1, $f2
	div.s $f0, $f1, $f2	# $f0 = (x - min) * 255 / diff
	round.w.s $f0, $f0	# round $f0
	mfc1 $t4, $f0	# $t4 = linear contrast pixel value result
	#--------------------------------------------------------------
	sb $t4, ($s1)	# update struct
	
	slt $t9, $t3, $t4
	beq $t9, 1, update_max
	j pixel_conti
	
update_max:
	move $t3, $t4
	j pixel_conti
		
pixel_conti:
	addi $t7, $t7, 1
	beq $t7, $s6, exit_pixel_loop
	j update_pixel_loop
	

#----------------------------------------------------------
exit_pixel_loop:
	sw $t3, -12($t5)	# update the new max_value
	move $v0, $a0
	jr $ra

