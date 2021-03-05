# /**
#  * Given a table of recipes and an inventory of items, this function
#  * will populate times_craftable with the number of times each recipe
#  * can be crafted.
#  *
#  * Note: When passing arrays as parameters, the register $a0 will hold the starting
#  * address of the array, not the contents of the array.
#  */

# void craftable_recipes(int inventory[5], int recipes[10][5], int times_craftable[10]) {
#     const int NUM_ITEMS = 5;
#     const int NUM_RECIPES = 10;

#     for (int recipe_idx = 0; recipe_idx < NUM_RECIPES; recipe_idx++) {
#         times_craftable[recipe_idx] = 0x7fffffff;  // Largest positive number
#         int assigned = 0;

#         for (int item_idx = 0; item_idx < NUM_ITEMS; item_idx++) {
#             if (recipes[recipe_idx][item_idx] > 0) {
#                 // If the item is not required for the recipe, skip it
#                 // Note: There is a div psuedoinstruction to do the division
#                 // The format is:
#                 //    div   $rd, $rs, $rt
#                 int times_item_req = inventory[item_idx] / recipes[recipe_idx][item_idx];
#                 if (times_item_req < times_craftable[recipe_idx]) {
#                     times_craftable[recipe_idx] = times_item_req;
#                     assigned = 1;
#                 }
#             }
#         }

#         if (assigned == 0) {
#             times_craftable[recipe_idx] = 0;
#         }
#     }
# }

.globl craftable_recipes
craftable_recipes:
sub $sp, $sp, 32
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)

move $s0, $a0                   #s0 = inventory[]
move $s1, $a1                   #s1 = recipes[][]
move $s2, $a2                   #s2 = times_craftable[]

li $s3, 5                       #s3 = NUM_ITEMS num of col
li $s4, 10                      #s4 = NUM_RECIPES 
li $s5, 0x7fffffff              #s5 = Largest positive number


li $t0, 0                       #t0 = recipe_idx

FOR_LOOP1:
        bge $t0, $s4, FOR_END1      #recipe_idx < NUM_RECIPES
        mul $t1, $t0, 4         #recipe_idx * 4
        add $t1, $t1, $s2       #address_craftable = recipe_idx * 4 + craftable[]
        sw $s5, 0($t1)          #times_craftable[recipe_idx] = 0x7fffffff
        li $t2, 0               #t2 = assigned = 0

        li $t3, 0               #t3 = item_idx = 0

FOR_LOOP2:
        bge $t3, $s3, INCR1     #item_idx < NUM_ITEMS
        mul $t4, $t0, $s3       #t4 = recipe_idx * num of col
        add $t4, $t4, $t3       #t4 = recipe_idx * num of col + col
        mul $t4, $t4, 4         #t4 = 4 * (recipe_idx * num of col + col)
        add $t4, $t4, $s1       #addr_of_recipes[row][col] = addr_of_recipes[][] + 4 * (recipe_idx * num of col + col)
        lw $s6, 0($t4)          #s6 = addr_of_recipes[row][col]

IF1:
        ble $s6, $zero, ENDIF1
        mul $t5, $t3, 4         #t5 = item_idx * 4
        add $t5, $t5, $s0       #t5 = addr_of_inventory[item_idx] = inventory[] + 4 * item_idx
        lw $t5, 0($t5)          #t5 = inventory[item_idx]
        div $t6, $t5, $s6       #t6 = times_item_req = inventory[item_idx]/recipes[recipe_idx][item_idx]

        mul $t7, $t0, 4         #t7 = recipe_idx * 4
        add $t7, $t7, $a2       #t7 = addr_of_times_craftable[recipe_idx]
        lw $t8, 0($t7)          #t8 = times_craftable[recipe_idx]


IF11:
        bge $t6, $t8, ENDIF1    #times_item_req < times_craftable[recipe_idx]
        sw $t6, 0($t7)          #times_craftable[recipe_idx] = times_item_req
        li $t2, 1               #t2 = assigned = 1

ENDIF1:
        bne $t2, $zero, INCR2   #assigned == 0
        sw $zero, 0($t7)        $addr_of_times_craftable[recipe_idx] =0


INCR2:
        addi $t3, $t3, 1        #t3 = t3 + 1 = item_idx + 1
        j FOR_LOOP2

INCR1:
        addi $t0, $t0, 1        #t0 = t0 + 1 = recipe_idx + 1
        j FOR_LOOP1

FOR_END1:


        







lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)

add $sp, $sp, 32
jr $ra