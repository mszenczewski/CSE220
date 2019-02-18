.include "data.asm"
.include "hw2.asm"

.data
nl: .asciiz "\n"
insert_car_output: .asciiz  "insert_car output: "
test_vin: .asciiz "AAAAABBBBBBBBBBCC"
test_car: .word test_vin
.word make_A
.word model_D
.byte 255, 255
.byte 12, 0

.align 2
expected_all_cars:

.word vin_00
.word make_A
.word model_A
.byte 110, 7
.byte 8
.byte 0

.word vin_01
.word make_D
.word model_B
.byte 115, 7
.byte 8
.byte 0

.word test_vin
.word make_A
.word model_D
.byte 255, 255
.byte 12, 0

.word vin_02
.word make_A
.word model_C
.byte 225, 7
.byte 12
.byte 0

.word vin_03
.word make_E
.word model_D
.byte 175, 7
.byte 10
.byte 0

.word vin_04
.word make_A
.word model_E
.byte 122, 7
.byte 5
.byte 0

.word vin_05
.word make_C
.word model_F
.byte 150, 7
.byte 10
.byte 0

.text
.globl main

main:
li $s5 6

la $a0, insert_car_output
li $v0, 4
syscall
la $a0, all_cars
move $a1, $s5
la $a2, test_car
li $a3, 2 #insertion index
jal insert_car
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall

li $v0 11
li $a0 '\n'
syscall

la $s6 all_cars
la $s7 expected_all_cars

move $t9 $s5
li $t8 4
mul $t9 $t9 $s5

test_loop:
	beqz $t9 test_done

	lw $t0 ($s6)
	lw $t1 ($s7)

	bne $t0 $t1 failed

	li $v0 11
	li $a0 'P'
	syscall

	li $v0 11
	li $a0 ' '
	syscall
	j skip_f

	failed:

	li $v0 11
	li $a0 'F'
	syscall

	li $v0 11
	li $a0 ' '
	syscall

	skip_f:

	addi $t9 $t9 -1 #counter
	addi $s6 $s6 4
	addi $s7 $s7 4
j test_loop
test_done:



li $v0, 10
syscall
