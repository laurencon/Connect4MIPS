# Group Members: Omar Suede, Abhinav Neelam, Lauren Contreras, Leonard Woo
# CS 2640 Final Project
# Welcome to our final project, Connect 4!
# $s0 register for heap address
# $s1 for heap constant 0x10040000
# $s2	board array address
# $s3	board array address - row major order
# $s4 	player 1 or 2
# $s5	total moves made counter
# $t0=x, $t1=y, $t2=color
# $t6=matrixcounter $t3=displaycounter

#unitwidth = 8
#w/h = 512
#actual w/h = 512 / 8 = 64

.data
player1color: .word 0xFF0000 # Red Chip - Player 1
player2color: .word 0xFFFF00 # Yellow Chip - Player 2

Table:
       .word 0x0000FF # Blue grid
       .word 0xFFFFFF #White background for contrast

heap: .word 0x10040000

array: 		.word 	0:42 # 0=empty 1=player1, 2=player2
rowmajor:	.word 	0:42 # 0=empty 1=player1, 2=player2

columns: 	.word 7 #$s7
rows: 		.word 6 #$s6
       msg1: .asciiz "\nWelcome to our game Connect 4!"
       msg2: .asciiz "\nPlease enter a number from 1-7 to indicate which column you'd like to drop the checker in: "
       msg3: .asciiz "\nAfter the checker is dropped in then Player 2 can go."
       msg4: .asciiz "\nHave fun and good luck! :)\n"
       msg5: .asciiz "\nIt's player 1's turn"
       msg6: .asciiz "\nIt's player 2's turn"
       msg7: .asciiz "Choose a number between 1-7:\n"
       msg8: .asciiz "Column is full, please choose again.\n"
       msg9: .asciiz "The winner is player 1! Congrats!\n"
       msg10: .asciiz "The winner is player 2! Congrats!\n"
       msg11: .asciiz "It's a tie!\n"
       msg12: .asciiz "The input is invalid, please enter a number from 1-7: "
       msg13: .asciiz "counter"
       msg14: .asciiz "loop\n"
       msg15: .asciiz "Column is full, please try another column: " 
       newl: .asciiz "\n"
       space: .asciiz " "
.text
main:
	la $s2, array
	#la $s3, rowmajor
	lw $s1, heap
	jal drawbackground
	jal DrawGrid
	
	jal drawTheChecker
	
 	#convert the x and y and store it in matrix counter
 	la $s6,rows
 	lw $s6,0($s6)
 	la $s7,columns
 	lw $s7,0($s7)
 	li $t0,0
 	li $t1,0
 	
	la $a0, msg1 # Displaying all welcome messages to introduce the game to player
	li $v0, 4
	syscall 
	
	la $a0, msg4
	li $v0, 4
	syscall
	
	j userinput
	

userinput:
# checks if the playervalue ($s4) is 0/1/2 then switches the player turn
# then prompts the player to choose the column number
# checks for valid column # and if column is not full
# writes the playervalue to the array and exits
	# temporary registers used. values not saved.
	# t4 counter
	# t6 address of row major board element
	# t7 temp value
	# t8 address of board element
	# t9 temp value

	# check if playervalue is 0,1,2
	checkplayerturn:
		beq $s4, 0, player1
		beq $s4, 1, player2
		beq $s4, 2, player1
	
		player1:
			li $s4, 1
			la $a0, msg5
			li $v0, 4
			syscall
			
			#load player1 color into $t2
			la $t2, player1color
			lw $t2, 0($t2)
			
			#li $t2, 0xFF0000
			j promptinput
	
		player2:
			li $s4, 2
			la $a0, msg6
			li $v0, 4
			syscall
			
			#load player1 color into $t2
			la $t2, player2color
			lw $t2, 0($t2)		
		
	promptinput:
		la $a0, msg2
		li $v0, 4
		syscall

	collectinput:
		# get user input and store in $t9
		li $v0, 5
		syscall
		move $t9, $v0
	
		# check if user input is out of bounds
		blt $t9, 1, invalidinput
		bgt $t9, 7, invalidinput
		j checkcolumn
	
		invalidinput:
			la $a0, msg12
			li $v0, 4
			syscall
			j collectinput
	
		checkcolumn:
			# save column to x ($t0)
			la $t0, ($t9)
			# ! counter iterator 
			li $t4, 1
		
			# find array index of the first element in specified column
			#mul $t9, $t9, 6
			#sub $t9, $t9, 6
			# multiply index by 4
			#mul $t9, $t9, 4
			# get address of array element
			#add $t8, $s2, $t9
			
			# rowmajor index = (6-y)*7+x-1
			li $t7, 6		# $t7 = 6
			sub $t9, $t7, $t4	# 6 - y
			mul $t9, $t9, 7		# *7
			add $t9, $t9, $t0	# +x
			sub $t9, $t9, 1		# +1
			mul $t9, $t9, 4
			# get address of array element
			add $t8, $s2, $t9



		checkempty:
			# load value of array index
			lw $t7, ($t8)
	
			# if element is 0, store user number in array
			bne $t7, 0 , nextelement
			
				# if there is an empty spot in the column:	
				# stores player value 1 or 2 into array.
				sw $s4, ($t8)
				# ! CHANGED ! stores the (counter value + 1) as y value to $t1
				#add $t1, $t4, 1
				# stores counter value as y value to $t1
				la $t1, ($t4)
				
				#writetorowmajor:
				# rowmajor index = (6-y)*7+x-1
				#	li $t7, 6		# $t7 = 6
				#	sub $t9, $t7, $t1
				#	mul $t9, $t9, 7
				#	add $t9, $t9, $t0
				#	sub $t9, $t9, 1
				#	
				#	# add to index of non-row-order array instead. conflicts with $s3
				#	add $t9, $t9, 42
				#	
				#	# multiply index by 4 
				#	mul $t9, $t9, 4
				#	# get address in rowmajor array
				#	# add $t6, $s3, $t9	
				#	add $t6, $s2, $t9
				#		
				#	sw $s4, ($t6)
					
								
				li $v0,1
				move $a0, $t0
				syscall
				move $a0, $t1
				syscall
				
				move $a1,$t0
				move $a2,$t1
				
				subi $a1,$a1,1
				subi $a2,$a2,0
				
				mul $a2,$a2,-1
				addi $a2,$a2,6
				
				# !!! exit jump !!!
				# Determines where the function jumps to on success
				jal drawTheChecker
				jal CheckForWin
				j userinput
		
				nextelement:
					#add $t8, $t8, 4
					sub $t8, $t8, 28
					add $t4, $t4, 1
					
					# if counter < 7, keep looping
					# if counter == 7, error msg and break loop
					beq $t4, 7, columnfull
						j checkempty
					
					columnfull:
						la $a0, msg15
						li $v0, 4
						syscall
						j collectinput

drawTheChecker:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	
	li $a3,8
	
	mul $a1,$a1,9
	mul $a2,$a2,9
			
	addi $a1,$a1,1
	addi $a2,$a2,1
		
	jal drawsquare
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra

# placeholder checkforwin
checkforwin:
	j userinput
	# j exit
drawbackground:	
	lw $s0, heap
	li $t2, 0x0000FF
	sw $t2, 0($s0)
	li $t0,0
	backgroundloop:
 		backi:
 			li $t1,0
 		backj:
 			sw $t2, 0($s0) 			
 			addi $s0,$s0,4
 			
			addi $t1,$t1,1
			beq $t1,64,backexitj
			j backj
		backexitj: 
			addi $t0,$t0,1
			beq $t0,64,backexiti
			j backi
		backexiti:

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
	# $t2 = 4, how many tokens we need to WIN
	
	li $t0, 0 #initializing a
	li $t1, 0 # initializing b
	li $t2, 4 # $t2 = 4
	li $a1, 2 # $a1 = 2
	lw $s6, rows
	lw $s7, columns
	lw $s1, heap
	
	loopa:
		bge $t0, $s6, ContinueChecking # if a is >= than row than branch
		li $t1, 0 # initializing b
		
		loopb:
			bge $t1, $s7, loopaContinued # if b >= columns than branch
			li $t4, 0 #initializing c
			li $t8, 0 #incrementing for vertical
			li $t9, 0 #incrementing for horizontal
			li $t5, 0 #incrementing for positive
			li $t3, 0 #incrementing for negative
			
			
			loopc:
				bge $t4, $t2, CheckFor4 # if c >= 4 than branch
				add $s5, $t1, $t4 # $s5 = b + c
				add $s3, $t0, $t4 # $s3 = a + c
				sub $t7, $t1, $t4 # $t7 = b - c
		
				# value of array [a][b] = $t6
				# $s6 = rows
				# $s7 = columns ,from beginning of code
				# $s2 = base add
				# $s4 = the number of player (1 or 2) 
				HorizontalWin:
					bge $t1, $t2, VerticalWin # if b >= 4 than branch
					mul $t6, $t0, $s7 # $t6 = a * columns
					add $t6, $t6, $s5
					add $t6, $s1, $t6 
					lb $t6, 0($t6)
					
					# if the array [a] [b + c] is not equal then go to vertical
					bne $t6, $s4, VerticalWin
					addi $t9, $t9, 1
					
				VerticalWin:
					bge $t0, $a1, DiagonalPositiveWin # if a >= 2 then branch
					mul $t6, $s3, $s7 # $t6 = (a+c) * columns
					add $t6, $t6, $t1
					add $t6, $s1, $t6 
					lb $t6, 0($t6)
					
					# if the array [a + c] [b] is not equal then go to HorizontalWin
					bne $t6, $s4, DiagonalPositiveWin
					addi $t8, $t8, 1
					
				
				DiagonalPositiveWin:
					bge $t0, $a1, DiagonalNegativeWin # if a >= 2 than branch
					bge $t1, $t2, DiagonalNegativeWin # if b >= 4 than branch
					mul $t6, $s3, $s7 # $t6 = (a+c) * columns
					add $t6, $t6, $s5 
					add $t6, $s1, $t6 
					lb $t6, 0($t6)
					
					# if the array [a +c] [b + c] is not equal then go to DiagonalNegativeWin
					bne $t6, $s4, DiagonalNegativeWin
					addi $t5, $t5, 1
					
				DiagonalNegativeWin:
					bge $t0, $a1, loopcContinued # if a >= 2 than branch
					ble $t1, $a1, loopcContinued # if b <= 2 than branch
					mul $t6, $s3, $s7 # $t6 = (a+c) * columns
					add $t6, $t6, $t7
					add $t6, $s1, $t6 
					lb $t6, 0($t6)
					
					# if the array [i + k] [j - k] is not equal then go to HorizontalWin
					bne $t6, $s4, loopcContinued
					addi $t3, $t3, 1
					
					loopcContinued:
						addi $t4, $t4, 1
						j loopc
		
			CheckFor4:
				beq $t8, $t2, Winner 
				beq $t9, $t2, Winner
				beq $t5, $t2, Winner
				beq $t3, $t2, Winner
				addi $t1, $t1, 1
				j loopb
				
		loopaContinued:
			addi $t0, $t0, 1
			j loopa
			
				
	# if none of these statements are true then we need to conclude with a tie
	ContinueChecking:
				
		jr $ra
			
CheckForTie:
	li $s4, 0
	li $t0, 0
	
	loopaTie:
		bge $t0, $s6, Tie
		li $t1, 0
		
		loopbTie:
			bge $t1, $s7, continuedTie
			mul $t6, $t0, $s7
			add $t6, $t6, $t1
			add $t6, $s0, $t6
			lb $t6, 0($t6)
			
			beq $t6, $s4, exitNoTie
			addi $t1, $t1, 1
			j loopbTie
			
	continuedTie:
		addi $t0, $t0, 1
		j loopaTie
			
	exitNoTie:
		jr $ra
				
				
				
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
