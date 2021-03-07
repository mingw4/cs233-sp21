# /**
#  * This function matches a 5x5 pattern across the map using 2D convolution.
#  * If the correlation between the pattern and a 5x5 patch of the map is above the
#  * given threshold, then the left hand corner of the patch will be returned.
#  * If no match was found, then -1 is returned.
#  */
# int pattern_match(int threshold, int pattern[5][5], int map[16][16]) {
#     const int PATTERN_SIZE = 5;
#     const int EDGE = 16 - 5 + 1;

#     for (int row = 0; row < EDGE; row++) {
#         for (int col = 0; col < EDGE; col++) {
#             int sum = 0;
#             for (int pat_row = 0; pat_row < PATTERN_SIZE; pat_row++) {
#                 for (int pat_col = 0; pat_col < PATTERN_SIZE; pat_col++) {
#                     if (pattern[pat_row][pat_col] == map[row + pat_row][col + pat_col]) {
#                         sum += 1;
#                     }
#                     if (sum > threshold) {
#                         return (row << 16) | col;
#                     }
#                 }
#             }
#         }
#     }
#     return -1;
# }

.globl pattern_match
pattern_match:

sub $sp, $sp, 28
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)

li $s0, 5               #s0 = PATTERN_SIZE = 5
li $s1, 12              #s1 = EDGE = 16 - 5 + 1 = 12
li $s2, 16              $s2 = 16 = MAP_SIZE
li $t0, 0               #t0 = row = 0

FOR0:
        bge $t0, $s1, FOR0_END          #t0 = row < s1 = EDGE
        li $t1, 0                       #t1 = col = 0
        
        FOR1:
                bge $t1, $s1, INCR0          #t1 = col < s1 = EDGE
                li $s3, 0                       #s3 = sum = 0
                li $t2, 0                       #t2 = pat_row = 0

                FOR2:
                        bge $t2, $s0, INCR1          #t2 = pat_row < s0 = PATTERN_SIZE
                        li $t3, 0                       #t3 = pat_col = 0

                        FOR3:
                                bge $t3, $s0, INCR2          #t3 = pat_col < s0 = PATTERN_SIZE
                                mul $t4, $t2, $s0               #t4 = pat_row * PATTERN_SIZE
                                add $t4, $t4, $t3               #t4 = pat_row * PATTERN_SIZE + pat_col
                                add $t4, $t4, $a1               #t4 = Addr_pattern[pat_row][pat_col]
                                lw $t4, 0($t4)                  #t4 = pattern[pat_row][pat_col]
                                add $t5, $t0, $t2               #t5 = row + pat_row
                                mul $t5, $t5, $s2               #t5 = (row + pat_row) * MAP_SIZE
                                add $t5, $t5, $t1               #t5 = (row + pat_row) * MAP_SIZE + col
                                add $t5, $t5, $t3               #t5 = (row + pat_row) * MAP_SIZE + (col + pat_col)
                                add $t5, $t5, $a2               #t5 = Addr_map[row + pat_row][col + pat_col]
                                lw $t5, 0($t5)                  $t5 = map[row + pat_row][col + pat_col]
                                
                                IF0:
                                        bne $t4, $t5, IF1               #Addr_pattern[pat_row][pat_col] == map[row + pat_row][col + pat_col]
                                        addi $s3, $3, 1                 #s3 = sum += 1
                                IF1:
                                        ble $s3, $a0, INCR3             #s3 = sum > a0 = threshold
                                        sll $t6, $t0, 16                #t6 = t5 << 16 = row << 16
                                        or $v0, $t6, $t1                #return (row << 16) | col
                                        j END
                        
                        INCR3:
                                addi $t3, $t3, 1                #pat_col++
                                j FOR3
                        
                INCR2:
                        addi $t2, $t2, 1                #pat_row++
                        j FOR2
        
        INCR1:
                addi $t1, $t1, 1                #col++
                j FOR1
INCR0:
        addi $t0, $t0, 1                #row++
        j FOR0

FOR0_END:
        li $v0, -1              #return -1
        j END






END:

lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)

add $sp, $sp, 28

        jr      $ra