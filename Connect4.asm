# Group Members: Omar Suede, Abhinav Neelam, Lauren Contreras, Leonard Woo
# CS 2640 Final Project
# Welcome to our final project, Connect 4!
# $s0 register for heap address
# $s1 for heap constant 0x10040000
# $s2 board array address
# $s3 tiles placed
# $s4 player 1 or 2

#unitwidth = 8
#w / h = 512
#actual w / h = 512 / 8 = 64

.data
player1color: .word 0xFF0000 # Red Chip - Player 1
player2color: .word 0xFFFF00 # Yellow Chip - Player 2
background: .word 0x0000FF #grid color
basecolor: .word 0xbbbbbb #base color

heap: .word 0x10040000 #heap base address

columns: 	.word 7 # $s7
rows: 		.word 6 # $s6
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

array: 	.word 	0:42 # 0 = empty 1 = player1, 2 = player2

.text
main:
	li $s3,0

	la $s2, array
	lw $s1, heap
	jal drawbackground
	jal DrawGrid
	#draws background and grid
	
 	la $s6,rows
 	lw $s6,($s6)
 	la $s7,columns
 	lw $s7,($s7)
 	li $t0,0
 	li $t1,0
 	li $v1,4
 	
	la $a0, msg1 
	li $v0, 4
	syscall 
	
	la $a0, msg4
	li $v0, 4
	syscall
	# Displaying all welcome messages to introduce the game to player
	
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
					li $t7, 6		# $t7 = 6
					sub $t9, $t7, $t1
					mul $t9, $t9, 7
					add $t9, $t9, $t0
					sub $t9, $t9, 1
					
					# add to index of non-row-order array instead. conflicts with $s3
					add $t9, $t9, 42
					
					# multiply index by 4 
					mul $t9, $t9, 4
					# get address in rowmajor array
					# add $t6, $s3, $t9	
					add $t6, $s2, $t9
						
					sw $s4, ($t6)

				move $a1,$t0
				move $a2,$t1
				
				subi $a1,$a1,1
				subi $a2,$a2,0
				
				mul $a2,$a2,-1
				addi $a2,$a2,6
				#store x and y into a1 and a2, a1 and a2 need to be 0 transformed
				
				# !!! exit jump !!!
				# Determines where the function jumps to on success
				addi $sp,$sp,-8
				
				sw $a1,0($sp)
				sw $a2,4($sp)
				
				jal drawTheChecker
				#draws checker
				
				lw $a1,0($sp)
				lw $a2,4($sp) 
				addi $sp,$sp,8
				
				addi $s3,$s3,1
				jal CheckForWin #checks for possible win condition				
				j userinput #user input again
		
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
	#multiply by (8 + 1) or 1 pixel gap between each checker

	addi $a1,$a1,1
	addi $a2,$a2,1
	#To draw squares beginning past 1 pixel
		
	jal drawsquare
	lw $ra,0($sp)
	addi $sp,$sp, 4
	jr $ra

#$a1 - x
#$a2 - y
#$s7 - cols
#$v0 - return value of linear index
convert2dto1darray:
	addi $sp,$sp,-4
	sw $ra, 0($sp)

	mul $v0, $a2, $s7
	add $v0, $v0, $a1
	#converting 2d to 1d
		
	mul $v0, $v0, 4
	#multiply by 4 to align with word

	add $v0, $v0, $s2
	#add base address of array
	
	lw $ra, 0($sp)
	
	addi $sp,$sp,4
	jr $ra

#$a1 - x
#$a2 - y
#$s7 - cols

#$t3 - cx
#$t5 - cy
#$t6 - cx1
#$s0 - cy1

#$v0 - return count of consecutive tiles

#int checktop_bot(int arr[],int rows, int columns, int x, int y)
#{
#	int cx ,cy;
#   
#	for(cx =x,cy = y; cy>=0;cy--)
#	{
#		if(arr[convertytold(cx,cy,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx,cy,columns)]==0)
#		{
#			break;
#		}
#	}
#	int cx1,cy1;
#	for(cx1 =x,cy1 = y; cy1<rows;cy1++)
#	{
#		if(arr[convertytold(cx1,cy1,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx1,cy1,columns)]==0)
#		{
#			break;
#		}
#	}
    
    
#	return (cy1-cy)-1;
#}

#EXAMPLE C CODE TO CHECK VERTICAL WINS
#SIMILAR CODE IN CHECKTOPBOT LABEL

checktopbot:
	addi $sp,$sp,-12
	sw $ra, 0($sp)
	sw $a1, 4($sp) #store x
	sw $a2, 8($sp) #store y
	
	move $t3,$a1
	move $t5,$a2
	
	move $t6,$a1
	move $s0,$a2

	checktopbotloop1:
		blt $t5,$0,checktopbotloop2
	
		move $a1,$t3
		move $a2,$t5
		jal convert2dto1darray
	
		lw $v0, 0($v0)

		beq $v0,$0,checktopbotloop2
		bne $v0,$s4,checktopbotloop2
	
		addi $t5,$t5,-1
		j checktopbotloop1

	checktopbotloop2:
		bge $s0,$s6,checktopbotend
	
		move $a1,$t6
		move $a2,$s0
		jal convert2dto1darray
	
		lw $v0, 0($v0)
	
		beq $v0,$0,checktopbotend
		bne $v0,$s4,checktopbotend
	
		addi $s0,$s0,1
		j checktopbotloop2

	checktopbotend:
		move $v0, $s0
		sub $v0, $v0, $t5
		addi $v0, $v0, -1
	
	lw $ra, 0($sp)
	lw $a1, 4($sp) #restore x to a1
	lw $a2, 8($sp) #restore y to a2
	
	addi $sp,$sp,12
	jr $ra
#$a1 - x
#$a2 - y
#$s7 - cols

#$t3 - cx
#$t5 - cy
#$t6 - cx1
#$s0 - cy1
#$v0 - return count of consecutive tiles
# SIMILAR CODE TO TOPBOTTOM
checkleftright:

	addi $sp,$sp,-12
	sw $ra, 0($sp)
	sw $a1, 4($sp) #x
	sw $a2, 8($sp) #y
	
	move $t3,$a1
	move $t5,$a2
	
	move $t6,$a1
	move $s0,$a2

	checkleftrightloop1:
		blt $t3,$0,checkleftrightloop2
	
		move $a1,$t3
		move $a2,$t5
		jal convert2dto1darray	#$v0 - player id
	
		lw $v0, 0($v0)

		beq $v0,$0,checkleftrightloop2
		bne $v0,$s4,checkleftrightloop2
	
		addi $t3,$t3,-1
		j checkleftrightloop1

	checkleftrightloop2:
		bge $s6,$s7,checkleftrightend
	
		move $a1,$t6
		move $a2,$s0
		jal convert2dto1darray	#$v0 - player id
	
		lw $v0, 0($v0)
	
		beq $v0,$0,checkleftrightend
		bne $v0,$s4,checkleftrightend
	
		addi $t6,$t6,1
		j checkleftrightloop2

	checkleftrightend:
		move $v0, $t6
		sub $v0, $v0, $t3
		addi $v0, $v0, -1

	lw $ra, 0($sp)
	lw $a1, 4($sp) #x
	lw $a2, 8($sp) #y
	
	addi $sp,$sp,12
	jr $ra
#$a1 - x
#$a2 - y
#$s7 - cols

#$t3 - cx
#$t5 - cy
#$t6 - cx1
#$s0 - cy1

#$v0 - return count of consecutive tiles
#similar code to TOP BOTTOM
checkfordiag:
addi $sp,$sp,-12
	sw $ra, 0($sp)
	sw $a1, 4($sp) #x
	sw $a2, 8($sp) #y
	
	move $t3,$a1
	move $t5,$a2
	
	move $t6,$a1
	move $s0,$a2

	checkdiag1:
		blt $t3,$0,checkdiag2
		bge $t5,$s6,checkdiag2
		move $a1,$t3
		move $a2,$t5
		jal convert2dto1darray
	
		lw $v0, 0($v0)

		beq $v0,$0,checkdiag2
		bne $v0,$s4,checkdiag2
	
		addi $t3,$t3,-1
		addi $t5,$t5, 1
		j checkdiag1

	checkdiag2:
		bge $t6,$s7,checkdiagend
		blt $s0,$0,checkdiagend
		move $a1,$t6
		move $a2,$s0
		jal convert2dto1darray
	
		lw $v0, 0($v0)
	
		beq $v0,$0,checkdiagend
		bne $v0,$s4,checkdiagend
	
		addi $t6,$t6,1
		addi $s0,$s0,-1
		j checkdiag2

	checkdiagend:
		move $v0, $t6
		sub $v0, $v0, $t3
		addi $v0, $v0, -1
	
	lw $ra, 0($sp)
	lw $a1, 4($sp) #x
	lw $a2, 8($sp) #y
	
	addi $sp,$sp,12
	jr $ra
#$a1 - x
#$a2 - y
#$s7 - cols

#$t3 - cx
#$t5 - cy
#$t6 - cx1
#$s0 - cy1

#$v0 - return count of consecutive tiles
#similar code to TOP BOTTOM
checkbackdiag:
	addi $sp,$sp,-12
	sw $ra, 0($sp)
	sw $a1, 4($sp) #x
	sw $a2, 8($sp) #y
	
	move $t3,$a1
	move $t5,$a2
	
	move $t6,$a1
	move $s0,$a2

	checkbackdiag1:
		bge $t3,$s7,checkbackdiag2
		bge $t5,$s6,checkbackdiag2
		move $a1,$t3
		move $a2,$t5
		jal convert2dto1darray
	
		lw $v0, 0($v0)

		beq $v0,$0,checkbackdiag2
		bne $v0,$s4,checkbackdiag2
	
		addi $t3,$t3,1
		addi $t5,$t5, 1
		j checkbackdiag1

	checkbackdiag2:
		blt $t6,$0,checkbackdiagend
		blt $s0,$0,checkbackdiagend
		move $a1,$t6
		move $a2,$s0
		jal convert2dto1darray
	
		lw $v0, 0($v0)
	
		beq $v0,$0,checkbackdiagend
		bne $v0,$s4,checkbackdiagend
	
		addi $t6,$t6,-1
		addi $s0,$s0,-1
		j checkbackdiag2

	checkbackdiagend:
		move $v0, $t6
		sub $v0, $v0, $t3
		mul $v0,$v0,-1
		addi $v0, $v0, -1
	
	lw $ra, 0($sp)
	lw $a1, 4($sp) #x
	lw $a2, 8($sp) #y
	
	addi $sp,$sp,12
	jr $ra

#$a1 - x
#$a2 - y
#$s4 - player number
#$s6 - rows
#$s7 - cols
#$s2 - array

CheckForWin:
	addi $sp,$sp,-4
	sw $ra, 0($sp)

	jal checktopbot
	move $a0,$s4
	bge $v0,$v1, Winner1
	jal checkleftright
	bge $v0,$v1, Winner1
	jal checkfordiag
	bge $v0,$v1, Winner1
	jal checkbackdiag
	bge $v0,$v1, Winner1
	
	#if any condition wins, then jump to winner1
	
	beq $s3,42,Tie
	#also check for ties if all tiles are placed

	lw $ra, 0($sp)
	addi $sp,$sp,4
	jr $ra

Winner1:
    beq $a0, 2, Winner2
    la $a0, msg9
    li $v0, 4
    syscall
    
    j exit

Winner2:
        la $a0, msg10
        li $v0, 4
        syscall
        
        j exit

Tie:     
	la $a0, msg11
	li $v0, 4
	syscall
 	j exit

drawbackground:	
	lw $s0, heap
	lw $t2, background
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

		xloop: # xloop
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
	
# Time to create the basic grid
# s4 for white x
# s5 for white y
DrawGrid:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	li $t8, 0
	li $a3, 8
	lw $t2, basecolor
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

exit:
	li $v0,10
	syscall
