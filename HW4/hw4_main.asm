.data
map_filename: .asciiz "map3.txt"
map: .word 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 
player: .word 0x58585858
visited: .word 0 0 0 0 0 0   

welcome_msg: .asciiz "Welcome to MIPSHack! Prepare for adventure!"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz "Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"

.text
print_map:	
	li $a0 '\n'
	li $v0 11
	syscall	
		
	la $t0 map
	
	lbu $t1 0($t0) #rows
	lbu $t2 1($t0) #cols
	
	addi $t0 $t0 2 #move past row/col
	
	li $t9 0
	row_loop.p:
		beq $t9 $t1 row_loop.p.done
		
		li $t8 0
		col_loop.p:
			beq $t2 $t8 col_loop.p.done

			lbu $t3 ($t0)
			
			li $t4 128
			bge $t3 $t4 print_blank.p
			
			move $a0 $t3
			li $v0 11
			syscall		
			
			j done.p
			
			print_blank.p:
			
			li $a0 ' '
			li $v0 11
			syscall
			
			done.p:	
			
			addi $t0 $t0 1
			addi $t8 $t8 1
		j col_loop.p
		col_loop.p.done:
		
		li $a0 '\n'
		li $v0 11
		syscall	
		
		addi $t9 $t9 1
	j row_loop.p
	row_loop.p.done:
	
	li $a0 '\n'
	li $v0 11
	syscall	
	
	jr $ra

print_player_info: #print "Pos=[3,14] Health=[4] Coins=[1]"
	la $t0 player
	
	lbu $t1 0($t0) #row
	lbu $t2 1($t0) #col
	lb $t3 2($t0) #health
	lbu $t4 3($t0) #coins
	
	la $a0 pos_str
	li $v0 4
	syscall
	
	move $a0 $t1 #row
	li $v0 1
	syscall
	
	li $a0 ','
	li $v0 11
	syscall
	
	move $a0 $t2 #col
	li $v0 1
	syscall
	
	la $a0 health_str
	li $v0 4
	syscall
	
	move $a0 $t3 #health
	li $v0 1
	syscall
	
	la $a0 coins_str
	li $v0 4
	syscall
	
	move $a0 $t4 #coins
	li $v0 1
	syscall
	
	li $a0 ']'
	li $v0 11
	syscall
	
	li $a0 '\n'
	li $v0 11
	syscall
	
	jr $ra
	
char_convert:
	li $t0 'w'
	bne $a0 $t0 not_w.cc
	li $v0 'U'
	jr $ra
	not_w.cc:
	
	li $t0 's'
	bne $a0 $t0 not_s.cc
	li $v0 'D'
	jr $ra
	not_s.cc:

	li $t0 'a'
	bne $a0 $t0 not_a.cc
	li $v0 'L'
	jr $ra
	not_a.cc:
	
	li $t0 'd'
	bne $a0 $t0 not_d.cc
	li $v0 'R'
	jr $ra
	not_d.cc:
	
	li $v0 -1
	jr $ra

.globl main
main:
	la $a0 welcome_msg
	li $v0 4
	syscall

	la $a0 map_filename
	la $a1 map
	la $a2 player
	jal init_game

	la $a0 map
	la $t0 player
	lbu $a1 0($t0)  #row
	lbu $a2 1($t0)  #col
	jal reveal_area

	la $s0 map
	la $s1 player
	li $s2 0 #move

	game_loop: #while player is not dead and move == 0:
		bnez $s2 game_loop.done
		
		lb $t0 2($s1) #health
		blez $t0 game_loop.done
		
		jal print_map 
		jal print_player_info 

		la $a0 your_move_str
		li $v0 4
		syscall

		li $v0 12 #read from keyboard
		syscall
		move $s3 $v0 #char entered
		
		li $s2 0 #move

		li $a0 '\n'
		li $v0 11
		syscall
		
		move $a0 $s3 #char entered
		jal char_convert
		
		move $s4 $v0 #output U D L R -1
		
		li $t0 -1
		beq $s4 $t0 skip_move
		
		move $a0 $s0 #map
		move $a1 $s1 #player
		move $a2 $s4 #char
		jal player_turn
		
		move $s2 $v0 #move
		
		j skip_flood
		
		skip_move:
		
		li $t0 'f'
		bne $s3 $t0 skip_flood
		
		move $a0 $s0 #map
		lbu $a1 0($s1) #row
		lbu $a2 1($s1) #col
		la $a3 visited
		jal flood_fill_reveal
		
		skip_flood:
		
		bnez $s2 skip_reveal
		
		move $a0 $s0 #map
		lbu $a1 0($s1) #row
		lbu $a2 1($s1) #col
		jal reveal_area
		
		skip_reveal:
	j game_loop
	game_loop.done:

	jal print_map
	jal print_player_info
	
	li $a0 '\n'
	li $v0 11
	syscall
	
	lb $t0 2($s1) #health
	blez $t0 died
	
	lbu $t0 3($s1) #coins
	li $t1 3
	blt $t0 $t1 failed

	#won
	la $a0 you_won_str
	li $v0 4
	syscall
	j exit

	failed:
	la $a0 you_failed_str
	li $v0 4
	syscall
	j exit

	died:
	la $a0 you_died_str
	li $v0 4
	syscall

	exit:
	
	li $v0 10
	syscall

.include "hw4.asm"
