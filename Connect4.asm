# Group Members: Omar Suede, Abhinav Neelam, Lauren Contreras
# CS 2640 Final Project
# Welcome to our final project, Connect 4!
#$s0 register for heap address
#$s1 for array address
#$t0 =x, $t1=y
#$t2=matrixcounter $t3=displaycounter
.data
Table: .word 0xFF0000 # Red Chip
       .word 0xFFFF00 # Yellow Chip
       .word 0x0000FF # Blue grid
       .word 0xFFFFFF #White background for contrast
       
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
main:
 	
 	#convert the x and y and store it in martix conutr
 	la $s6,rows
 	lw $s6,0($s6)
 	la $s7,columns
 	lw $s7,0($s7)
 	li $t0,0
 	li $t1,0
 	loopcounter:#iterates through the matrix
 		loopi:
 			li $t1,0
 		loopj:
 			#insert code 
			addi $t1,$t1,1
			beq $t1,$s7,exit2#x
			j loopj
		exit2: 
			addi $t0,$t0,1
			beq $t0,$s6,exit1
			j loopi
		exit1:
		
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
		
	
