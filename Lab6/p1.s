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
li $s0, 5               #NUM_ITEMS
li $s1, 10              #NUM_RECIPES
li $s2, 32'h7fffffff    

li $t0, 0               #recipe_idx
coe_FOR1:
        bge $t0, $s0, coe_END1
        add $t1, $t0, $t0
        add $t1, $t1, $t1
        add $t1, $t1, $a2
        sw $s2, 0($t1)  #times_craftable[recipe_idx]
        li $t2, 0       #assigned 0
        li $t3,0        #item_idx

        coe_FOR2:
                bge $t3, $s1, coe_END2
                mult $s0, $t0
                mflo $t4
                add $t4, $t4, $t3
                add $t4, $t4, $t4
                add $t4, $t4, $t4
                add $t4, $t4, $a1
                lw $t4, 0($t4)          #recipes[recipe_idx][item_idx]
                ble $t4, $zero, coe_END2
                add $t5, $t3, $t3
                add $t5, $t5, $t5
                add $t5, $t5, $a0
                lw $t6, 0($t5)          #inventory[item_idx]
                div $t6, $t6, $t4       #times_item_req
                lw $t7, 0($t1)          #times_craftable[recipe_idx]
                bge $t6, $t7, INCREMENT2
                sw $t6, 0($t1)
                li $t2, 1
        INCREMENT2:
                addi $t3, $t3, 1
                j coe_FOR2
        coe_END2:
                bne $t2, $zero, INCREMENT1
                sw $zero, 0($t1)
INCREMENT1:
        addi $t0, $t0, 1
        j coe_FOR1
coe_END1:

        


        




        jr      $ra