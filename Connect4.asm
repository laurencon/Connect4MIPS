# Group Members: Omar Suede, Abhinav Neelam, Lauren Contreras
# CS 2640 Final Project
# Welcome to our final project, Connect 4!
#$s0 register for heap address
#$s1 for heap constant 0x10040000
#$t0=x, $t1=y, $t2=color
#$t2=matrixcounter $t3=displaycounter

#unitwidth = 8
#w/h = 512
#actual w/h = 512 / 8 = 64

.data
Table: .word 0xFF0000 # Red Chip - Player 1
       .word 0xFFFF00 # Yellow Chip - Player 2
       .word 0x0000FF # Blue grid
       .word 0xFFFFFF #White background for contrast

heap: .word 0x10040000

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
	lw $s1, heap
	jal drawbackground

	jal DrawGrid
	
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
		jal Input
		jal drawTheChecker
		jal CheckForWin
	Player2:
		la $a0, msg6 # Displaying message to indicate the second player's turn
		li $v0, 4
		syscall
		
		li $v0, 5 # syscall to read integer
		syscall
		jal Input
		jal drawTheChecker
		jal CheckForWin
		
j main # to continue playing game until there's a winner or a tie
	
drawTheChecker:

	jal drawSquare
drawbackground:	
	lw $s0, heap
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

#Input - $(a1,a2) - (x,y)
#Input - $t2 = Color
#Input - $a3 = Box Width
#t4,t5 - temporary for x,y position
#t0,t1 - (y,x)

drawsquare:
	addi $sp,$sp,-4
	sw $ra, 0($sp)

	li $t0,0
	drawsquareloop:
 		yloop: # yloop
 			li $t1,0

		xloop: #xloop
 			#insert code
 			add $t5, $a2, $t0
 			add $t4, $a1, $t1
 			
 			jal convert2dto1d
			sw $t2, 0($t7)

			addi $t1,$t1,1
			beq $t1,$a3,xloopexit
			j xloop
		xloopexit:
			addi $t0,$t0,1
			beq $t0,$a3,yloopexit
			j yloop
		yloopexit:
		
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra

convert2dto1d:
	mul $t7,$t5,64
	add $t7,$t7,$t4
	
	mul $t7,$t7,4
	add $t7,$t7,$s1
	
	jr $ra
	
# Time to create the basic grid]
#s4 for white x
#s5 for white y
DrawGrid:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	li $a0,0
	li $t8, 0
	li $a3,8
	li $t2,0xffffff
	gridloop:#iterates through the matrix
 		gridloop1:
 			li $t9, 0
 			
 			
 		gridloop2:
 	 
			move $a1,$t9
			move $a2,$t8
			
			mul $a1,$a1,9
			mul $a2,$a2,9
			
			addi $a1,$a1,1
			addi $a2,$a2,1
			
 			jal drawsquare
 			
			addi $t9,$t9,1
			beq $t9,7,gridexit1
			
			j gridloop2
		gridexit1: 
			addi $t8,$t8,1
			beq $t8,6,gridexit2
			j gridloop1
		gridexit2:
		
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra

CheckForWin:
	# Connect 4 has 3 possible ways to win
	# 1. Vertical
	# 2. Horizontal
	# 3. Diagonal (including positive and negative slope)
	# $s4 = 4, how many tokens we need to WIN
	
	li $t0, 0 #initializing i
	loopi:
		li $t1, 0 # initializing j
		
		loopj:
			li $t4, 0 $initializing k
			
			loopk:
				
				add $s5, $t1, $t4 # $s5 = j + k
				add $s3, $t0, $t4 # $s3 = i + k
				sub $t7, $t1, $t4 # $t7 = j - k
		
				#value of array [i][j] = $t6
				# $s7 = columns ,from beginning of code
				# $s0 = base add
				$ a0 = the number of player (1 or 2) #may change later depending on how input is stored :)
				
				VerticalWin:
	
					mul $t6, $s3, $s7 # $t6 = (i+k) * columns
					add $t6, $t6, $t1
					add $t6, $s0, $t6 
					lb $t6, 0($t6)
					
					#insert code for argument if the array [i +k] [j] is not equal then go to HorizontalWin
					bne $t6, $a0, HorizontalWin
					addi $t8, $t8, 1
					
				HorizontalWin:
	
					mul $t6, $t0, $s7 # $t6 = i * columns
					add $t6, $t6, $s5
					add $t6, $s0, $t6 
					lb $t6, 0($t6)
					
					#insert code for argument if the array [i] [j + k] is not equal then go to DiagonalPositiveWin
					bne $t6, $a0, DiagonalPositiveWin
					addi $t9, $t9, 1
					
				DiagonalPositiveWin:
	
					mul $t6, $s3, $s7 # $t6 = (i+k) * columns
					add $t6, $t6, $s5
					add $t6, $s0, $t6 
					lb $t6, 0($t6)
					
					#insert code for argument if the array [i +k] [j + k] is not equal then go to DiagonalNegativeWin
					bne $t6, $a0, DiagonalNegativeWin
					addi $t5, $t5, 1
					
				DiagonalNegativeWin:
	
					mul $t6, $s3, $s7 # $t6 = (i+k) * columns
					add $t6, $t6, $t7
					add $t6, $s0, $t6 
					lb $t6, 0($t6)
					
					#insert code for argument if the array [i + k] [j - k] is not equal then go to HorizontalWin
					bne $t6, $a0, loopkContinued
					addi $t3, $t3, 1
			CheckFor4:
				beq $t8, $s4, Winner #may change based on how input is stored :)
				beq $t9, $s4, Winner
				beq $t5, $s4, Winner
				beq $t3, $s4, Winner
				
				# if none of these statements are true then we need to conclude with a tie
				
	loopiContinued:
		addi $t0, $t0, 1
		j loopi
		
		loopjContinued:
			addi $t1, $t1, 0
			j loopj
			
			loopkContinued:
				addi $t4, $t4, 1
				j loopk
				
				
Tie: 	la $a0, msg11
	li $v0, 4
	syscall
	li $v0, 10
	syscall
Winner:
	beq $a0, 1 Winner2
	la $a0, msg9
	li $v0, 4
	syscall
	
	Winner2:
		la $a0, msg10
		li $v0, 4
		syscall
		li $v0, 10
		syscall
	
exit:
	li $v0,10
	syscall
