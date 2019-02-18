.data
chars: .ascii "IQSP4TONLZJUGACHXVE73WKY"
#chars: .ascii "123456ABCDEF"

.text
.globl main
main:
la $a0, chars
li $a1, 6 #rows
li $a2, 4 #columns
li $a3, 0 #first col
addi $sp, $sp, -4
li $t0, 2  # second col
sw $t0, 0($sp)
jal swap_matrix_columns
addi $sp, $sp, 4

# expected: SQIPOT4NJZLUCAGHEVX7KW3Y
la $a0, chars
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
