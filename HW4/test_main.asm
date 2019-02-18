.data
map_filename: .asciiz "map3.txt"

# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"

map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
#map: .word 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 0x58585858 

.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0
.asciiz "Really, please don't mess with this string"
welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"


.text
print_player_info: #print "Pos=[3,14] Health=[4] Coins=[1]"
	la $t0 player
	
	lbu $t1 0($t0) #row
	lbu $t2 1($t0) #col
	lbu $t3 2($t0) #health
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
	
print_map:
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
	
	jr $ra

.globl main
main:

la $a0 map_filename
la $a1 map
la $a2 player
jal init_game

#la $a0 map
#li $a1 4 #row
#li $a2 4 #col
#li $a3 '@' #char
#jal is_valid_cell
#jal get_cell
#jal set_cell

la $a0 map
la $t0 player
lbu $a1 0($t0)  #row
lbu $a2 1($t0)  #col
jal reveal_area


la $a0 map
la $a1 player
li $a2 'L' #direction U D L R
#jal get_attack_target
#jal player_turn

la $a0 map
la $a1 player
li $a2 1
li $a3 10
#jal complete_attack
#jal monster_attacks
#jal player_move

la $a0 map
la $t0 player
lbu $a1 0($t0)  #row
lbu $a2 1($t0)  #col
la $a3 visited
#jal flood_fill_reveal


jal print_map
jal print_player_info

#move $a0 $v0
#li $v0 1
#syscall

#li $a0 '\n'
#li $v0 11
#syscall



li $v0 10
syscall

.include "hw4.asm"
