#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Name, Student Number
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
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
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
frog_pos: .word 0x10008E44
frog_x: .word 17
frog_y: .word 28
frog_colour: .word 0xa15597
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

#Paint the frog
#TODO convert coords into actual values
lw $t0, displayAddress
jal draw_frog

jal Wait #Wait a frame until we do the next set of calculations

j MainLoop

Exit:
li $v0, 10 # terminate the program gracefully
syscall

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
li $a0, 15
syscall
jr $ra

