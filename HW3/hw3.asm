.text

# Part I
get_adfgvx_coords:
	#a0 index one
	#a1 index two
	
	bltz $a0 bad_input.gac
	bltz $a1 bad_input.gac
	
	li $t0 5
	bgt $a0 $t0 bad_input.gac
	bgt $a1 $t0 bad_input.gac
	
	li $t0 0
	beq $a0 $t0 a0_zero 
	
	li $t0 1
	beq $a0 $t0 a0_one
	
	li $t0 2
	beq $a0 $t0 a0_two 
	
	li $t0 3
	beq $a0 $t0 a0_three 
	
	li $t0 4
	beq $a0 $t0 a0_four 
	
	li $t0 5
	beq $a0 $t0 a0_five 
	
	a0_zero:
	li $v0 'A'
	j a0_done
	
	a0_one:
	li $v0 'D'
	j a0_done
	
	a0_two:
	li $v0 'F'
	j a0_done

	a0_three:
	li $v0 'G'
	j a0_done
	
	a0_four:
	li $v0 'V'
	j a0_done
	
	a0_five:
	li $v0 'X'
	j a0_done
	
	a0_done:
	
	li $t0 0
	beq $a1 $t0 a1_zero 
	
	li $t0 1
	beq $a1 $t0 a1_one
	
	li $t0 2
	beq $a1 $t0 a1_two 
	
	li $t0 3
	beq $a1 $t0 a1_three 
	
	li $t0 4
	beq $a1 $t0 a1_four 
	
	li $t0 5
	beq $a1 $t0 a1_five 
	
	a1_zero:
	li $v1 'A'
	j a1_done
	
	a1_one:
	li $v1 'D'
	j a1_done

	a1_two:
	li $v1 'F'
	j a1_done
	
	a1_three:
	li $v1 'G'
	j a1_done
	
	a1_four:
	li $v1 'V'
	j a1_done
	
	a1_five:
	li $v1 'X'
	j a1_done

	a1_done:
	
	jr $ra
	
	bad_input.gac:
	li $v0 -1
	li $v1 -1
	jr $ra

# Part II
search_adfgvx_grid:
	#a0 address of matrix
	#a1 char to find
	
	move $t0 $a0
	
	li $t2 0
	li $t3 37
	find_loop.sag:
		beq $t2 $t3 not_found.sag
		lbu $t1 ($t0)
		beq $t1 $a1 char_found.sag
		addi $t0 $t0 1
		addi $t2 $t2 1
	j find_loop.sag
	
	char_found.sag:
	
	li $t3 6
	div $t2 $t3
	
	mfhi $v1
	mflo $v0
	
	jr $ra
	
	not_found.sag:
	
	li $v0 -1
	li $v1 -1
	jr $ra

# Part III
map_plaintext:

	addi $sp $sp -16 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)


	move $s0 $a0 #adfgvx grid
	move $s1 $a1 #plaintext
	move $s2 $a2 #middletext_buffer
	
	char_loop.mp:
		move $a0 $s0 #address of grid
		lbu $a1 ($s1) #first char
		
		beqz $a1 string_done.mp
		
		jal search_adfgvx_grid
	
		move $a0 $v0 
		move $a1 $v1
		jal get_adfgvx_coords
		
		sb $v0 ($s2)
		sb $v1 1($s2)
		

		addi $s1 $s1 1 #move to next char
		addi $s2 $s2 2 #move to next output
	j char_loop.mp
	
	string_done.mp:

	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	
	addi $sp $sp 16 #registers times 4

	jr $ra

# Part IV
swap_matrix_columns:
	lbu $t0 ($sp)
	
	blez $a1 bad_input.smc
	blez $a2 bad_input.smc
	
	bltz $a3 bad_input.smc
	bltz $t0 bad_input.smc
	
	blt $a2 $a3 bad_input.smc
	blt $a2 $t0 bad_input.smc
	
	addi $sp $sp -20 #registers times 4
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	
	move $s0 $a0 
	move $s1 $a1
	move $s2 $a2 
	move $s3 $a3 
	move $s4 $t0   

	#s0 matrix
	#s1 number of rows
	#s2 number of columns
	#s3 column 1
	#s4 column 2
	
	move $t0 $s0 #left
	move $t1 $s0 #right
	
	add $t0 $t0 $s3 #move to correct column	
	add $t1 $t1 $s4 #move to correct column 
		
	li $t9 0
	swap_loop.smc:
		beq $t9 $s1 swap_finished.smc
		
		lbu $t3 ($t0)
		lbu $t4 ($t1)
		
		sb $t3 ($t1)
		sb $t4 ($t0)
		
		add $t0 $t0 $s2 #move to next row
		add $t1 $t1 $s2 #move to next row
		
		addi $t9 $t9 1
	j swap_loop.smc
	
	swap_finished.smc:
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	addi $sp $sp 20 #registers times 4
	
	li $v0 0	
	jr $ra
	
	bad_input.smc:
	li $v0 -1
	jr $ra

# Part V
key_sort_matrix:
	lbu $t0 ($sp)
	
	addi $sp $sp -36 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $s7 32($sp)

	move $s0 $a0 #matrix
	move $s1 $a1 #num rows
	move $s2 $a2 #num cols
	move $s3 $a3 #key
	move $s4 $t0 #element
	
	li $s6 -1 #number of swaps
	
	#decide if bit or byte
	li $t0 1
	beq $s4 $t0 key_sort_bit.outer
	j key_sort_byte.outer
	
	key_sort_bit.outer:
		beqz $s6 key_sort.done
		
		move $s7 $s3 #move back to start of 
		
		li $s6 0 #number of swaps
		li $s5 0 #loop counter
		key_sort_bit.inner:
			lbu $t1 ($s7) #get first key element
			lbu $t2 1($s7) #get second key element
			
			move $t6 $s5
			addi $t6 $t6 1
			beq $t6 $s2 key_sort_bit.inner.done
		
						
			ble $t1 $t2 no_swap_bit.ksm
			
			addi $s6 $s6 1 #counter of swaps
		
			sb $t1 1($s7)
			sb $t2 ($s7)
		
			move $a0 $s0 #matrix
			move $a1 $s1 #num rows
			move $a2 $s2 #num cols
			move $a3 $s5 #first col
			
			addi $sp $sp -4
			move $t0 $s5
			addi $t0 $t0 1
			sw $t0 0($sp) #second col
			jal swap_matrix_columns
			addi $sp $sp 4
			
			no_swap_bit.ksm:
		
			addi $s7 $s7 1 #move to next comparison
			addi $s5 $s5 1 #iterate counter
		j key_sort_bit.inner
		key_sort_bit.inner.done:
	j key_sort_bit.outer

	key_sort_byte.outer:
		beqz $s6 key_sort.done
		
		move $s7 $s3 #move back to start of 
		
		li $s6 0 #number of swaps
		li $s5 0 #loop counter
		key_sort_byte.inner:
			lw $t1 ($s7) #get first key element
			lw $t2 4($s7) #get second key element
			
			move $t6 $s5
			addi $t6 $t6 1
			beq $t6 $s2 key_sort_bit.inner.done
				
			ble $t1 $t2 no_swap_byte.ksm
			
			addi $s6 $s6 1 #counter of swaps
		
			sw $t1 4($s7)
			sw $t2 ($s7)
		
			move $a0 $s0 #matrix
			move $a1 $s1 #num rows
			move $a2 $s2 #num cols
			move $a3 $s5 #first col
			
			addi $sp $sp -4
			move $t0 $s5
			addi $t0 $t0 1
			sw $t0 0($sp) #second col
			jal swap_matrix_columns
			addi $sp $sp 4
			
			no_swap_byte.ksm:
		
			addi $s7 $s7 4 #move to next comparison
			addi $s5 $s5 1 #iterate counter
		j key_sort_byte.inner
		key_sort_byte.inner.done:
	j key_sort_byte.outer

	key_sort.done:

	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $s7 32($sp)
	addi $sp $sp 36 #registers times 4
	
	jr $ra

# Part VI
transpose:
	#a2 num rows
	#a3 num cols
	
	blez $a2 bad_input.tp
	blez $a3 bad_input.tp
	
	move $t0 $a0 #matrix source
	
	li $t9 0 #current row 
	transpose_loop_outer:
		beq $t9 $a2 transpose_loop_outer.done
		
		move $t1 $a1 #matrix destination
		add $t1 $t1 $t9 #move to correct col
	
		li $t8 0 #current col
		transpose_loop_inner:
			beq $t8 $a3 transpose_loop_inner.done
			
			lbu $t2 ($t0) #get source character 
			
			sb $t2 ($t1) #store character
			
			add $t1 $t1 $a2 #move to next output
			addi $t0 $t0 1 #move to next character
			addi $t8 $t8 1 #increment counter
		j transpose_loop_inner
		transpose_loop_inner.done:
		
		addi $t9 $t9 1 #increment counter
	j transpose_loop_outer
	transpose_loop_outer.done:
	
	li $v0 0
	jr $ra
	
	bad_input.tp:
	li $v0 -1
	jr $ra

# Part VII
encrypt:
	#a0 adfgvx grid
	#a1 plaintext
	#a2 keyword
	#a3 ciphertext
	
	addi $sp $sp -36 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $s7 32($sp)
	
	move $s0 $a0
	move $s1 $a1
	move $s2 $a2
	move $s3 $a3
	
	move $t1 $s1 #plaintext
	li $t9 0 #size
	
	move $t4 $s2 #keyword
	li $t5 0 #count
	count_key:
		lbu $t6 ($t4)
		beqz $t6 count_key.done
		
		addi $t4 $t4 1 #next character
		addi $t5 $t5 1 #increment counter
	j count_key
	count_key.done:
	
	#t5 size of keyword
	
	count_size:
		lbu $t2 ($t1)
		beqz $t2 count_size.done
		addi $t9 $t9 1 #count
		addi $t1 $t1 1 #move to next character
	j count_size
	count_size.done:
	
	li $t8 2
	mul $t9 $t9 $t8
	
	div $t9 $t5
	
	mfhi $t7
	
	beqz $t7 no_remainder.enc
	sub $t9 $t9 $t7
	add $t9 $t9 $t5
	no_remainder.enc:
	
	#t9 size of heap
	
	move $a0 $t9 #allocate heap memory
	li $v0 9
	syscall
	
	move $s4 $v0 #address of heap memory
	move $t0 $v0 #address of heap memory
	
	li $t8 0
	asterisk:
		beq $t8 $t9 asterisk.done
		li $t1 '*'
		sb $t1 ($t0)
		addi $t0 $t0 1
		addi $t8 $t8 1
	j asterisk
	asterisk.done:
	
	move $s5 $t9 

	#s0 adfg grid
	#s1 plaintext
	#s2 keyword
	#s3 ciphertext
	#s4 address of heap
	#s5 size of heap 
	
	move $a0 $s0
	move $a1 $s1
	move $a2 $s4
	jal map_plaintext

	move $t0 $s2
	li $s7 0
	count_keyword:
		lbu $t1 ($t0)
		beqz $t1 count_keyword.done
		
		addi $s7 $s7 1
		addi $t0 $t0 1
	j count_keyword
	count_keyword.done:
	
	div $s5 $s7
	mflo $s6 

	move $a0 $s4 #heap
	move $a1 $s6 #num rows
	move $a2 $s7 #num col
	move $a3 $s2 #key
	addi $sp $sp -4
	li $t0, 1 #element size
	sw $t0, 0($sp)
	jal key_sort_matrix
	addi $sp $sp 4
			
	move $a0 $s4 #heap
	move $a1 $s3 #ciphertext
	move $a2 $s6 #num rows
	move $a3 $s7 #num col
	jal transpose
	
	move $t0 $s3
	add $t0 $t0 $s5
	
	li $t1 0
	sb $t1 ($t0) #null terminate

	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $s7 32($sp)
	
	addi $sp $sp 36 #registers times 4

	jr $ra

# Part VIII
lookup_char:
	li $t2 0 #row counter

	li $t0 'A'
	beq $a1 $t0 good_input1.lc 
	
	addi $t2 $t2 1

	li $t0 'D'
	beq $a1 $t0 good_input1.lc 
	
	addi $t2 $t2 1

	li $t0 'F'
	beq $a1 $t0 good_input1.lc 
	
	addi $t2 $t2 1
	
	li $t0 'G'
	beq $a1 $t0 good_input1.lc 
	
	addi $t2 $t2 1
	
	li $t0 'V'
	beq $a1 $t0 good_input1.lc 

	addi $t2 $t2 1
	
	li $t0 'X'
	beq $a1 $t0 good_input1.lc 
	
	li $v0 -1
	jr $ra
	
	good_input1.lc:	
	
	li $t3 0
	
	li $t1 'A'
	beq $a2 $t1 good_input2.lc 
	
	addi $t3 $t3 1
	
	li $t1 'D'
	beq $a2 $t1 good_input2.lc 
	
	addi $t3 $t3 1
	
	li $t1 'F'
	beq $a2 $t1 good_input2.lc 
	
	addi $t3 $t3 1
	
	li $t1 'G'
	beq $a2 $t1 good_input2.lc 
	
	addi $t3 $t3 1
	
	li $t1 'V'
	beq $a2 $t1 good_input2.lc 
	
	addi $t3 $t3 1
	
	li $t1 'X'
	beq $a2 $t1 good_input2.lc
	
	li $v0 -1
	jr $ra
	
	good_input2.lc:	
	
	#a0 adf grid
	#a1 row_char
	#a2 col_char
	
	#t2 row index
	#t3 col index

	row_loop.enc:
		beqz $t2 row_loop.enc.done
		addi $a0 $a0 6
		addi $t2 $t2 -1
	j row_loop.enc
	row_loop.enc.done:
	
	add $a0 $a0 $t3
	
	li $v0 0
	
	lbu $v1 ($a0)

	jr $ra

# Part IX
string_sort:
	#a0 string
	li $t9 -1
	sort_string_outer:
		beqz $t9 sort_string_outer.done
		
		move $t0 $a0
		
		li $t9 0
		sort_string_inner:
			lbu $t1 ($t0)
			lbu $t2 1($t0)
			
			beqz $t2 sort_string_inner.done
			
			ble $t1 $t2 no_swap.string
			
			addi $t9 $t9 1
			
			sb $t1 1($t0)
			sb $t2 ($t0)
			
			no_swap.string:
			
			addi $t0 $t0 1
		j sort_string_inner
		sort_string_inner.done:
	j sort_string_outer
	sort_string_outer.done:
	
	jr $ra

# Part X
decrypt:
	addi $sp $sp -36 #registers times 4
	
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $s7 32($sp)
	
	move $s0 $a0 #adf grid
	move $s1 $a1 #ciphertext
	move $s2 $a2 #keyword
	move $s3 $a3 #plaintext
	
	move $t0 $s2
	li $t1 0
	count_keyword.dec:
		lbu $t2 ($t0)
		beqz $t2 count_keyword.dec.done
		
		addi $t0 $t0 1 #move to next char
		addi $t1 $t1 1 #increment count
	j count_keyword.dec
	count_keyword.dec.done:
	
	#t1 keyword length
	move $s5 $t1
	
	addi $t1 $t1 1 #null terminator space
	
	move $a0 $t1 #allocate heap memory
	li $v0 9
	syscall
	
	move $s4 $v0 #address of heap memory
	
	move $t2 $s2
	move $t4 $s4
	copy_loop.dec:
		lbu $t3 ($t2)
		beqz $t3 copy_loop.dec.done
		
		sb $t3 ($t4)
		
		addi $t2 $t2 1
		addi $t4 $t4 1
	j copy_loop.dec
	copy_loop.dec.done:
	
	li $t3 0
	sb $t3 ($t4) #null terminate
	
	move $a0 $s4
	jal string_sort
	
	move $a0 $s5 #allocate heap memory
	li $v0 9
	syscall
	
	move $s6 $v0 #address of int array
	
	move $t0 $s4 #source
	move $t1 $s6 #destination
	
	lookup_loop.dec:
		lbu $t2 ($t0)
		
		beqz $t2 lookup_loop.dec.done
		
		move $t3 $s2 #keyword
		li $t4 0
		lookup_char.dec:
			lbu $t5 ($t3)
			beq $t5 $t2 lookup_char.dec.done
			addi $t4 $t4 1
			addi $t3 $t3 1
		j lookup_char.dec
		lookup_char.dec.done:
		
#		addi $t4 $t4 48
		sb $t4 ($t1)
		
		addi $t0 $t0 1
		addi $t1 $t1 1
	j lookup_loop.dec
	lookup_loop.dec.done:
	
	li $t0 0
	move $t1 $s1
	count_cipher.dec:
		lbu $t2 ($t1)
		beqz $t2 count_cipher.dec.done
		addi $t0 $t0 1 #increment count
		addi $t1 $t1 1 #move next char
	j count_cipher.dec
	count_cipher.dec.done:
	
	#t0 length of ciphertext

	div $t0 $s5 
	
	mflo $t1 #num columns
	
	addi $t0 $t0 1 #null term
	move $a0 $t0 #allocate heap memory
	li $v0 9
	syscall

	move $s7 $v0 #address of ciphertext

	move $a0 $s1
	move $a1 $s7
	move $a2 $s5 #rows
	move $a3 $t1 #cols
	jal transpose	
	
	#s0 adf grid
	#s1 ciphertext
	#s2 keyword
	#s3 plaintext
	#s4 sorted keyword [on heap]
	#s5 length of keyword [num rows of ciphertext]	
	#s6 array of keyword indices [on heap]
	#s7 transposed ciphertext

	li $t0 0
	move $t1 $s1
	count_cipher2.dec:
		lbu $t2 ($t1)
		beqz $t2 count_cipher2.dec.done
		addi $t0 $t0 1 #increment count
		addi $t1 $t1 1 #move next char
	j count_cipher2.dec
	count_cipher2.dec.done:

	div $t0 $s5 

	move $a0 $s7 #matrix
	mflo $a1 #rows
	move $a2 $s5 #cols
	move $a3 $s6 #key
	addi $sp $sp -4
	li $t0 1 #element size
	sw $t0 0($sp)
	jal key_sort_matrix
	addi $sp $sp 4
	
	li $t0 0
	move $t1 $s1
	count_cipher3.dec:
		lbu $t2 ($t1)
		beqz $t2 count_cipher3.dec.done
		addi $t0 $t0 1 #increment count
		addi $t1 $t1 1 #move next char
	j count_cipher3.dec
	count_cipher3.dec.done:

	move $s6 $t0

	dec_loop:
		blez $s6 dec_loop.done
		
		lbu $t0 ($s7)
		lbu $t1 1($s7)
		
		li $t5 '*'
		beq $t0 $t5 dec_loop.done
		beq $t1 $t5 dec_loop.done
		
		move $a0 $s0
		move $a1 $t0
		move $a2 $t1
		jal lookup_char
		 
		move $t0 $v1
		
		sb $t0 ($s3)
		
		addi $s7 $s7 2 #move to next pair
		addi $s6 $s6 -2 #decrement counter
		addi $s3 $s3 1 #move to next destination
	j dec_loop
	dec_loop.done:
	
	li $t0 0
	sb $t0 ($s3)
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $s6 32($sp)
	
	addi $sp $sp 36 #registers times 4
	
	jr $ra
