#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Euan Pound, 1007421577
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Different Speeds (Easy)
# 2. Show Score (Hard)
# 3. Sinking Logs (Hard)
# 4. Powerups (Hard)
#
# Any additional information that the TA needs to know:
# - Very fun project! Although it took a long time to do.
#
#####################################################################
# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
grass: .word 0x5ca155
water: .word 0x5584a1
pavement: .word 0x575757
log: .word 0x966F33
sinking_log: .word 0xdb9b37
car: .word 0xfb9403
frog_pos: .word 0x10008E44
frog_x: .word 16
frog_y: .word 28
frog_colour: .word 0xa15597
text_colour: .word 0xff0000
log_1_x: .word 0
log_1_y: .word 8
log_2_x: .word 16
log_2_y: .word 8
log_3_x: .word 4
log_3_y: .word 12
log_4_x: .word 20
log_4_y: .word 12
car_1_x: .word 20
car_1_y: .word 20
car_2_x: .word 4
car_2_y: .word 20
car_3_x: .word 16
car_3_y: .word 24
car_4_x: .word 0
car_4_y: .word 24
timer_for_move: .word 4

score: .word 0
lives: .word 3

blue: .word 0x0000ff
heart: .word 0xff0000
frame_rate: .word 15
.text
MainLoop:
lw $t0 displayAddress
lw $t1 grass

addi $a0, $zero, 8 #set height to 8 pixels
addi $a1, $zero, 32 #set width to 32 pixels
jal draw_rect #draw a rectangle given the inputs

lw $t1, water #load water colour into $t1
jal draw_rect #draw a rectangle given the inputs

lw $t1, grass #load grass colour into $t1
addi $a0, $zero, 4 #set height to 4 pixels
jal draw_rect #draw a rectangle given the inputs

lw $t1, pavement #load pavement colour into $t1
addi $a0, $zero, 8 #set height to 8 pixels
jal draw_rect #draw a rectangle given the inputs

lw $t1, grass #load grass colour into $t1
addi $a0, $zero, 4 #set height to 4 pixels
jal draw_rect #draw a rectangle given the inputs

lw $t1, log # Load log colour into $t1

# Paint all the logs and cars and only save the value of $a2 into the respective x position if the timer has run to zero
lw $a2, log_1_x
lw $a3, log_1_y
jal draw_obst
lw $t9, timer_for_move
sw $a2, log_1_x

lw $t9, timer_for_move
lw $t1, sinking_log
lw $a2, log_2_x
lw $a3, log_2_y
beq $t9, 3, skip_log
jal draw_obst
lw $t9, timer_for_move
sw $a2, log_2_x
j skip_second
skip_log:
addi $a2, $a2, 1
sw $a2, log_2_x
skip_second:

lw $t1, log

lw $a2, log_3_x
lw $a3, log_3_y
jal draw_obst
lw $t9, timer_for_move
bne $t9, 0 log_4load
sw $a2, log_3_x

log_4load:
lw $a2, log_4_x
lw $a3, log_4_y
jal draw_obst
lw $t9, timer_for_move
bne $t9, 0 log_5load
sw $a2, log_4_x

log_5load:
lw $t1, car # Load car colour into the colour register

lw $a2, car_1_x
lw $a3, car_1_y
jal draw_obst
lw $t9, timer_for_move
sw $a2, car_1_x

lw $a2, car_2_x
lw $a3, car_2_y
jal draw_obst
lw $t9, timer_for_move
sw $a2, car_2_x

lw $a2, car_3_x
lw $a3, car_3_y
jal draw_obst
lw $t9, timer_for_move
bne $t9, 0 log_8load
sw $a2, car_3_x

log_8load:
lw $a2, car_4_x
lw $a3, car_4_y
jal draw_obst
lw $t9, timer_for_move
bne $t9, 0 log_9load
sw $a2, car_4_x
addi $t9, $zero, 5

log_9load:
subi $t9, $t9, 1
sw $t9, timer_for_move

# Determine if the frog has moved before painting it
lw $t8, 0xffff0000
beq $t8, 1, keyboard_input
return_from_keyboard:

jal draw_hourglass
jal draw_heart

# Paint the frog
lw $a0, frog_x 
lw $a1, frog_y
jal conv_from_coords # Convert the coords into screen values
jal draw_frog # Draw the frog

# Collision Code
lw $t3, frog_y
lw $t4, log_1_y
lw $a0, log_1_x
lw $a1, log_2_x
beq $t3, $t4, handle_log_row_1
return_from_handle_log_row_1:

lw $t3, frog_y
lw $t4, log_3_y
lw $a0, log_3_x
lw $a1, log_4_x
beq $t3, $t4, handle_log_row_2
return_from_handle_log_row_2:

lw $t3, frog_y
lw $t4, car_1_y
lw $a0, car_1_x
lw $a1, car_2_x
beq $t3, $t4, handle_car_row_1
return_from_handle_car_row_1:

lw $t3, frog_y
lw $t4, car_3_y
lw $a0, car_3_x
lw $a1, car_4_x
beq $t3, $t4, handle_car_row_2
return_from_handle_car_row_2:

#Collision for the end zone
lw $t3, frog_y
addi $t4, $zero, 0
beq $t3, $t4, in_endzone
addi $t4, $zero, 4
beq $t3, $t4, in_endzone

not_in_endzone:

lw $t3, frog_x
lw $t4, frog_y
bne $t3, 28 not_in_time_skip
bne $t4, 28 not_in_time_skip
lw $t5, blue
beq $t5, 0xd3d3d3 not_in_time_skip
lw $t5, frame_rate
addi, $t5, $zero, 150
sw $t5, frame_rate
lw $t5, blue
addi $t5, $zero, 0xd3d3d3
sw $t5, blue
not_in_time_skip:

lw $t3, frog_x
lw $t4, frog_y
bne $t3, 16 not_in_heart
bne $t4, 16 not_in_heart
lw $t5, heart
beq $t5, 0xd3d3d3 not_in_heart
lw $t5, lives
addi, $t5, $t5, 1
sw $t5, lives
lw $t5, heart
addi $t5, $zero, 0xd3d3d3
sw $t5, heart
not_in_heart:

#Draw Score
lw $t1, score
beq $t1, 0, draw_zero
return_from_draw_zero:
beq $t1, 1, draw_one
return_from_draw_one:
beq $t1, 2, draw_two
return_from_draw_two:
beq $t1, 3, draw_three
return_from_draw_three:

lw $t1, lives
beq $t1, 0, Exit

jal Wait #Wait a frame until we do the next set of calculations

j MainLoop

Exit:
li $v0, 10 # terminate the program gracefully
syscall

draw_hourglass:
lw $t1, blue
lw $t0, displayAddress
sw $t1, 3696($t0)
sw $t1, 3700($t0)
sw $t1, 3704($t0)
sw $t1, 3708($t0)
sw $t1, 3828($t0)
sw $t1, 3832($t0)
sw $t1, 3956($t0)
sw $t1, 3960($t0)
sw $t1, 4080($t0)
sw $t1, 4084($t0)
sw $t1, 4088($t0)
sw $t1, 4092($t0)
jr $ra

draw_heart:
lw $t1, heart
lw $t0, displayAddress
sw $t1, 2112($t0)
sw $t1, 2124($t0)
sw $t1, 2240($t0)
sw $t1, 2244($t0)
sw $t1, 2248($t0)
sw $t1, 2252($t0)
sw $t1, 2368($t0)
sw $t1, 2372($t0)
sw $t1, 2376($t0)
sw $t1, 2380($t0)
sw $t1, 2500($t0)
sw $t1, 2504($t0)
jr $ra

in_endzone:
lw $t1, score
addi $t1, $t1, 1
sw $t1, score
lw $t3, frog_x
lw $t4, frog_y
addi $t3, $zero, 16
addi $t4, $zero, 28
sw $t3, frog_x
sw $t4, frog_y
j not_in_endzone

draw_zero:
lw $t1, text_colour
lw $t0, displayAddress
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 144($t0)
sw $t1, 260($t0)
sw $t1, 272($t0)
sw $t1, 388($t0)
sw $t1, 400($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)
sw $t1, 524($t0)
sw $t1, 528($t0)
j return_from_draw_zero

draw_one:
lw $t1, text_colour
lw $t0, displayAddress
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 264($t0)
sw $t1, 268($t0)
sw $t1, 392($t0)
sw $t1, 396($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)
sw $t1, 524($t0)
sw $t1, 528($t0)
j return_from_draw_one

draw_two:
lw $t1, text_colour
lw $t0, displayAddress
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 144($t0)
sw $t1, 264($t0)
sw $t1, 268($t0)
sw $t1, 272($t0)
sw $t1, 388($t0)
sw $t1, 392($t0)
sw $t1, 396($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)
sw $t1, 524($t0)
sw $t1, 528($t0)
j return_from_draw_two

draw_three:
lw $t1, text_colour
lw $t0, displayAddress
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 144($t0)
sw $t1, 264($t0)
sw $t1, 268($t0)
sw $t1, 272($t0)
sw $t1, 396($t0)
sw $t1, 400($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)
sw $t1, 524($t0)
sw $t1, 528($t0)
j Exit

lose_life:
lw $t1, lives
subi $t1, $t1, 1
sw $t1, lives
jr $ra

handle_log_row_1:
lw $t3, frog_x
add $t4, $zero, $a0
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
add $t4, $zero, $a1

lw $t9, timer_for_move
beq $t9, 3, sunken
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_1_return
sunken:
lw $t4, frog_y
addi $t3, $zero, 16
addi $t4, $zero, 28
sw $t3, frog_x
sw $t4, frog_y
jal lose_life
j return_from_handle_log_row_1
handle_log_row_1_return:
addi $t3, $t3, 1
sw $t3, frog_x
j return_from_handle_log_row_1

# Log row collision handler
handle_log_row_2:
lw $t3, frog_x
add $t4, $zero, $a0
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return

add $t4, $zero, $a1

beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_log_row_2_return
lw $t4, frog_y
addi $t3, $zero, 16
addi $t4, $zero, 28
sw $t3, frog_x
sw $t4, frog_y
jal lose_life
j return_from_handle_log_row_2
handle_log_row_2_return:
lw $t4, timer_for_move
bne $t4, 4, return_from_handle_log_row_2
addi $t3, $t3, 1
sw $t3, frog_x
j return_from_handle_log_row_2

#Handle the car collision code
handle_car_row_1:
lw $t3, frog_x
add $t4, $zero, $a0
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return

add $t4, $zero, $a1

beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_1_return

j return_from_handle_car_row_1
handle_car_row_1_return:
lw $t4, frog_y
addi $t3, $zero, 16
addi $t4, $zero, 28
sw $t3, frog_x
sw $t4, frog_y
jal lose_life
j return_from_handle_car_row_1

# Car row 2
handle_car_row_2:
lw $t3, frog_x
add $t4, $zero, $a0
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return

add $t4, $zero, $a1

beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return
addi $t4, $t4, 1
beq $t3, $t4, handle_car_row_2_return

j return_from_handle_car_row_2
handle_car_row_2_return:
lw $t4, frog_y
addi $t3, $zero, 16
addi $t4, $zero, 28
sw $t3, frog_x
sw $t4, frog_y
jal lose_life
j return_from_handle_car_row_2

keyboard_input:
lw $t2, 0xffff0004
beq $t2, 0x77, respond_to_W
beq $t2, 0x61, respond_to_A
beq $t2, 0x73, respond_to_S
beq $t2, 0x64, respond_to_D
j return_from_keyboard

respond_to_W:
lw $t1, frog_y # Load into $t1 the location of frog y
beq $t1, 0 return_from_keyboard # Return if out of bounds
subi $t1, $t1 4 # Subtract from it to go up one square
sw $t1, frog_y # Store the value back in the location variable
j return_from_keyboard

respond_to_S:
lw $t1, frog_y # Load into $t1 the location of frog y
beq $t1, 28 return_from_keyboard # Return if out of bounds
addi $t1, $t1 4 # Add to it to go down one square
sw $t1, frog_y # Store the value back in the location variable
j return_from_keyboard

respond_to_A:
lw $t1, frog_x # Load into $t1 the location of frog x
beq $t1, 0 return_from_keyboard # Return if out of bounds
subi $t1, $t1 4 # Subtract from it to go left one square
sw $t1, frog_x # Store the value back in the location variable
j return_from_keyboard

respond_to_D:
lw $t1, frog_x # Load into $t1 the location of frog x
beq $t1, 28 return_from_keyboard # Return if out of bounds
addi $t1, $t1 4 # Add to it to go right one square
sw $t1, frog_x # Store the value back in the location variable
j return_from_keyboard

draw_obst:
#a2 will be our log_x value
#a3 will be our log_y value
addi $sp, $sp, -4 # Move sp back 4
sw $ra, 0($sp) # Move $ra onto the stack

add $t4, $zero, $zero # set $t4 to 0 $t5 will be our counter
# draw one full obstacle
# loop five times and draw a rectangle each time
obst_loop:
beq $t4, 8, end_draw_obst # if $t4 == 5 then finish drawing this obstacle
add $t9, $t4, $a2 #set $t9 to the current loop iteration plus x coord of the log
bgt $t9, 31, res_to_start # if at any loop the value of the x coordinate is > 32 res_to_start
back: #we have guaranteed that the obstacle will be on the correct line
add $a0, $zero, $t9
add $a1, $zero, $a3
jal conv_from_coords
addi $a0, $zero, 4
addi $a1, $zero, 1
jal draw_rect #draw a column of the shape

addi $t4, $t4, 1
j obst_loop

end_draw_obst:
addi $a2, $a2, 1 # remove comment (for testing)
bgt $a2, 31 res_to_start_log
back2:
lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra

res_to_start:
subi $t9, $t9, 32
j back

res_to_start_log:
subi $a2, $a2, 32
j back2

conv_from_coords:
# $a0 is x component
# $a1 is y component
addi $t8, $zero, 4
mult $a0, $t8 # mult $a0 by 4
mflo $a0
addi $t8, $zero, 128
mult $a1, $t8 # mult $a1 by 128
mflo $a1 
lw $t0, displayAddress# set $t0 to display address
add $t0, $t0, $a0 # add them to $t0
add $t0, $t0, $a1 # ^
jr $ra # return

# Draw a rectangle:
draw_rect:
add $t6 $zero,  $zero
draw_rect_loop:
beq $t6, $a0, end_draw_rect # If $t6 == height ($a0) Exit

# Draw a line:
add $t5, $zero, $zero
draw_line_loop:
beq $t5, $a1, end_draw_line # If %t5 == width (%a1) end_draw_line
sw $t1 ($t0)
addi $t0, $t0, 4 #move to the next pixel
addi $t5, $t5, 1 #increment the width counter
j draw_line_loop
end_draw_line:

addi $t9, $zero, 4
mult $t9, $a1 # Multiply 4 by our width value
mflo $t9 #keep the lowest 32bits in $t9
addi $t8 $zero, 128 # Move 128 into register $t8
sub $t7, $t8, $t9
# Subtract that from 128 and load it into register $t7

add $t0, $t0, $t7 # set $t0 to the next pixel of the next line
addi $t6, $t6, 1 #increment our height counter
j draw_rect_loop

end_draw_rect:
jr $ra

draw_frog:
lw $t1, frog_colour #set $t1 to frog colour
sw $t1, ($t0)
sw $t1, 12($t0)
sw $t1, 128($t0)
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 388($t0)
sw $t1, 392($t0)
sw $t1, 396($t0)

jr $ra

Wait: #Wait for ~1/64th of a second
li $v0, 32
lw $a0, frame_rate
syscall
jr $ra

