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

## void draw_line(unsigned int start_pos, unsigned int end_pos, Canvas* canvas) {
##     unsigned int width = canvas->width;
##     unsigned int step_size = 1;
##     // Check if the line is vertical.
##     if (end_pos - start_pos >= width) {
##         step_size = width;
##     }
##     // Update the canvas with the new line.
##     for (int pos = start_pos; pos != end_pos + step_size; pos += step_size) {
##         canvas->canvas[pos / width][pos % width] = canvas->pattern;
##     }
## }

.globl draw_line
draw_line:

lw $t0, 4($a2)                  #t0 = width = canvas->width
li $t1, 1                      #t1 = step_size = 1
sub $t2, $a1, $a0               #t2 = end_pos - start_pos

IF:
        blt $t2, $t0, IF_END            #end_pos - start_pos >= width
        move $t1, $t0                   #t1 = step_size = width

IF_END:
        move $t3, $a0                   #t3 = pos = a0 = start_pos
        add $t4, $a1, $t1               #t4 = a1 + t3 = end_pos + step_size

FOR:
        beq $t3, $t4, FOR_END
        sub $sp, $sp, 28
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)
        sw $s5, 24($sp)

        div $t3, $t0            #pos div width
        mflo $s0                #s0 = t3 / t0 = pos / width
        mfhi $s1                #s1 = t3 % t0 = pos % width
        lb $s2, 8($a2)          #s2 = pattern
        lw $s3, 12($a2)         #s3 = canvas->canvas_addr

        mul $s0, $s0, 4         #s0 = 4 * pos / width
        add $s0, $s0, $s3       #s0 = addr_canavas->canvas[pos / width]
        lw $s0, 0($s0)          #s0 = canavas->canvas[pos / width]
        add $s0, $s0, $s1       #s0 = addr_canvas->canvas[pos / width][pos % width]
        sb $s2, 0($s0)
        add $t3, $t3, $t1       #pos += step_size



        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)

        add $sp, $sp, 28

        j FOR

FOR_END:
        jr $ra



















        jr      $ra
