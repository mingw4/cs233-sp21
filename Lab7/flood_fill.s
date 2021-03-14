.text

## struct Canvas {
##     // Height and width of the canvas.
##     unsigned int height;
##     unsigned int width;
##     // The pattern to draw on the canvas.
##     unsigned char pattern;
##     // Each char* is null-terminated and has same length.
##     char** canvas;
## };
## 
## // Mark an empty region as visited on the canvas using flood fill algorithm.
## void flood_fill(int row, int col, unsigned char marker, Canvas* canvas) {
##     // Check the current position is valid.
##     if (row < 0 || col < 0 ||
##         row >= canvas->height || col >= canvas->width) {
##         return;
##     }
##     unsigned char curr = canvas->canvas[row][col];
##     if (curr != canvas->pattern && curr != marker) {
##         // Mark the current pos as visited.
##         canvas->canvas[row][col] = marker;
##         // Flood fill four neighbors.
##         flood_fill(row - 1, col, marker, canvas);
##         flood_fill(row, col + 1, marker, canvas);
##         flood_fill(row + 1, col, marker, canvas);
##         flood_fill(row, col - 1, marker, canvas);
##     }
## }

.globl flood_fill
flood_fill:

IF1:
	blt $a0, $zero, END						#a0 = row < 0
	blt $a1, $zero, END						#a1 = col < 0
	lw $t0, 0($a3)							#t0 = canvas->height
	bge $a0, $t0, END						#a0 = row >= t0 = canvas->height
	lw $t0, 4($a3)							#t0 = canvas->width
	bge $a1, $t0, END						#a1 = col >= t0 = canvas->width
	
##IF1_END

lw $t0, 12($a3)								#t0 = canvas->canvas
mul $t1, $a0, 4								#t1 = 4 * row
add $t0, $t0, $t1							#t0 = addr_canvas->canvas[row]
lw $t0, 0($t0)								#t0 = canvas->canvas[row]
add $t0, $t0, $a1							#t0 = addr_canvas->canvas[row][col]
lb $t1, 0($t0)								#t1 = curr = canvas->canvas[row][col]
lb $t2, 8($a3)								#t2 = canvas->pattern

IF2:
	beq $t1, $t2, END						#t1 = curr == canvas->pattern = t2
	beq $t1, $a2, END						#t1 = curr == marker = a2

	sb $a2, 0($t0)							#canvas->canvas[row][col] = marker

##recursion

##flood_fill(row - 1, col, marker, canvas)
	sub $sp, $sp, 28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	sub $a0, $a0, 1						#row = row - 1
	jal flood_fill

	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	add $sp, $sp, 28

##flood_fill(row, col + 1, marker, canvas)
	sub $sp, $sp, 28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	addi $a1, $a1, 1					#col = col + 1
	jal flood_fill

	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	add $sp, $sp, 28

##flood_fill(row + 1, col, marker, canvas)
	sub $sp, $sp, 28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	addi $a0, $a0, 1				#row = row + 1
	jal flood_fill

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	add $sp, $sp, 28

##flood_fill(row, col - 1, marker, canvas)
	sub $sp, $sp, 28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	sub $a1, $a1, 1					#col = col - 1
	jal flood_fill

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	add $sp, $sp, 28

END:

	jr 	$ra
