
############################ file-io########################
.data
			.align 2
inputTest1:		.asciiz "Provide Your Own Address"
			.align 2
inputTest2:		.asciiz "Provide Your Own Address"
			.align 2
outputFile:		.asciiz "Provide Your Own Address"
			.align 2

errorinfor:             .asciiz "Error: not able to correctly open file."

line:			.asciiz "P2\n24 7\n15\n"

buffer:			.space 1024


.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	#la $a0,inputTest2
	jal read_file
	
	la $a0,outputFile
	jal write_file
	
Exit:	li $v0,10		# exit...
	syscall	
	

# ----------------------------------- a -------------------------------------- #
		

	
read_file:
	# $a0 -> input filename	
	# Opens file
	# read file into buffer
	# return
	# Add code here
	

	# open the file
	li $v0, 13           # system call for opening the file
	li $a1, 0           # open for reading	
	li $a2, 0            # ignore mode
	syscall              # Opens file
	move $s0, $v0        # save the file descriptor 
	
	slt $t0, $s0, $zero	# if ($s0) < 0, return ERROR!
	bne $t0, $zero, Error    # if there are some errors, error statement will be printed
	 
	# else, everything works as intended
	# read the file
	li $v0, 14           # system call for reading the file
	move $a0, $s0        # $a0 -> file descriptor ($s0)
	la $a1, buffer       # $a1 = address of input buffer 
	li $a2, 1024      # $a2 = maximum number of characters to read
	syscall              # read file into buffer
	
	
	# print the character
	li $v0, 4          # system call to print string
	la $a0, buffer       # buffer contains the character
	syscall              # print characters

	
	
	# Close the file 
        li   $v0, 16       # system call for close file
  	move $a0, $s0      # file descriptor to close
  	syscall            # close file
	
	jr $ra		   # return
	
	
	
	
# ----------------------------------- b -------------------------------------- #
	
write_file:
	# $a0 -> outputFilename
	# open file for writing
	# write following contents:
	# P2
	# 24 7
	# 15
	# write out contents read into buffer
	# close file
	# Add  code here
	
	# open the file
	li $v0, 13           # system call for opening the file
	li $a1, 1            # open for writing	(0: read, 1: write)
	li $a2, 0            # mode is ignored
	syscall              # Opens file
	move $s0, $v0        # save the file descriptor 
	
	slt $t0, $s0, $zero
	bne $t0, $zero, Error    # if there are some errors, error statement will be printed
	
	
	# write line  to the file
	li $v0, 15           # system call for write to file
	move $a0, $s0        # file descriptor (content of $s0 saved to $a0)
	la $a1, line       # address of buffer from which to write 
	li $a2, 12        # hardcoded buffer length
	syscall              # write to file
	
	

	
	# Close the file 
        li   $v0, 16       # system call for close file
  	move $a0, $s0      # file descriptor to close
  	syscall            # close file
	
	jr $ra		   # return
	
Error:  li $v0, 4         # system call for print the string
	la $a0, errorinfor    # load the address of error statement
	syscall          # print the string
	
	
	# exit the program
	li $v0, 10
	syscall	  	  
