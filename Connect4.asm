# Group Members: Omar Suede, Abhinav Neelam, Lauren Contreras
# CS 2640 Final Project
# Welcome to our final project, Connect 4!
#$s0 register for heap address
#$s1 for array address
#$t0=x, $t1=y, $t2=color
#$t2=matrixcounter $t3=displaycounter

#unitwidth = 8
#w/h = 512
#actual w/h = 512 / 8 = 64

.data
Table: .word 0xFF0000 # Red Chip
       .word 0xFFFF00 # Yellow Chip
       .word 0x0000FF # Blue grid
       .word 0xFFFFFF #White background for contrast

heapstart: .word 0x10040000

array: .word 0:42 # 0=empty 1=player1, 2=player2
columns: .word 7 #$s7
rows: .word 6 #$s6
       msg1: .asciiz "\nWelcome to our game Connect 4! The first player is gonna have the first turn."
       msg2: .asciiz "\nPlease enter a number from 1-7 to indicate which column you'd like to drop the checker in."
       msg3: .asciiz "\nAfter the checker is dropped in then Player 2 can go."
       msg4: .asciiz "\nHave fun and good luck! :)"
       msg5: .asciiz "\nIt's player 1's turn: "
       msg6: .asciiz "\nIt's player 2's turn: "
       msg7: .asciiz "Choose a number between 1-7:\n"
       msg8: .asciiz "Column is full, please choose again.\n"
       msg9: .asciiz "The winner is player 1! Congrats!\n"
       msg10: .asciiz "The winner is player 2! Congrats!\n"
       msg11: .asciiz "It's a tie!\n"
       newl: .asciiz "\n"
       space: .asciiz " "
.text
convert2dto1d:
	mul $t2,$t1,$s7
	add $t2, $t2,$t0
	add $t2,$t2,$s0

main:
	jal drawbackground
	j exit
 	#convert the x and y and store it in matrix counter
 	la $s6,rows
 	lw $s6,0($s6)
 	la $s7,columns
 	lw $s7,0($s7)
 	li $t0,0
 	li $t1,0
 	
 	loopcounter123:#iterates through the matrix
 		loopi123:
 			li $t1,0
 		loopj123:
 			#insert code 
			addi $t1,$t1,1
			beq $t1,$s7,exit2123#x
			j loopj123
		exit2123: 
			addi $t0,$t0,1
			beq $t0,$s6,exit1123
			j loopi123
		exit1123:
		
	la $a0, msg1 # Displaying all welcome messages to introduce the game to player
	li $v0, 4
	syscall 
	
	la $a0, msg2
	li $v0, 4
	syscall
	
	la $a0, msg3
	li $v0, 4
	syscall
	
	la $a0, msg4
	li $v0, 4
	syscall

	Player1:
		la $a0, msg5 # Displaying message to indicate the first player's turn
		li $v0, 4
		syscall
		
		li $v0, 5 # syscall to read integer
		syscall
	Player2:
		la $a0, msg6 # Displaying message to indicate the second player's turn
		li $v0, 4
		syscall
		
		li $v0, 5 # syscall to read integer
		syscall
	Tie: 	la $a0, msg11
		li $v0, 4
		syscall
		li $v0, 10
		syscall
	Winner:
		la $a0, msg9
		li $v0, 4
		syscall
		
		la $a0, msg10
		li $v0, 4
		syscall
		li $v0, 10
		syscall

drawbackground:	
	lw $s0, heapstart
	li $t2, 0x0000FF

	sw $t2, 0($s0)
	
	li $v0, 1
	li $a0, 0
	syscall
	
	li $t0,0
	loopcounter:
 		loopi:
 			li $t1,0
 		loopj:
 			sw $t2, 0($s0) 			
 			addi $s0,$s0,4
 			
			addi $t1,$t1,1
			beq $t1,64,exit2
			j loopj
		exit2: 
			addi $t0,$t0,1
			beq $t0,64,exit1
			j loopi
		exit1:

	jr $ra
# Time to create the basic grid
Grid:
	
exit:
	li $v0,10
	syscall