.text

### Part I ###
index_of_car:
	#a0 array of car structs
	#a1 length
	#a2 start index
	#a3 year to find
	
	#exit if length less than or equal to zero
	bgtz $a1 length_greater_than_zero
	li $v0 -1
	jr $ra
	length_greater_than_zero:
	
	#exit if start index negative
	bgez $a2 index_not_negative
	li $v0 -1
	jr $ra
	index_not_negative:
	
	#exit if start index greater than or equal to length
	blt $a2 $a1 index_less_than_length
	li $v0 -1
	jr $ra
	index_less_than_length:
	
	#exit if year less than 1885
	li $t3 1885
	bgt $a3 $t3 year_greater_than_1885
	li $v0 -1
	jr $ra
	year_greater_than_1885:
	
	move $t0 $a0 #address of first struct
	move $t5 $a2 #counter
	li $t4 0 #index counter
	
	#advance to first index to search from
	advance_loop:
		beqz $t5 advance_loop.done
		addi $t0 $t0 16 #advance one index
		addi $t5 $t5 -1 #decrement counter
		addi $t4 $t4 1 #increase index count
	j advance_loop
	advance_loop.done:
	
	move $t6 $a1 #array size
	
	array_loop:
		beqz $t6 array_loop.end #leave after counter runs out
		
		li $t7 3 #counter
		loop:
			beqz $t7 loop.end #leave after counter runs out
			
			lw $t1 ($t0) #get address of string 	
			
			addi $t0 $t0 4 #advance to next string
			addi $t7 $t7 -1 #decrement counter
		j loop
		loop.end:
	
		lh $t1 ($t0) #get model year
		
		#exit if year matches
		bne $t1 $a3 year_not_found
		move $v0 $t4 #move index number into output
		jr $ra
		year_not_found:
		
		addi $t0 $t0 2 #advance to bit vector
		
		lbu $t1 ($t0) #get bit vector
		
		addi $t0 $t0 1 #advance to padding
		
		addi $t0 $t0 1 #advance to next item in array
		
		addi $t6 $t6 -1 #decrement array length counter
		
		addi $t4 $t4 1 #increase index count
	j array_loop
	array_loop.end:
	
	#car not found
	li $v0 -1
	jr $ra
	

### Part II ###
strcmp:
	move $t0 $a0 #str1
	move $t1 $a1 #str2
	
	li $t9 0 #sum
	
	lbu $t2 ($t0) #first character
	lbu $t3 ($t1) #second character
	
	beqz $t2 first_string_empty
	beqz $t3 second_string_empty
	
	compare_loop:
		lbu $t2 ($t0) #first character
		lbu $t3 ($t1) #second character
		
		beq $t2 $t3 characters_match
		sub $t8 $t2 $t3 # t8 = t2 - t3
		add $t9 $t9 $t8 # t9 += t8
		j string_ended
		characters_match:
		
		beqz $t2 string_ended
		beqz $t2 string_ended
		
		addi $t0 $t0 1 #advance first string pointer
		addi $t1 $t1 1 #advance second string pointer
	j compare_loop
	
	first_string_empty:
	fse_loop:
		lbu $t3 ($t1) #second character
		beqz $t3 string_ended
		addi $t9 $t9 -1 
		addi $t1 $t1 1 #advance second string pointer
	j fse_loop
	
	second_string_empty:
	sse_loop:
		lbu $t2 ($t0) #first character
		beqz $t2 string_ended
		addi $t9 $t9 1 
		addi $t0 $t0 1 #advance first string pointer
	j sse_loop
	
	string_ended:
	
	move $v0 $t9 

	jr $ra


### Part III ###
memcpy:
	#a0 source
	#a1 destination
	#a2 number of bytes to copy
	
	#exit if n less than or equal to zero
	bgtz $a2 n_greater_than_zero
	li $v0 -1
	jr $ra
	n_greater_than_zero:

	move $t9 $a2 #number of bytes to move
	move $t0 $a0 #source
	move $t1 $a1 #destination
	
	memcpy_loop:
		beqz $t9 memcpy_loop.done
		
		lbu $t3 ($t0) #source bit
		
		sb $t3 ($t1) #store bit
		
		#advance pointers
		addi $t0 $t0 1 
		addi $t1 $t1 1
		
		addi $t9 $t9 -1 #decrement counter
	j memcpy_loop
	memcpy_loop.done:
	
	li $v0 0
	
	jr $ra


### Part IV ###
insert_car:
	#exit if length less than zero
	bgez $a1 length_gte_zero
	li $v0 -1
	jr $ra
	length_gte_zero:
	
	#exit if index less than zero
	bgez $a3 index_gte_zero
	li $v0 -1
	jr $ra
	index_gte_zero:
	
	#exit if index less than length
	ble $a3 $a1 index_lte_length
	li $v0 -1
	jr $ra	
	index_lte_length:

	addi $sp $sp -24 #registers times 4
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $ra 20($sp)
	
	move $s0 $a0
	move $s1 $a1
	move $s2 $a2
	move $s3 $a3
	
	#a0 array of cars
	#a1 number of cars in array [length]
	#a2 new car to be inserted
	#a3 index at which to insert the new car
	
	move $t9 $s3 #index counter
	
	advance_to_insertion:
		beqz $t9 advance_to_insertion.done
		
		addi $s0 $s0 16 #advance one car length in the array
		
		addi $s1 $s1 -1 #logically remove the skipped cars from the array
		
		addi $t9 $t9 -1 #decrement counter
	j advance_to_insertion
	advance_to_insertion.done:
	
	#s0 points at insertion point
	#s1 number of cars LEFT in array
	#s2 new car
	#s3 index
	
	beqz $s1 insert_car_into_array
	
	move $t9 $s1 #counter
	
	addi $t9 $t9 -1 #decrement counter so it does not point past the array
	
	advance_to_end:
		beqz $t9 pointer_advanced
		addi $s0 $s0 16 #advance one element in array
		addi $t9 $t9 -1 #decrement counter
	j advance_to_end
	pointer_advanced:
	
	move $s4 $s1 #counter
	move_over_loop:
		beqz $s4 array_moved
			
			move $a0 $s0 #source
			
			#destination
			move $a1 $s0 
			addi $a1 $a1 16 
			
			li $a2 16 #number of bytes
			
			jal memcpy
		
		addi $s0 $s0 -16 #move back one element
		addi $s4 $s4 -1 #decrement counter
	j move_over_loop
	array_moved:
	
	addi $s0 $s0 16 #move forward to start of insertion
	
	insert_car_into_array:
	
	move $a0 $s2 #source		
	move $a1 $s0 #destination
	li $a2 16 #number of bytes
			
	jal memcpy	
	
	li $v0 0
	
	lw $ra 20($sp)
	lw $s4 16($sp)
	lw $s3 12($sp)
	lw $s2 8($sp)
	lw $s1 4($sp)
	lw $s0 0($sp)
	
	addi $sp $sp 24 
	
	jr $ra
	

### Part V ###
most_damaged:
	#exit if car length lte 0
	bgtz $a2 car_gtz
	li $v0 -1
	li $v1 -1
	jr $ra
	car_gtz:
	
	#exit if repair length lte 0
	bgtz $a2 repair_gtz
	li $v0 -1
	li $v1 -1
	jr $ra
	repair_gtz:

	addi $sp $sp -20
	
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	
	
	#a0 array of cars
	#a1 array of repairs
	#a2 number of elements in cars
	#a3 number of elements in repairs
	
	move $s0 $a0
	move $s2 $a2
	move $s3 $a3
	
	li $t0 0 #highest damage total
	li $t1 0 #index
	
	li $t8 0 #counter total cars
	damaged_car:
		beq $t8 $s2 damaged_car.done
		
		move $t9 $s3 #counter total repairs
		move $s1 $a1 #pointer repairs
		
		li $t4 0 #sum for damage
		repair_search:
			beqz $t9 repair_search.done
			
			lw $t3 ($s1) #load car pointer from repair
			bne $s0 $t3 no_match
			
			lh $t5 8($s1) #load damage
			
			add $t4 $t4 $t5 #add to total damages
			
			no_match: 
			
			addi $s1 $s1 12 #move to next repair
			
			addi $t9 $t9 -1 #decrement counter
		j repair_search
		repair_search.done:
		
		ble $t4 $t0 no_winner
		
		move $t0 $t4 #update damage total
		move $t1 $t8 #update index
		
		no_winner:
		
		addi $s0 $s0 16 #move to next car in car array
		addi $t8 $t8 1 #increment car counter
	j damaged_car
	damaged_car.done:
	
	move $v0 $t1 #move index
	move $v1 $t0 #move damage total
	
	lw $s3 16($sp)
	lw $s2 12($sp)
	lw $s1 8($sp)
	lw $s0 4($sp)
	lw $ra 0($sp)
	
	addi $sp $sp 20
	
	jr $ra


### Part VI ###
sort:
	#exit if length lte zero
	bgtz $a1 length_gt_zero	
	li $v0 -1 
	jr $ra
	length_gt_zero:
	
	addi $sp $sp -32
	
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	
	move $s0 $a0
	move $s1 $a1
	
	#s0 array of cars
	#s1 length
	
	li $s6 0 #sorted = false
	move $s5 $s1 #counter
	addi $s5 $s5 -1 #prevent running off the array
	
	sort_loop:
		bnez $s6 sorted #exit if sorted
		
		move $s2 $s0 #i car pointer
		move $s3 $s0 
		addi $s3 $s3 16 #i + 1 car
		
		#s2 i pointer
		#s3 i+1 pointer
		
		li $s6 1 #sorted = true
		
		addi $s2 $s2 16 #skip the first element
		addi $s3 $s3 16 #skip the first element
		
		li $s4 1 #counter
		sort_loop.odd:
			bge $s4 $s5 sort_loop.odd.done #exit when counter is zero
			
			lh $t1 12($s2) #load first car's year
			lh $t2 12($s3) #load second car's year
			
			ble $t1 $t2 no_swap.odd
			
			li $s6 0 #sorted = false
			
			addi $sp $sp -16 #make room on stack for car
			
			#move the second car onto the stack
			move $a0 $s3 #source
			move $a1 $sp #destination
			li $a2 16 #size
			jal memcpy
			
			#move the first car into second car's spot
			move $a0 $s2 #source
			move $a1 $s3 #destination
			li $a2 16 #size
			jal memcpy
			
			#move the second car from the stack to the first spot
			move $a0 $sp #source
			move $a1 $s2 #destination
			li $a2 16 #size
			jal memcpy
			
			addi $sp $sp 16 #move stack pointer back
			
			no_swap.odd:
			addi $s2 $s2 32 #move pointer by two cars
			addi $s3 $s3 32 #move pointer by two cars
			addi $s4 $s4 2 #increment counter by two to only do even
		j sort_loop.odd
		sort_loop.odd.done:
		

		move $s2 $s0 #i car pointer
		move $s3 $s0 
		addi $s3 $s3 16 #i + 1 car

		li $s4 0 #counter
		sort_loop.even:
			bge $s4 $s5 sort_loop.even.done #exit when counter is zero
			
			lh $t1 12($s2) #load first car's year
			lh $t2 12($s3) #load second car's year
			
			ble $t1 $t2 no_swap.even
			
			li $s6 0 #sorted = false

			addi $sp $sp -16 #make room on stack for car
			
			#move the second car onto the stack
			move $a0 $s3 #source
			move $a1 $sp #destination
			li $a2 16 #size
			jal memcpy
			
			#move the first car into second car's spot
			move $a0 $s2 #source
			move $a1 $s3 #destination
			li $a2 16 #size
			jal memcpy
			
			#move the second car from the stack to the first spot
			move $a0 $sp #source
			move $a1 $s2 #destination
			li $a2 16 #size
			jal memcpy
			
			addi $sp $sp 16 #move stack pointer back
			
			no_swap.even:
			addi $s2 $s2 32 #move pointer by two cars
			addi $s3 $s3 32 #move pointer by two cars
			addi $s4 $s4 2 #increment counter by two to only do even
		j sort_loop.even
		sort_loop.even.done:
	
	j sort_loop
	sorted:

	lw $s6 28($sp)
	lw $s5 24($sp)
	lw $s4 20($sp)
	lw $s3 16($sp)
	lw $s2 12($sp)
	lw $s1 8($sp)
	lw $s0 4($sp)
	lw $ra 0($sp)
	
	addi $sp $sp 32
	
	li $v0 0
	
	jr $ra


### Part VII ###
most_popular_feature:
	#exit if length lte zero
	bgtz $a1 length_gt_zero.pop	
	li $v0 -1 
	jr $ra
	length_gt_zero.pop:
	
	#exit if features less than 1
	bgtz $a2 feature_positive
	li $v0 -1
	jr $ra
	feature_positive:
	
	#exit if greater than 15
	li $t0 15
	ble $a2 $t0 valid_feature
	li $v0 -1
	jr $ra
	valid_feature:
	
	addi $sp $sp -20
	
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	
	li $v0 -1 #default answer
	
	andi $t3 $a2 0x8 
	srl $t3 $t3 3 
	
	andi $t2 $a2 0x4
	srl $t2 $t2 2 
	
	andi $t1 $a2 0x2
	srl $t1 $t1 1 
	
	andi $t0 $a2 0x1
	
	li $s0 0 #convertible
	li $s1 0 #hybrid
	li $s2 0 #tinted
	li $s3 0 #gps
	
	li $t9 0 #counter
	car_feature_search:
		beq $t9 $a1 car_feature_search.done
		
		lbu $s4 14($a0) #load car feature
		
		beqz $t0 skip_convert
		andi $t4 $s4 0x1 #get specific feature
		beqz $t4 skip_convert
		addi $s0 $s0 1 #add one to total
		skip_convert:
		
		beqz $t1 skip_hybrid
		andi $t4 $s4 0x2 #get specific feature
		beqz $t4 skip_hybrid
		addi $s1 $s1 1 #add one to total
		skip_hybrid:
		
		beqz $t2 skip_tint
		andi $t4 $s4 0x4 #get specific feature
		beqz $t4 skip_tint
		addi $s2 $s2 1 #add one to total
		skip_tint:
		
		beqz $t3 skip_gps
		andi $t4 $s4 0x8 #get specific feature
		beqz $t4 skip_gps
		addi $s3 $s3 1 #add one to total
		skip_gps:
		
		addi $a0 $a0 16 #move to next car
		addi $t9 $t9 1 #increment counter
	j car_feature_search
	car_feature_search.done:
	
	bgtz $s0 has_features
	bgtz $s1 has_features
	bgtz $s2 has_features
	bgtz $s3 has_features
	li $v0 -1 
	j leave
	has_features:
	
	li $t6 -1 #best feature
	li $t7 0 #highest count

	blt $s0 $t7 no_winner.convert
	move $t7 $s0
	li $t6 0
	no_winner.convert:
	
	blt $s1 $t7 no_winner.hybrid
	move $t7 $s1
	li $t6 1
	no_winner.hybrid:
	
	blt $s2 $t7 no_winner.tint
	move $t7 $s2
	li $t6 2
	no_winner.tint:
	
	blt $s3 $t7 no_winner.gps
	move $t7 $s3
	li $t6 3
	no_winner.gps:
	
	#t6 winning feature
	#t7 highest count
	
	#test if gps
	li $t8 3
	bne $t8 $t6 not_gps
	li $v0 8
	j leave
	not_gps:
	
	#test if tint
	li $t8 2
	bne $t8 $t6 not_tint
	li $v0 4
	j leave
	not_tint:
	
	#test if hybrid
	li $t8 1
	bne $t8 $t6 not_hybrid
	li $v0 2
	j leave
	not_hybrid:
	
	#must be convertible
	li $v0 1
	
	leave:
	
	lw $s4 16($sp)
	lw $s3 12($sp)
	lw $s2 8($sp)
	lw $s1 4($sp)
	lw $s0 0($sp)
	
	addi $sp $sp 20
	
	jr $ra
	

### Optional function: not required for the assignment ###
transliterate:
	#a0 character
	#a1 transliterate_str
	
	li $t0 0 
	
	trans_loop:
		lbu $t1 ($a1) #get character in trans string
		
		beq $a0 $t1 trans_found #exit if matched
		
		addi $t0 $t0 1 #increment index counter
		addi $a1 $a1 1 #move to next character in trans string
	j trans_loop
	trans_found:
	
	#divide by 10 to get remainder
	li $t2 10
	div $t0 $t2 
	
	mfhi $v0 #remainder
	
	jr $ra


### Optional function: not required for the assignment ###
char_at:
	li $v0, -200
	li $v1, -200

	jr $ra


### Optional function: not required for the assignment ###
index_of:
	li $v0, -200
	li $v1, -200

	jr $ra


### Part VIII ###
compute_check_digit:
	addi $sp $sp -24

	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	
	move $s0 $a0
	move $s1 $a1
	move $s2 $a2
	move $s3 $a3
	
	#s0 VIN 
	#s1 map
	#s2 weights
	#s3 transliterate_str

	li $s4 0 #sum
	vin_char_loop:
		lbu $t0 ($s0) #get next character
		
		beqz $t0 vin_done 
		
		#TO DO PROCESS CHARACTER
		
		move $a0 $t0 
		move $a1 $s3
		jal transliterate
		
		move $t0 $v0 #transliterated character 	
		
		lbu $t1 ($s2) #get next weight IN ASCII
		
		li $t2 88 # ASCII FOR X
		bne $t1 $t2 not_x  
		addi $t1 $t1 -30 #to get to -78 to yield 10		
		not_x:
		addi $t1 $t1 -48 #convert from ASCII
		
		mul $t0 $t0 $t1 #multiply by weight

		add $s4 $s4 $t0 #add to sum

		addi $s2 $s2 1 #move to next weight
		addi $s0 $s0 1 #move to next character		
	j vin_char_loop
	vin_done:
	
	li $t0 11
	div $s4 $t0
	
	mfhi $v0
	
	addi $v0 $v0 48 #convert to ASCII
	
	lw $s4 20($sp)
	lw $s3 16($sp)
	lw $s2 12($sp)
	lw $s1 8($sp)
	lw $s0 4($sp)
	lw $ra 0($sp)
	
	addi $sp $sp 24
	
	jr $ra	
