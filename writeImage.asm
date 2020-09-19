
####################################write Image#####################
.data
P5: 	.ascii "P5 "
P2: 	.ascii "P2 "
content: .space 2048
errorinfor:             .asciiz "Error: not able to correctly open file."

.text
.globl write_image
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	# Add code here.
	
	move $s6, $ra # save $ra
	
	#move $s6, $a0	# save $a0, $a2 to $s6, $s7
	move $s7, $a2
	
	#write pic info to file
	move $s1, $a0	# use $s1 to traverse on struct
	lw $s2, -4($s1)	# $s2 = width
	lw $s3, -8($s1) # $s3 = height
	lw $s4, -12($s1) 	# $s4 = max_value
	
	move $a0, $a1	# $a0 = $a1 = file location on disk for open file
	
	
	
prepare_content:
	la $t0, content # $t0 = address of content
	addi $t1, $0, 0 	# $t1 = char counter
	
	# $t2 = each char
	# save "P5 " or "P2 "
	addi $t2, $0, 80
	sb $t2, ($t0) # save "P"
	addi $t0, $t0, 1	# increase 1 byte
	addi $t1, $t1, 1

	#if ($s7 = $a2 = 0) then write P5; else write P2
	Is_P5_P2:
		beqz $s7, write_2
		addi $t2, $0, 53	# save "5"
		sb $t2, ($t0)
		addi $t0, $t0, 1	# increase 1 byte
		addi $t1, $t1, 1
		j continue
	write_2:
		addi $t2, $0, 50	# save "2"
		sb $t2, ($t0)
		addi $t0, $t0, 1	# increase 1 byte
		addi $t1, $t1, 1
continue:
	addi $t2, $0, 32
	sb $t2, ($t0)	# save " "
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	# save width, height, max_value
	# int_to_char:      $s5: input int; $t0: address of content; $t1: num of char
	move $s5, $s2
	jal int_to_char
	
	move $s5, $s3
	jal int_to_char
	
	move $s5, $s4
	jal int_to_char


	# COPY THE PIXEL
	mult $s2, $s3
	mflo $t3
	addi $s1, $s1, -13
	copy_loop:
		lb $t4, ($s1)
		sb $t4, ($t0)	# save the char pixel
		addi $s1, $s1, -1	# next pixel in struct
		addi $t0, $t0, 1	# next char address in content
		addi $t1, $t1, 1	# increase char counter
		addi $t3, $t3, -1	# condition of the loop: char array size > 0
		beqz $t3, write_to_file
		j copy_loop


	# save '\0'
end_of_content:	
	#addi $t2, $0, 0
	#sb $t2, ($t0)
	#addi $t0, $t0, 1
	#addi $t1, $t1, 1
	
write_to_file:
	# create a new file on disk
	# la $a1, outputFile   in "main.asm"
	# move $a0, $a1
	# => la $a0, outputFile 
	li $v0, 13           # system call for opening the file
	li $a1, 1            # open for writing	(0: read, 1: write)
	li $a2, 0            # mode is ignored
	syscall              # Opens file
	move $s0, $v0        # save the file descriptor 
	
	slt $t0, $s0, $zero
	bne $t0, $zero, Error    # if there are some errors, error statement will be printed
	
	# write all file content to the file
	li $v0, 15           # system call for write to file
	move $a0, $s0        # file descriptor (content of $s0 saved to $a0)
	la $a1, content       # address of buffer from which to write 
	add $a2, $0, $t1         # hardcoded buffer length
	syscall              # write to file
	
	# Close the file 
        li   $v0, 16       # system call for close file
  	syscall            # close file
	
	move $ra, $s6
	jr $ra		   # return
	
Error:  li $v0, 4         # system call for print the string
	la $a0, errorinfor    # load the address of error statement
	syscall          # print the string
	
	# exit the program
	li $v0, 10
	syscall	  	  
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
# Need: $s5: input int; $t0: address of content; $t1: num of char
# result is directly added to "content"
int_to_char:
	li $t3, 100
	li $t4, 10
	li $t5, 1
	
	
	# -------------------------------------------------------------------
	beq $s5, 100, three_d_convert
	beq $s5, 10, two_d_convert
	beq $s5, 1, one_d_convert
	
	slt $t6, $t3, $s5
	slt $t7, $t4, $s5
	slt $t8, $t5, $s5
	
	beq $t6, 1, three_d_convert
	beq $t7, 1, two_d_convert
	beq $t8, 1, one_d_convert
	
	# ------------------------------------------------------------------
	
	#else the input must be '0'
	j else

else:	addi $t2, $0, 48
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	j cont
	
three_d_convert:
# find the ?XX
	div $s5, $t3
	mfhi $s5	# XX -> $a0
	mflo $t2	# ? -> $t2
	addi $t2, $t2, 48 # $t2: int to ascii
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	# find the ?X
	div $s5, $t4
	mfhi $s5	# X -> $a0
	mflo $t2	# ? -> $t2
	addi $t2, $t2, 48 # $t2: int to ascii
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	# find the ? (1 digit)
	addi $t2, $s5, 0
	addi $t2, $t2, 48 # $t2: int to ascii
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	j cont
two_d_convert:
	# find the ?X
	div $s5, $t4
	mfhi $s5	# X -> $a0
	mflo $t2	# ? -> $t2
	addi $t2, $t2, 48 # $t2: int to ascii
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	# find the ? (1 digit)
	addi $t2, $s5, 0
	addi $t2, $t2, 48 # $t2: int to ascii
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	j cont
one_d_convert:
	# find the ? (1 digit)
	addi $t2, $s5, 0
	addi $t2, $t2, 48 # $t2: int to ascii
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	j cont
cont:
	# bull shit....
	addi $t2, $0, 32 # $t2: ' ' = space
	sb $t2, ($t0)
	addi $t0, $t0 , 1
	addi $t1, $t1, 1
	
	
	jr $ra
	
	
		
		
