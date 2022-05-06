

#$s0 register for heap address
#$s1 for heap constant 0x10040000

# $s2	board array address
# $s3	win array address
# $s4 	player 1 or 2
# $s5	total moves made counter

.data

array: .word 0:42

win: .word 		# vertical
			0,1,2,3,1,2,3,4,2,3,4,5,
			6,7,8,9,7,8,9,10,8,9,10,11,
			12,13,14,15,13,14,15,16,14,15,16,17,
			18,19,20,21,19,20,21,22,20,21,22,23,
			24,25,26,27,25,26,27,28,26,27,28,29,
			30,31,32,33,31,32,33,34,32,33,34,35,
			36,37,38,39,37,38,39,40,38,39,40,41,
			# horizontal
			0,6,12,18,6,12,18,24,12,18,24,30,18,24,30,36,
			1,7,13,19,7,13,19,25,13,19,25,31,19,25,31,37,
			2,8,14,20,8,14,20,26,14,20,26,32,20,26,32,38
			3,9,15,21,9,15,21,27,15,21,27,33,21,27,33,39,
			4,10,16,22,10,16,22,28,16,22,28,34,22,28,34,40,
			5,11,17,23,11,17,23,29,17,23,29,35,23,29,35,41
			# diagonal
			2,9,16,23,
			1,8,15,22,8,15,22,29,
			0,7,14,21,7,14,21,28,14,21,28,35,
			6,13,20,27,13,20,27,34,20,27,34,41,
			12,19,26,33,19,26,33,40,
			18,25,32,39,	
			# diagonal
			3,8,13,18,
			4,9,14,19,9,14,19,24,
			5,10,15,20,10,15,20,25,15,20,25,30,
			11,16,21,26,16,21,26,31,21,26,31,36,
			17,22,27,32,22,27,32,37,
			23,28,33,38

       msg1: .asciiz "\nWelcome to our game Connect 4!"
       msg2: .asciiz "\nPlease enter a number from 1-7 to indicate which column you'd like to drop the checker in: "
       msg3: .asciiz "\nAfter the checker is dropped in then Player 2 can go."
       msg4: .asciiz "\nHave fun and good luck! :)\n"
       msg5: .asciiz "\nIt's player 1's turn: "
       msg6: .asciiz "\nIt's player 2's turn: "
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

#load address of arrays 
la $s2, array
la $s3, win

main: 

	la $a0, msg1
	li $v0, 4
	syscall
	la $a0, msg4
	li $v0, 4
	syscall
	
userinput:
	# t4 counter
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
			j promptinput
	
		player2:
			li $s4, 2
			la $a0, msg6
			li $v0, 4
			syscall
		
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
			la $t0, ($t9 )
		
			# find array index of the first element in specified column
			mul $t9, $t9, 6
			sub $t9, $t9, 6
			# multiply index by 4
			mul $t9, $t9, 4
	
			# get address of array element
			add $t8, $s2, $t9

			# ! counter iterator
			li $t4, 0

		checkempty:
			# load value of array index
			lw $t7, ($t8)
	
			# if element is 0, store user number in array
			bne $t7, 0 , nextelement
			
				# if there is an empty spot in the column:	
				# stores player value 1 or 2 into array.
				sw $s4, ($t8)
				# stores the (counter value + 1) as y value to $t1
				add $t1, $t4, 1
				
				# !!! SUCCESSFUL EXIT JUMP !!!
				# Determines where the function jumps to on success
				j checkforwin
		
				nextelement:
					add $t8, $t8, 4
					add $t4, $t4, 1
			
					# if counter < 6, keep looping
					# if counter == 6, error msg and break loop
					beq $t4, 6, columnfull
						j checkempty
					
					columnfull:
						la $a0, msg15
						li $v0, 4
						syscall
						j collectinput

checkforwin:
	# $t3 	win sequence loop counter 
	# $t4 	iteration counter
	# $t5	summation counter
	# $t6	value of board element
	# $t7	value of win element
	# $t8	address of win element
	# $t9 	temp value
	
	# increment move counter
	add $s5, $s5, 1

	# reset counters
	li $t3, 0
	li $t4, 0
	li $t5, 0
	
	# address of win element $t8
	la $t8, ($s3)
	
	# start loop through win array
	check4elements:
	
		# exit checkforwin if iterated through entirety of win array
		beq $t3, 69, nowin
	
		# store value of win element to $t7
		lw $t7, ($t8)

	
		# convert win value to board address
		mul $t9, $t7, 4
		add $t9, $s2, $t9
		# load value of board address to $t6
		lw $t6, ($t9)
	
		# if board element is empty, skip to next win sequence
		beq $t6, 0, skipsequence
		j continuecheck
	
			skipsequence:
			mul $t9, $t4, 4
			sub $t9, $t9, 16
			# set address of next win sequence
			sub $t8, $t8, $t9
		
			# reset counters
			li $t4, 0
			li $t5, 0
			
			add $t3, $t3, 1
		
			j check4elements
	
			continuecheck:		
			
			# add board element value to summation counter
			add $t5, $t5, $t6
		
			# iterate counter
			add $t4, $t4, 1
		
			# set next win address
			add $t8, $t8, 4
		
			beq $t4, 4, checksumforwin
			j check4elements
			
				checksumforwin:
				beq $t5, 4, player1win
				beq $t5, 8, player2win


				# reset counters
				li $t4, 0
				li $t5, 0
				
				add $t3, $t3, 1
		
				j check4elements
	
	nowin:
	# check if 42 moves have been made and jumps to tie
	beq $s5, 42, tie
	
	# !!! Exit Jump - where to jump to if no win detected and board is not yet full !!!
	# if no tie, loop back to user input to start next player turn
	j userinput
	


player1win:
	la $a0, msg9
	li $v0, 4
	syscall
	j exit
	
player2win:
	la $a0, msg10
	li $v0, 4
	syscall
	j exit
	
tie:
	la $a0, msg11
	li $v0, 4
	syscall
	j exit

exit:
	li $v0,10
	syscall
