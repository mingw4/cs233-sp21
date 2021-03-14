.text

## struct Lines {
##     unsigned int num_lines;
##     // An int* array of size 2, where first element is an array of start pos
##     // and second element is an array of end pos for each line.
##     // start pos always has a smaller value than end pos.
##     unsigned int* coords[2];
## };
## 
## struct Solution {
##     unsigned int length;
##     int* counts;
## };
## 
## // Count the number of disjoint empty area after adding each line.
## // Store the count values into the Solution struct. 
## void count_disjoint_regions(const Lines* lines, Canvas* canvas,
##                             Solution* solution) {
##     // Iterate through each step.
##     for (unsigned int i = 0; i < lines->num_lines; i++) {
##         unsigned int start_pos = lines->coords[0][i];
##         unsigned int end_pos = lines->coords[1][i];
##         // Draw line on canvas.
##         draw_line(start_pos, end_pos, canvas);
##         // Run flood fill algorithm on the updated canvas.
##         // In each even iteration, fill with marker 'A', otherwise use 'B'.
##         unsigned int count =
##                 count_disjoint_regions_step('A' + (i % 2), canvas);
##         // Update the solution struct. Memory for counts is preallocated.
##         solution->counts[i] = count;
##     }
## }

.globl count_disjoint_regions
count_disjoint_regions:
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

        move $s0, $a0                   #s0 = a0 = lines
        move $s1, $a1                   #s1 = a1 = canvas
        move $s2, $a2                   #s2 = a2 = solution
        move $s3, $zero                 #s3 = i = 0
        lw $s4, 0($s0)                  #s4 = lines->num_lines
FOR:

        bge $s3, $s4, END               #s3 = i >= lines->num_lines
        lw $t0, 4($s0)                  #t0 = addr_lines->coords
        mul $t1, $s3, 4                 #t1 = 4 * s3 = 4 * i
        add $t0, $t0, $t1               #t0 = addr_lines->coords[0][i]
        lw $t0, 0($t0)                  #t0 = start_pos = line->coords[0][i]


        lw $t2, 8($s0)                  #t2 = addr_lines->coords
        add $t2, $t2, $t1               #t2 = addr_lines->coords[1][i]
        lw $t2, 0($t2)                  #t2 = end_pos =  addr_lines->coords[1][i]



        move $a0, $t0
        move $a1, $t2
        move $a2, $s1
        jal draw_line

        li $a0, 'A'                     #a0 = 'A'
        li $t4, 2
        div $s3, $t4
        mfhi $t5                        #t4 = i % 2
        add $a0, $a0, $t5               #a0 = 'A' + i % 2
        move $a1, $s1                   #a1 = canvas

        jal count_disjoint_regions_step
        move $s5, $v0                   #s5 = v0 = count

        lw $s6, 4($s2)                  #s6 = solution->count
        mul $t6, $s3, 4                 #t6 = 4i
        add $t7, $s6, $t6               #s6 = solution->count + 4i
        sw $s5, 0($t7)                  #solution->counts[i] = count
        addi $s3, $s3, 1                #i++
        j FOR

END:

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
