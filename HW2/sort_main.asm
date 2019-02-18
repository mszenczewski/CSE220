.include "sort_data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
sort_output: .asciiz  "sort output: "

.text
.globl main
main:
la $a0, sort_output
li $v0, 4
syscall
la $a0, all_cars
li $a1, 12
jal sort
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall

la $t0 all_cars
la $t1 sorted_all_cars

li $t9 12 #counter

test_loop:
	beqz $t9 test_done
	
	lw $t2 ($t0)
	lw $t3 ($t1)
	
	bne $t2 $t3 failed
	
	lw $t2 4($t0)
	lw $t3 4($t1)
	
	bne $t2 $t3 failed
	
	lw $t2 8($t0)
	lw $t3 8($t1)
	
	bne $t2 $t3 failed
	
	lh $t2 12($t0)
	lh $t3 12($t1)
	
	bne $t2 $t3 failed

	addi $t0 $t0 16
	addi $t1 $t1 16
	addi $t9 $t9 -1
j test_loop
test_done:


la $t0 all_cars
la $t1 sorted_all_cars

li $t9 12 #counter
print_loop:
	beqz $t9 print_done
	
	lw $a0 0($t0)
	li $v0 4
	syscall

	li $a0 ' '
	li $v0 11
	syscall
	
	lw $a0 4($t0)
	li $v0 4
	syscall
	
	li $a0 ' '
	li $v0 11
	syscall
	
	lw $a0 8($t0)
	li $v0 4
	syscall
	
	li $a0 ' '
	li $v0 11
	syscall
	
	lh $a0 12($t0)
	li $v0 1
	syscall
	
	li $a0 '\n'
	li $v0 11
	syscall
	
	addi $t0 $t0 16
	addi $t1 $t1 16
	addi $t9 $t9 -1
j print_loop
print_done:

li $v0, 10
syscall

failed:
	li $v0 11
	li $a0 'F'
	syscall

	li $v0 11
	li $a0 '\n'
	syscall
	
	li $v0 10
	syscall
