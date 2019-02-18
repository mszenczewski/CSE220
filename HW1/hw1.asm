# Michael Szenczewski
# mszenczewski
# 111267857

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
zero_str: .asciiz "Zero\n"
neg_infinity_str: .asciiz "-Inf\n"
pos_infinity_str: .asciiz "+Inf\n"
NaN_str: .asciiz "NaN\n"
floating_point_str: .asciiz "_2*2^"

# Miscellaneous strings
nl: .asciiz "\n"

# Put your additional .data declarations here, if any.
s_negative: .asciiz "-"
s_period: .asciiz "."
s_base_conversion_ans: .asciiz "----------------------------------------"
s_fp_binary: .asciiz "********************************"
s_fp_bit: .asciiz "%"

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beq $a0, 0, zero_args
    beq $a0, 1, one_arg
    beq $a0, 2, two_args
    beq $a0, 3, three_args
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory
    
start_coding_here:
	#get first argument
	lw $s0 addr_arg0
	lbu $s1 ($s0)

	#test if longer than one character
	lw $t4 addr_arg0
	addi $t4 $t4 1
	lbu $t2 ($t4)
	bnez $t2 invalid_operation
	
	#test if 2
	li $s2 '2'
	beq $s1, $s2 twos_comp

	#test if F
	li $s2 'F'
	beq $s1, $s2 floating_point

	#test if C
	li $s2 'C'
	beq $s1, $s2 base_convert

	#if not F or 2 or C
	j invalid_operation

twos_comp:
	#test if proper number of arguments
	lw $t0 num_args
	li $t1 2
	beq $t1 $t0 correct_num_arg
	j invalid_arguments
	correct_num_arg:

	#get second argument
	lw $s0 addr_arg1
	
	li $s7 0 #string length

	validate.twos:
		#exit if 0
		lbu $t5 ($s0)
		beqz $t5 validate.twos.done
		
		#test if 0 or 1 only
		beq $t5 '0' valid_input.twos
		beq $t5 '1' valid_input.twos
		j invalid_arguments
		valid_input.twos:

		#iterate through string	
  		addi $s0 $s0 1 
		
		#iterate counter
		addi $s7 $s7 1 
		
		#fail if greater than 32-bit
		beq $s7 33 invalid_arguments 
	j validate.twos

	validate.twos.done:

	# s0 points at least significant bit
	addi $s0 $s0 -1
	
	# s7 has total length of string

	addi $s7 $s7 -1 # remove sign bit

	li $t9 0 #sum
	li $t8 0 #exponent

	#test for sign
	lw $s3 addr_arg1
	lbu $t5 ($s3)
	beq $t5 '0' is_positive
		
	#move pointer to rightmost 1
	move_pointer:
	
		#exit if string ends
		beqz $s7 move_pointer.done
		
		#exit if 0
		lbu $t5 ($s0)
		beq $t5 '0' move_pointer.done

		addi $t8 $t8 1 #increase exponent
		addi $s7 $s7 -1 #decrement length
		addi $s0 $s0 -1 #move one bit in

		j move_pointer
	move_pointer.done:
	
	addi $t9 $t9 1 #for the rightmost 1
	
	is_negative:
		beqz $s7 twos_print_negative
	
		#load bit
		lbu $t6 ($s0) 

		addi $t6 $t6 -48 #convert from ASCII to 0 or 1
		
		beq $t6 0 make_one
		li $t6 0
		j make_one.done
		
		make_one:
		li $t6 1		
		make_one.done:

		#t9 = t6 * 2 ^ t8

		li $s4 1
		move $t3 $t8
		exponent_loop:
			beqz $t3 exponent_loop.done #exit
			
			sll $s4 $s4 1
			
			addi $t3 $t3 -1 #decrement

			j exponent_loop
		exponent_loop.done:

		mul $t2 $s4 $t6 

		addu $t9 $t9 $t2
		
		#fix -2147483648
		li $t0 -2147483648
		bne $t9 $t0 not_overflow
		li $v0 1
		move $a0 $t9
		syscall
		j print_new_line
		not_overflow:
		
		addi $t8 $t8 1 #increase exponent
		addi $s7 $s7 -1 #decrement length
		addi $s0 $s0 -1 #move one bit in

		j is_negative		

	is_positive:
	
		beqz $s7 twos_print
	
		#load bit
		lbu $t6 ($s0) 

		addi $t6 $t6 -48 #convert from ASCII to 0 or 1

		#t9 = t6 * 2 ^ t8

		li $s4 1
		move $t3 $t8
		exponent_loop.pos:
			beqz $t3 exponent_loop.pos.done #exit
			
			sll $s4 $s4 1
			
			addi $t3 $t3 -1 #decrement

			j exponent_loop.pos
		exponent_loop.pos.done:

		mul $t2 $s4 $t6 

		add $t9 $t9 $t2
		
		addi $t8 $t8 1 #increase exponent
		addi $s7 $s7 -1 #decrement length
		addi $s0 $s0 -1 #move one bit in

		j is_positive

	twos_print_negative:
		li $v0 4
		la $a0 s_negative
		syscall
	twos_print:	
		li $v0 1
		move $a0 $t9
		syscall

	j print_new_line

floating_point:
	#test if proper number of arguments
	lw $t0 num_args
	li $t1 2
	beq $t1 $t0 correct_num_arg.fp
		j invalid_arguments
	correct_num_arg.fp:

	
	lw $s0 addr_arg1 #get second argument
	
	li $s7 0 #string length
	li $t2 0 #number of nonzero characters

	validate.fp:

		#exit if 0
		lbu $t5 ($s0)
		beqz $t5 validate.fp.done
		
		#test if '0' thru '9' or 'A' thru 'F'
		#test if 48 thru 57 or 65 thru 70
		
		bge $t5 48 greater_than_48
		j invalid_arguments
		
		greater_than_48:
		ble $t5 57 valid_input.fp # 48 thru 57
		
		blt $t5 65 invalid_arguments # 57 thru 64
		
		bgt $t5 70 invalid_arguments # 70 up
		
		valid_input.fp:

  		addi $s0 $s0 1 #iterate through string	
		addi $s7 $s7 1 #iterate counter
		
		#fail if greater than 8-bit
		beq $s7 9 invalid_arguments 

	j validate.fp

	validate.fp.done:
	
	bne $s7 8 invalid_arguments #fail if not 8-bit

	addi $s0 $s0 -1 # s0 points at least significant bit
	
	lw $s2 addr_arg1 #get second argument

	lbu $t5 ($s2) #get first character
	
	#look for special first characters
	beq $t5 '0' special_cases.zero
	beq $t5 '8' special_cases.eight
	beq $t5 '7' special_cases.seven
	beq $t5 'F' special_cases.f
	
	j not_special.fp
	
	special_cases.zero:
	
		lbu $t5 4($s2) #offset to get second character
		
		beqz $t5 special_cases.zero.print #exit when string ends
		
		bne $t5 '0' not_special.fp 	#leave if not '0'

  		addi $s2 $s2 1 #iterate through string	
		#addi $t1 $t1 1 #iterate counter
	
	j special_cases.zero
	
	special_cases.eight:
	
		lbu $t5 4($s2) #offset to get second character
		
		beqz $t5 special_cases.zero.print #exit when string ends
		
		bne $t5 '0' not_special.fp 	#leave if not '0'

  		addi $s2 $s2 1 #iterate through string	
	
	j special_cases.eight
	
	special_cases.zero.print:
		li $v0 4
    	la $a0 zero_str
		syscall
	j exit
	
	special_cases.seven:
	
		#get second character
		addi $s2 $s2 1
		lbu $t5 ($s2) 
		
		bne $t5 'F' not_special.fp 	#leave if argument does not start with '7F'

		#get third character
		addi $s2 $s2 1
		lbu $t5 ($s2)
		
		bne $t5 '8' not_7F8 #leave if not '7F8'

		# is '7F8'	
		is_zeros.7F8:
			#get next character
			addi $s2 $s2 1
			lbu $t5 ($s2)
		
			beqz $t5 is_zeros.7F8.done #exit when string ends
		
			bne $t5 '0' print_NaN #leave if not '7F000000'
		j is_zeros.7F8
			
		is_zeros.7F8.done:
			
		li $v0 4
    	la $a0 pos_infinity_str
		syscall
		j exit
		
		print_NaN:
		li $v0 4
    	la $a0 NaN_str
		syscall
		j exit
		
		not_7F8: 
		# t5 still contains at third character
		blt $t5 '8' not_special.fp 	#leave if argument does not start with '7F8' or greater
		j print_NaN
	
	special_cases.f:
	
	#get second character
	addi $s2 $s2 1
	lbu $t5 ($s2)
	
	bne $t5 'F' not_special.fp 	#leave if argument does not start with 'FF'
	
	#get third character
	addi $s2 $s2 1
	lbu $t5 ($s2)
	
	bgt $t5 '8' print_NaN #leave if greater than 8
	bne $t5 '8' not_special.fp #leave if not 'FF8'
	
	is_zeros.FF8:
		#get next character
		addi $s2 $s2 1
		lbu $t5 ($s2)
		
		beqz $t5 print_neg_infinity #exit when string ends
		
		bne $t5 '0' print_NaN #leave if not 'FF800000'
	j is_zeros.FF8
	
	print_neg_infinity:
	li $v0 4
   	la $a0 neg_infinity_str
	syscall
	j exit
			
	# DEFAULT CASE	
	not_special.fp:	
	
	lw $s0 addr_arg1 #s0 address of second argument
	la $s7 s_fp_binary #address of output string
	li $s1 2 #base 2
	
	hex_to_binary:
		addi $s7 $s7 3 #move 4 over because the results will print in reverse order
	
		lbu $t1 ($s0) #load next value in string
		
		beqz $t1 stored_as_binary #leave when empty
		
		bgt $t1 58 not_a_number
		addi $t1 $t1 -48 #convert from ASCII if 0-9
		j stored_as_decimal
		
		not_a_number:
		addi $t1 $t1 -55 #convert from ASCII if A-F
	
		stored_as_decimal:
		
		li $t5 4 #counter
		
		decimal_to_binary:
			beqz $t5 decimal_to_binary.done #exit after 4 loops
			
			div $t1 $s1
			mfhi $t2 #remainder
			mflo $t1 #quotient
			
			addi $t2 $t2 48 #convert to ASCII
		
			sb $t2 ($s7) #store output 
		
			addi $t5 $t5 -1 #decrement counter
			addi $s7 $s7 -1 #move to the left because results are backwards inserted
		j decimal_to_binary
		decimal_to_binary.done:
	
		addi $s0 $s0 1 #iterate input string
		addi $s7 $s7 1 #iterate output string
		addi $s7 $s7 4 #move 4 over because the results will print in reverse order
	j hex_to_binary
	
	stored_as_binary:
	
	la $s0 s_fp_binary
	
	lbu $s1 ($s0) #load sign bit
	
	addi $s1 $s1 -48 #convert ASCII
	
	li $t0 8 #loop counter
	
	move $s2 $zero
	
	load_exponent:
		beqz $t0 load_exponent.done #leave when counter 0
		
		addi $s0 $s0 1 #move to start of exponent 
	
		lbu $t1 ($s0) #load next bit from exponent
		
		addi $t1 $t1 -48 #convert from ASCII
		
		add $s2 $s2 $t1 #add new bit
		
		sll $s2 $s2 1 #move exponent over to prepare for next bit
		
		addi $t0 $t0 -1 #iterate counter
	j load_exponent
	load_exponent.done:
	
	srl  $s2 $s2 1 #undo move on last loop
	
	addi $s2 $s2 -127 #remove bias-127
	
	beqz $s1 is_positive.fp
	li $v0 4
	la $a0 s_negative
	syscall
	
	is_positive.fp:
	
	li $v0 1
	li $a0 1
	syscall
	
	li $v0 4
	la $a0 s_period
	syscall
	
	li $t0 -1 #so loop can start
	addi $s0 $s0 1 #move to start of mantissa 
	
	print_mantissa:
		beqz $t0 print_mantissa.done #exit when string ends
		
		lbu $t0 ($s0) #load next bit
		
		sb $t0 s_fp_bit #store it in a string
		
		li $v0 4
		la $a0 s_fp_bit
		syscall
		
		addi $s0 $s0 1 #move to next bit
	j print_mantissa
	
	print_mantissa.done:
	
	li $v0 4
    la $a0 floating_point_str
	syscall
	
	li $v0 1
	move $a0 $s2
	syscall
	
	j print_new_line

base_convert:
	#test if proper number of arguments
	lw $t0 num_args
	li $t1 4
	bne $t1 $t0 invalid_arguments
	
	lw $s0 addr_arg1 #address of second argument (input string)

	#third argument (original base)
	lw $t4 addr_arg2 
	move $a0 $t4
    li $v0 84
    syscall
    move $s1 $v0
	
	validate.bc:
		lbu $t1 ($s0) #load next value in string
		
		beqz $t1 valid_input.bc #leave if string empty
		
		addi $t1 $t1 -48 #convert from ASCII
		
		bge $t1 $s1 invalid_arguments #exit if value greater than or equal to base

  		addi $s0 $s0 1 #iterate through string	
	j validate.bc
	
	valid_input.bc:
	
	#fourth argument (new base)
	lw $t4 addr_arg3 
	move $a0 $t4
    li $v0 84
    syscall
    move $s2 $v0
    
    addi $s0 $s0 -1
    
    li $t9 0
    li $s3 0
	
	# s0 points to least significant digit of string
	# s1 is the original base
	# s2 is the new base
	# s3 is the sum
	# t9 is the exponent
	
	convert_dec.bc:
		lbu $t1 ($s0) #load next value in string
		
		beqz $t1 converted_to_dec.bc #leave if string empty
		
		addi $t1 $t1 -48 #convert from ASCII
		
		move $t2 $t9
		
		li $t3 1 #exponent sum
		
		exponent_loop.bc:
			beqz $t2 exponent_loop.bc.done #exit when exponent is 0
			
			mul $t3 $t3 $s1
			
			addi $t2 $t2 -1
		j exponent_loop.bc
		exponent_loop.bc.done:
		
		mul $t1 $t1 $t3
		
		add $s3 $s3 $t1
	
		addi $t9 $t9 1 #iterate exponent
		addi $s0 $s0 -1 #iterate thru string
	j convert_dec.bc
	
	converted_to_dec.bc:
	
	# s2 is the new base
	# s3 is the input value in decimal
	
	la $s4 s_base_conversion_ans #output address leftmost character
	
	sb $0 ($s4)
	addi $s4 $s4 1
	
	move $t1 $s3
	
	convert_from_dec.bc:
		
		div $t1 $s2 
		mfhi $t2 #remainder
		mflo $t1 #quotient
		
		addi $t2 $t2 48 #convert to ASCII
		
		sb $t2 ($s4) #store output
		
		addi $s4 $s4 1 #iterate string
		
		beqz $t1 print_base_conversion
	j convert_from_dec.bc
	
	print_base_conversion:
	
	addi $s4 $s4 -1 #pointer now points to first LOGICAL character

	
	print_ans.bc:
		lbu $t6 ($s4) #load first LOGICAL character
		beqz $t6 print_new_line
		
		addi $t6 $t6 -48 #convert from ASCII
		
		li $v0 1
		move $a0 $t6
		syscall
		
		addi $s4 $s4 -1 #move to the LOGICAL right
	j print_ans.bc
	
invalid_arguments:
    li $v0 4
    la $a0 invalid_args_error
	syscall

	j exit

invalid_operation:
    li $v0 4
    la $a0 invalid_operation_error
	syscall

	j exit

print_new_line:
    li $v0 4
    la $a0 nl
	syscall
	j exit

exit:
    li $v0 10   # terminate program
    syscall
