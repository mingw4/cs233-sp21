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
## // Count the number of disjoint empty area in a given canvas.
## unsigned int count_disjoint_regions_step(unsigned char marker,
##                                          Canvas* canvas) {
##     unsigned int region_count = 0;
##     for (unsigned int row = 0; row < canvas->height; row++) {
##         for (unsigned int col = 0; col < canvas->width; col++) {
##             unsigned char curr_char = canvas->canvas[row][col];
##             if (curr_char != canvas->pattern && curr_char != marker) {
##                 region_count ++;
##                 flood_fill(row, col, marker, canvas);
##             }
##         }
##     }
##     return region_count;
## }

.globl count_disjoint_regions_step
count_disjoint_regions_step:
        # Your code goes here :)
sub $sp, $sp, 32
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)


move $s0, $zero                         #s0 = region_count = 0
move $s1, $zero                         #s1 = row = 0

lw $s3, 0($a1)                          #s3 = canvas->height
lw $s4, 4($a1)                          #s4 = canvas->width
move $s5, $a0                           #s5 = a0 = marker
move $s6, $a1                           #s6 = a1 = addr_canvas

FOR1:
        bge $s1, $s3, END               #s1 = row >= canvas->height = s3
        move $s2, $zero                         #s2 = col = 0
FOR2:
        bge $s2, $s4, INCR1             #s2 = col >= canvas->width = s4
        lw $t0, 12($a1)                 #t0 = canvas->canvas
        mul $t1, $s1, 4                 #t1 = 4 * s1 = 4 * row
        add $t1, $t1, $t0               #t1 = addr_canvas[row]
        lw $t1, 0($t1)                  #t1 = canvas[row]
        add $t1, $t1, $s2               #t1 = addr_canvas[row][col]
        lb $t2, 0($t1)                  #t2 = curr_char = canvas[row][rol]

IF:
        lb $t3, 8($s6)                  #t3 = canvas->pattern
        beq $t2, $t3, INCR2             #curr_char == canvas->pattern
        beq $t2, $s5, INCR2             #curr_char == marker

        addi $s0, $s0, 1
        move $a0, $s1
        move $a1, $s2
        move $a2, $s5
        move $a3, $s6
        jal flood_fill

        move $a0, $s5
        move $a1, $s6

INCR2:
        addi $s2, $s2, 1                #col = col + 1
        j FOR2
INCR1:
        addi $s1, $s1, 1                #row = row + 1
        j FOR1
END:
        move $v0, $s0



lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)

add $sp, $sp, 32




jr      $ra
