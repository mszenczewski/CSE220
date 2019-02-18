# Michael Szenczewski
# mszenczewski
# 111267857

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
init_game:
	addi $sp $sp -24 #registers times 4
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $s5 20($sp)
	
	move $s0 $a0
	move $s1 $a1
	move $s2 $a2 
	
	#s0 map file name
	#s1 map pointer
	#s2 player pointer
	
	move $a0 $s0
	li $a1 0
	li $a2 0
	li $v0 13
	syscall
	
	bltz $v0 failed.ig
	
	move $s3 $v0 #file descriptor
	
	addi $sp $sp -3 #make room on the stack
	
	move $a0 $s3
	move $a1 $sp #stack pointer
	li $a2 3
	li $v0 14
	syscall
	
	lbu $t0 1($sp)
	lbu $t1 ($sp)
	
	addi $t0 $t0 -48 #convert from ASCII
	addi $t1 $t1 -48 #convert from ASCII
	
	li $t2 10
	mul $t1 $t1 $t2 #multiply by 10
	
	add $t0 $t0 $t1 #total sum 
	
	addi $sp $sp 3 #move stack pointer back
	
	move $s4 $t0 
	
	#s4 number of rows
	
	addi $sp $sp -3 #make room on the stack
	
	move $a0 $s3
	move $a1 $sp #stack pointer
	li $a2 3
	li $v0 14
	syscall
	
	lbu $t0 1($sp)
	lbu $t1 ($sp)
	
	addi $t0 $t0 -48 #convert from ASCII
	addi $t1 $t1 -48 #convert from ASCII
	
	li $t2 10
	mul $t1 $t1 $t2 #multiply by 10
	
	add $t0 $t0 $t1 #total sum 
	
	move $s5 $t0 
	
	addi $sp $sp 3 #move stack pointer back
	
	sb $s4 ($s1)
	sb $s5 1($s1)
	
	addi $s1 $s1 2
	
	#s0 map file name
	#s1 map pointer POINTING AT FIRST MAP CHARACTER
	#s2 player pointer
	#s3 file descriptor	
	#s4 number of rows
	#s5 number of cols
	
	li $t9 0
	row_process.ig:
		beq $t9 $s4 row_process.ig.done
		add $sp $sp $s5
		addi $sp $sp 1 #new line
	
		move $a0 $s3
		move $a1 $sp #stack pointer
		move $a2 $s5
		addi $a2 $a2 1 #new line
		li $v0 14
		syscall
		
		li $t8 0
		move $t0 $sp
		process_char.ig:
			beq $s5 $t8 process_char.ig.done
			
			lbu $t1 ($t0)
			
			li $t2 '@'
			bne $t1 $t2 not_player.ig
						
			sb $t9 0($s2) #row 
			sb $t8 1($s2) #col

			not_player.ig:
			
			ori $t1 $t1 0x80 #change 7th bit... 0x80 is 10000000 in hex
			
			sb $t1 ($s1)

			addi $t0 $t0 1 #move input pointer
			addi $s1 $s1 1 #move output pointer
			addi $t8 $t8 1 #iterate counter
		j process_char.ig
		process_char.ig.done:
	
		sub $t0 $zero $s5
		addi $t0 $t0 -1 #new line
		add $sp $sp $t0
		
		addi $t9 $t9 1
	j row_process.ig
	row_process.ig.done:
	
	addi $sp $sp -3 #make room on the stack
	
	move $a0 $s3
	move $a1 $sp #stack pointer
	li $a2 3
	li $v0 14
	syscall

	lbu $t3 1($sp)
	lbu $t4 ($sp)

	addi $sp $sp 3 #move stack pointer back
	
	addi $t3 $t3 -48 #convert from ASCII
	addi $t4 $t4 -48 #convert from ASCII
	
	li $t5 10
	mul $t4 $t4 $t5
	add $t4 $t4 $t3
	
	sb $t4 2($s2) #health
	
	li $t5 0 
	sb $t5 3($s2) #coins
	
	j exit.ig
	
	failed.ig:
	
	li $v0 -1 
	
	exit.ig:
	

	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	addi $sp $sp 24 #registers times 4
	
	jr $ra


# Part II
is_valid_cell:
	#a0 map pointer
	#a1 row
	#a2 col
	
	bltz $a1 failed.ivc
	bltz $a2 failed.ivc
	
	lbu $t1 0($a0) #row
	lbu $t2 1($a0) #col
	
	bge $a1 $t1 failed.ivc
	bge $a2 $t2 failed.ivc
	
	li $v0 0
	
	j exit.ivc
	
	failed.ivc:
	
	li $v0 -1
	
	exit.ivc:
	
	jr $ra


# Part III
get_cell:
	addi $sp $sp -16 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)

	move $s0 $a0 #map pointer
	move $s1 $a1 #row
	move $s2 $a2 #col

	move $a0 $s0 #map
	move $a1 $s1 #row
	move $a2 $s2 #col
	jal is_valid_cell
	
	li $t0 -1
	beq $t0 $v0 failed.gc
	
	lbu $t0 0($s0) #map rows
	lbu $t1 1($s0) #map cols
	
	addi $s0 $s0 2 #move past row/col
	
	li $t9 0
	row_loop.gc:
		beq $t9 $s1 row_loop.gc.done
		add $s0 $s0 $t1 #move one row
		addi $t9 $t9 1 #iterate counter
	j row_loop.gc
	row_loop.gc.done:
	
	li $t9 0
	col_loop.gc:
		beq $t9 $s2 col_loop.gc.done
		addi $s0 $s0 1 #move one col
		addi $t9 $t9 1 #iterate counter
	j col_loop.gc
	col_loop.gc.done:
	
	lbu $v0 ($s0)
	
	j exit.gc
	
	failed.gc:
	
	li $v0 -1
	
	exit.gc:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	addi $sp $sp 16 #registers times 4
	
	jr $ra


# Part IV
set_cell:
	addi $sp $sp -20 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	
	move $s0 $a0 #map pointer
	move $s1 $a1 #row
	move $s2 $a2 #col
	move $s3 $a3 #char

	move $a0 $s0 #map
	move $a1 $s1 #row
	move $a2 $s2 #col
	jal is_valid_cell		
	
	li $t0 -1
	beq $t0 $v0 failed.sc
	
	lbu $t0 0($s0) #map rows
	lbu $t1 1($s0) #map cols
	
	addi $s0 $s0 2 #move past row/col
	
	li $t9 0
	row_loop.sc:
		beq $t9 $s1 row_loop.sc.done
		add $s0 $s0 $t1 #move one row
		addi $t9 $t9 1 #iterate counter
	j row_loop.sc
	row_loop.sc.done:
	
	li $t9 0
	col_loop.sc:
		beq $t9 $s2 col_loop.sc.done
		addi $s0 $s0 1 #move one col
		addi $t9 $t9 1 #iterate counter
	j col_loop.sc
	col_loop.sc.done:
	
	sb $s3 ($s0)
	
	li $v0 0
	
	j exit.sc
	
	failed.sc:
	
	li $v0 -1
	
	exit.sc:		
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	addi $sp $sp 20 #registers times 4
		
	jr $ra

# Part V
reveal_area:
	addi $sp $sp -24 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	
	move $s0 $a0 #map pointer
	move $s1 $a1 #row
	move $s2 $a2 #col
	
	addi $s1 $s1 -1 #row
	addi $s2 $s2 -1 #col 
	
	li $s3 3
	outer_loop.ra:
		beqz $s3 outer_loop.ra.done
		
		li $s4 3
		inner_loop.ra:
			beqz $s4 inner_loop.ra.done
			
			move $a0 $s0 #map
			move $a1 $s1 #row
			move $a2 $s2 #col
			jal is_valid_cell		
	
			li $t0 -1
			beq $t0 $v0 not_valid.ra
			
			move $a0 $s0 #map
			move $a1 $s1 #row
			move $a2 $s2 #col
			jal get_cell
			
			move $t0 $v0
			
			andi $t0 $t0 0x7F #change 7th bit... 0x7F is 01111111 in hex
			
			move $a0 $s0 #map
			move $a1 $s1 #row
			move $a2 $s2 #col
			move $a3 $t0 #char
			jal set_cell	
			
			not_valid.ra:
			
			addi $s2 $s2 1 #col
			addi $s4 $s4 -1 #counter
		j inner_loop.ra
		inner_loop.ra.done:
		
		addi $s1 $s1 1 #row
		addi $s2 $s2 -3 #move col back to start
		addi $s3 $s3 -1 #counter
	j outer_loop.ra
	outer_loop.ra.done: 
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	addi $sp $sp 24 #registers times 4
	
	jr $ra

# Part VI
get_attack_target:	
	addi $sp $sp -24 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	
	move $s0 $a0 #map 
	move $s1 $a1 #player
	move $s2 $a2 #direction
	
	lbu $s3 0($s1) #player row
	lbu $s4 1($s1) #player col
	
	li $t2 'U'
	bne $t2 $s2 not_u.gat
	addi $s3 $s3 -1 #one row up
	j cell_found.gat
	not_u.gat:
	
	li $t2 'D'
	bne $t2 $s2 not_d.gat
	addi $s3 $s3 1 #one row down
	j cell_found.gat
	not_d.gat:
	
	li $t2 'L'
	bne $t2 $s2 not_l.gat
	addi $s4 $s4 -1 #one col left
	j cell_found.gat
	not_l.gat:
	
	li $t2 'R'
	bne $t2 $s2 not_r.gat
	addi $s4 $s4 1 #one col right
	j cell_found.gat
	not_r.gat:

	j failed.gat
	cell_found.gat:
	
	move $a0 $s0 #map
	move $a1 $s3 #row
	move $a2 $s4 #col
	jal is_valid_cell
	
	li $t0 -1
	beq $v0 $t0 failed.gat
	
	#s0 map
	#s1 player
	#s2 direction
	#s3 target row
	#s4 target col
	
	move $a0 $s0 #map
	move $a1 $s3 #row
	move $a2 $s4 #col
	jal get_cell
	
	#v0 target
	
	li $t0 'm'
	beq $t0 $v0 exit.gat
	
	li $t0 'B'
	beq $t0 $v0 exit.gat
	
	li $t0 '/'
	beq $t0 $v0 exit.gat
	
	failed.gat:
	li $v0 -1
	
	exit.gat:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	addi $sp $sp 24 #registers times 4
	
	jr $ra


# Part VII
complete_attack:
	addi $sp $sp -20 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)

	move $s0 $a0 #map
	move $s1 $a1 #player
	move $s2 $a2 #target row
	move $s3 $a3 #target col
	
	move $a0 $s0 #map
	move $a1 $s2 #row
	move $a2 $s3 #col
	jal get_cell
	
	#v0 has m B \
	
	li $t0 'm'
	bne $t0 $v0 not_m.ca
	
	lb $t0 2($s1) #health
	addi $t0 $t0 -1 	
	sb $t0 2($s1)
	
	move $a0 $s0 #map
	move $a1 $s2 #row
	move $a2 $s3 #col
	li $a3 '$' #char
	jal set_cell
	
	j monster_killed.ca
	
	not_m.ca:
	
	li $t0 'B'
	bne $t0 $v0 is_door.ca
	
	lb $t0 2($s1) #health
	addi $t0 $t0 -2 
	sb $t0 2($s1)
	
	move $a0 $s0 #map
	move $a1 $s2 #row
	move $a2 $s3 #col
	li $a3 '*' #char
	jal set_cell
	
	j monster_killed.ca
	
	is_door.ca:

	move $a0 $s0 #map
	move $a1 $s2 #row
	move $a2 $s3 #col
	li $a3 '.' #char
	jal set_cell
	
	monster_killed.ca:
	
	lb $t0 2($s1) #health
	
	bgtz $t0 still_kickin.ca
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	lbu $a2 1($s1) #col
	li $a3 'X' #char
	jal set_cell
	
	still_kickin.ca:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	addi $sp $sp 20 #registers times 4
	
	jr $ra

damage_counter:
	#a0 value to test
	
	li $t0 'm'
	bne $t0 $a0 not_m.dc
	li $v0 1
	jr $ra
	not_m.dc:
	
	li $t0 'B'
	bne $t0 $a0 not_B.dc
	li $v0 2
	jr $ra
	not_B.dc:
	
	li $v0 0
	jr $ra

# Part VIII
monster_attacks:
	addi $sp $sp -16 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	
	move $s0 $a0 #map
	move $s1 $a1 #player
	
	li $s2 0 #damage
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	addi $a1 $a1 -1 #up one row	
	lbu $a2 1($s1) #col	
	jal get_cell
	
	move $a0 $v0
	jal damage_counter
	
	add $s2 $s2 $v0
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	addi $a1 $a1 1 #down one row	
	lbu $a2 1($s1) #col	
	jal get_cell
	
	move $a0 $v0
	jal damage_counter
	
	add $s2 $s2 $v0
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	lbu $a2 1($s1) #col
	addi $a2 $a2 1 #right one col		
	jal get_cell
	
	move $a0 $v0
	jal damage_counter
	
	add $s2 $s2 $v0
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	lbu $a2 1($s1) #col
	addi $a2 $a2 -1 #left one col		
	jal get_cell
	
	move $a0 $v0
	jal damage_counter
	
	add $s2 $s2 $v0
	
	move $v0 $s2
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	addi $sp $sp 16 #registers times 4
	
	jr $ra


# Part IX
player_move:
	addi $sp $sp -24 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	
	move $s0 $a0 #map
	move $s1 $a1 #player
	move $s2 $a2 #target row
	move $s3 $a3 #target col
	
	move $a0 $s0 #map
	move $a1 $s1 #player
	lbu $a2 0($s1) #row
	lbu $a3 1($s1) #col
	jal monster_attacks 
	
	lb $t0 2($s1) #health
	sub $t0 $t0 $v0
	sb $t0 2($s1)
	
	bgtz $t0 still_kickin.pm
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	lbu $a2 1($s1) #col
	li $a3 'X' #char
	jal set_cell
	
	li $v0 0
	j exit.pm	
	
	still_kickin.pm:
	
	move $a0 $s0 #map
	lbu $a1 0($s1) #row
	lbu $a2 1($s1) #col
	li $a3 '.' #char
	jal set_cell
	
	move $a0 $s0 #map
	move $a1 $s2 #row
	move $a2 $s3 #col
	jal get_cell
	
	move $s4 $v0 #target char
	
	move $a0 $s0 #map
	move $a1 $s2 #row
	move $a2 $s3 #col
	li $a3 '@' #char
	jal set_cell
	
	sb $s2 0($s1) #new row
	sb $s3 1($s1) #new col
	
	li $t0 '.'
	bne $t0 $s4 not_dot.pm
	
	li $v0 0
	j exit.pm
	
	not_dot.pm:

	li $t0 '$'
	bne $t0 $s4 not_coin.pm
	
	lbu $t1 3($s1) #coins
	addi $t1 $t1 1
	sb $t1 3($s1)
	
	li $v0 0
	j exit.pm
	
	not_coin.pm:

	li $t0 '*'
	bne $t0 $s4 not_gem.pm
	
	lbu $t1 3($s1) #coins
	addi $t1 $t1 5
	sb $t1 3($s1)
	
	li $v0 0
	j exit.pm
	
	not_gem.pm:

	li $t0 '>'
	bne $t0 $s4 not_exit.pm
	
	li $v0 -1
	j exit.pm
	
	not_exit.pm:

	li $v0 -100 #this should not be possible
	
	exit.pm:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	addi $sp $sp 24 #registers times 4
	
	jr $ra

get_target_coords:
	#a0 map
	#a1 player
	#a2 direction
	
	lbu $t1 0($a1) #row
	lbu $t2 1($a1) #col
	
	li $t0 'U'
	bne $t0 $a2 not_u.gtc
	
	addi $t1 $t1 -1 #move up one row
	
	move $v0 $t1
	move $v1 $t2 
	
	jr $ra
	
	not_u.gtc:
	
	li $t0 'D'
	bne $t0 $a2 not_d.gtc
	
	addi $t1 $t1 1 #move down one row
	
	move $v0 $t1
	move $v1 $t2 
	
	jr $ra
	
	not_d.gtc:
	
	li $t0 'L'
	bne $t0 $a2 not_l.gtc
	
	addi $t2 $t2 -1 #move left one col
	
	move $v0 $t1
	move $v1 $t2 
	
	jr $ra
	
	not_l.gtc:
	
	li $t0 'R'
	bne $t0 $a2 not_r.gtc
	
	addi $t2 $t2 1 #move right one col
	
	move $v0 $t1
	move $v1 $t2 
	
	jr $ra
	
	not_r.gtc:
	
	#this should never happen
	
	li $v0 -100
	li $v1 -100 
	jr $ra

# Part X
player_turn:
	li $t0 'U'
	beq $t0 $a2 valid_direction.pt
	
	li $t0 'D'
	beq $t0 $a2 valid_direction.pt
	
	li $t0 'L'
	beq $t0 $a2 valid_direction.pt
	
	li $t0 'R'
	beq $t0 $a2 valid_direction.pt
	
	li $v0 -1
	jr $ra
	
	valid_direction.pt:

	addi $sp $sp -24 #registers times 4
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)	
	sw $s4 20($sp)		
	
	move $s0 $a0 #map
	move $s1 $a1 #player
	move $s2 $a2 #direction
	
	move $a0 $s0 #map
	move $a1 $s1 #player
	move $a2 $s2 #direction
	jal get_target_coords
	
	move $s3 $v0 #target row
	move $s4 $v1 #target col
	
	move $a0 $s0 #map
	move $a1 $s3 #row
	move $a2 $s4 #col
	jal is_valid_cell
	
	li $t0 -1
	bne $t0 $v0 valid_target.pt
	
	li $v0 0
	j exit.pt
	
	valid_target.pt:
	
	move $a0 $s0 #map
	move $a1 $s3 #row
	move $a2 $s4 #col
	jal get_cell
	
	li $t0 '#'
	bne $t0 $v0 not_wall.pt
	
	li $v0 0
	j exit.pt
	
	not_wall.pt:
	
	move $a0 $s0 #map
	move $a1 $s1 #player
	move $a2 $s2 #direction
	jal get_attack_target
	
	li $t0 -1
	beq $t0 $v0 no_attack.pt
	
	move $a0 $s0 #map
	move $a1 $s1 #player
	move $a2 $s3 #row
	move $a3 $s4 #col
	jal complete_attack
	
	li $v0 0
	j exit.pt

	no_attack.pt:
	
	move $a0 $s0 #map
	move $a1 $s1 #player
	move $a2 $s3 #row
	move $a3 $s4 #col
	jal player_move
	
	exit.pt:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	addi $sp $sp 24 #registers times 4
	
	jr $ra
	
offsets:
	li $t0 0
	bne $a0 $t0 not_0.o
	li $v0 -1
	li $v1 0
	jr $ra
	not_0.o:
	
	li $t0 1
	bne $a0 $t0 not_1.o
	li $v0 1
	li $v1 0
	jr $ra
	not_1.o:
	
	li $t0 2
	bne $a0 $t0 not_2.o
	li $v0 0
	li $v1 -1
	jr $ra
	not_2.o:
	
	li $t0 3
	bne $a0 $t0 not_3.o
	li $v0 0
	li $v1 1
	jr $ra
	not_3.o:
	
	#this should never happen
	li $v0 0
	li $v1 0
	jr $ra

# Part XI
flood_fill_reveal:
	addi $sp $sp -36 #registers times 4
	sw $ra 0($sp)
	sw $fp 4($sp)
	sw $s0 8($sp)
	sw $s1 12($sp)
	sw $s2 16($sp)
	sw $s3 20($sp)
	sw $s4 24($sp)	
	sw $s5 28($sp)						
	sw $s6 32($sp)											
	
	move $s0 $a0 #map
	move $s1 $a1 #row
	move $s2 $a2 #col
	move $s3 $a3 #visited
	
	move $a0 $s0 #map
	move $a1 $s1 #row
	move $a2 $s2 #col
	jal is_valid_cell
	
	li $t0 -1
	bne $t0 $v0 valid.ffr
	
	li $v0 -1
	j exit.ffr
	
	valid.ffr:
	
	move $fp $sp
	
	addi $sp $sp -4 #push
	sb $s1 0($sp) #row
	sb $s2 1($sp) #col

	loop.ffr:
		beq $fp $sp loop.ffr.done
		
		lbu $s2 1($sp) #col
		lbu $s1 0($sp) #row
		addi $sp $sp 4 #pop
		
		move $a0 $s0 #map
		move $a1 $s1 #row
		move $a2 $s2 #col
		jal get_cell
		
		move $t0 $v0 
		
		andi $t0 $t0 0x7F #01111111 in hex
		
		move $a0 $s0 #map
		move $a1 $s1 #row
		move $a2 $s2 #col
		move $a3 $t0 #char
		jal set_cell
		
		li $s4 0
		pair_loop.ffr:
			li $t0 4
			beq $s4 $t0 pair_loop.ffr.done
			
			move $a0 $s4
			jal offsets
			
			move $s5 $s1
			move $s6 $s2
			
			add $s5 $s5 $v0
			add $s6 $s6 $v1
		
			move $a0 $s0 #map
			move $a1 $s5 #row
			move $a2 $s6 #col
			jal get_cell
		
			move $t0 $v0
			andi $t0 $t0 0x7F #01111111 in hex
			
			li $t1 '.'
			bne $t0 $t1 skip.ffr
			
			li $t0 0 #bitvector index
			
			lbu $t1 1($s0) #map cols
			
			mul $t2 $s5 $t1 #target row * number of cols
			
			add $t0 $t0 $t2 #move index over n rows
			
			add $t0 $t0 $s6 #move index over n cols
			
			#s0 map
			#s1 pre-offset row
			#s2 pre-offset col
			#s3 bitvector
			#s4 offset counter
			#s5 row + i
			#s6 col + j
			#v0 character target
			#t0 index of bitvector
			
			li $t1 8
			div $t0 $t1
			
			mfhi $t1 #which bit to select
			mflo $t2 #which byte to select
			
			move $t3 $s3 #bit vector
			
			add $t3 $t3 $t2 #move pointer to correct byte
			
			lbu $t4 ($t3) #load byte
			
			li $t5 7
			
			sub $t6 $t5 $t1 #7 - bit to select
			
			srlv $t4 $t4 $t6 #move desired bit to LSB
			
			andi $t4 $t4 0x1 #00000001
			
			bnez $t4 skip.ffr
			
			#set cell as visited
			
			#t1 bit
			#t3 pointer to the byte
			
			lbu $t4 ($t3) #byte
			
			li $t5 1 #00000001
			
			li $t6 7
			
			sub $t6 $t6 $t1 #7 - bit to select
			
			sllv $t5 $t5 $t6 #move one into desired place
			
			or $t4 $t4 $t5 #set the bit
			
			sb $t4 ($t3) #store the byte
			
			addi $sp $sp -4 #push
			sb $s5 0($sp) #row
			sb $s6 1($sp) #col
		
			skip.ffr:
			
			addi $s4 $s4 1
		j pair_loop.ffr
		pair_loop.ffr.done:
	
	j loop.ffr
	loop.ffr.done:
	
	li $v0 0

	exit.ffr:
	
	lw $ra 0($sp)
	lw $fp 4($sp)
	lw $s0 8($sp)
	lw $s1 12($sp)
	lw $s2 16($sp)
	lw $s3 20($sp)
	lw $s4 24($sp)
	lw $s5 28($sp)
	lw $s6 32($sp)
	addi $sp $sp 36 #registers times 4
	
	jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
