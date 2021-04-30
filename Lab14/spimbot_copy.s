### syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

### memory-mapped I/O addresses and constants

# movement info
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024
GET_OPPONENT_HINT       = 0xffff00ec

TIMER                   = 0xffff001c

REQUEST_PUZZLE          = 0xffff00d0  ## Puzzle
SUBMIT_SOLUTION         = 0xffff00d4  ## Puzzle

# other player info
GET_WOOD                = 0xffff2000
GET_STONE               = 0xffff2004
GET_WOOL                = 0xffff2008
GET_WOODWALL            = 0xffff200c
GET_STONEWALL           = 0xffff2010
GET_BED                 = 0xffff2014
GET_CHEST               = 0xffff2018
GET_DOOR                = 0xffff201c

GET_HYDRATION           = 0xffff2044
GET_HEALTH              = 0xffff2048

GET_INVENTORY           = 0xffff2034
GET_SQUIRRELS               = 0xffff2038

GET_MAP                 = 0xffff2040

# interrupt masks and acknowledge addresses
BONK_INT_MASK           = 0x1000      ## Bonk
BONK_ACK                = 0xffff0060  ## Bonk

TIMER_INT_MASK          = 0x8000      ## Timer
TIMER_ACK               = 0xffff006c  ## Timer

REQUEST_PUZZLE_INT_MASK = 0x800       ## Puzzle
REQUEST_PUZZLE_ACK      = 0xffff00d8  ## Puzzle

RESPAWN_INT_MASK        = 0x2000      ## Respawn
RESPAWN_ACK             = 0xffff00f0  ## Respawn

NIGHT_INT_MASK          = 0x4000      ## Night
NIGHT_ACK               = 0xffff00e0  ## Night

# world interactions -- input format shown with each command
# X = x tile [0, 39]; Y = y tile [0, 39]; t = block or item type [0, 9]; n = number of items [-128, 127]
CRAFT                   = 0xffff2024    # 0xtttttttt
ATTACK                  = 0xffff2028    # 0x0000XXYY

PLACE_BLOCK             = 0xffff202c    # 0xttttXXYY
BREAK_BLOCK             = 0xffff2020    # 0x0000XXYY
USE_BLOCK               = 0xffff2030    # 0xnnttXXYY, if n is positive, take from chest. if n is negative, give to chest.

SUBMIT_BASE             = 0xffff203c    # stand inside your base when using this command

MMIO_STATUS             = 0xffff204c    # updated with a status code after any MMIO operation

# possible values for MMIO_STATUS
# use ./QtSpimbot -debug for more info!
ST_SUCCESS              = 0  # operation completed succesfully
ST_BEYOND_RANGE         = 1  # target tile too far from player
ST_OUT_OF_BOUNDS        = 2  # target tile outside map
ST_NO_RESOURCES         = 3  # no resources available for PLACE_BLOCK
ST_INVALID_TARGET_TYPE  = 4  # block at target position incompatible with operation
ST_TOO_FAST             = 5  # operation performed too quickly after the last one
ST_STILL_HAS_DURABILITY = 6  # block was damaged by BREAK_BLOCK, but is not yet broken. hit it again.

# block/item IDs
ID_WOOD                 = 0
ID_STONE                = 1
ID_WOOL                 = 2
ID_WOODWALL             = 3
ID_STONEWALL            = 4
ID_BED                  = 5
ID_CHEST                = 6
ID_DOOR                 = 7
ID_GROUND               = 8  # not an item
ID_WATER                = 9  # not an item



.data
### Puzzle
puzzle:     .byte 0:400
solution:   .byte 0:256
#### Puzzle

scanner_result: .byte 0 0 0

has_puzzle: .word 0

inv:    .word 0:8

sol_t:          .word   12       solution

has_bonked:    .byte 0
# -- string literals --
.text
main:
    sub $sp, $sp, 12
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)

    # Construct interrupt mask
    li      $t4, 0
    or      $t4, $t4, TIMER_INT_MASK            # enable timer interrupt
    or      $t4, $t4, BONK_INT_MASK             # enable bonk interrupt
    or      $t4, $t4, REQUEST_PUZZLE_INT_MASK   # enable puzzle interrupt
    or      $t4, $t4, 1 # global enable
    mtc0    $t4, $12
    
    # 判断是红色还是蓝色
    li      $t0, BOT_X
    ble     $t0, 20, red

    # blue goes here!
    blue:

    li $t1, 270
    sw $t1, ANGLE
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t2, 1
    sw $t2, VELOCITY
        
    # YOUR CODE GOES HERE!!!!!!


puzzzle_part_blue:
    li      $s0, 0
for_blue:
    bge     $s0, 4, end_for_blue
    li      $s1, 0
    

    la      $t0, puzzle
    sw      $t0, REQUEST_PUZZLE

pending_blue:
    beq     $s1, 0, pending_

    la      $a2, sol_t
    la      $a1, puzzle
    add     $a0, $a1, 16 

    jal     count_disjoint_regions
    la      $t0, sol_t
    lw      $t0, 4($t0)
    sw      $t0, SUBMIT_SOLUTION
    add     $s0, $s0, 1
    j       for_blue
end_for_blue:

move_up:
    lw      $t4, BOT_Y      # load spimbot y loc
    ble     $t4, 140, turn_left_blue

    li      $t1, 270
    sw      $t1, ANGLE
    li      $t1, 1
    sw      $t1, ANGLE_CONTROL
    li      $t2, 10
    sw      $t2, VELOCITY
    j       move_down_blue

turn_left_blue:


    lw      $t3, BOT_X      # load spimbot x loc
    ble     $t3, 124, build_bed
    
    #wool collector
    li      $t0, 0x00000111 # (x=1,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000211 # (x=2,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000311 # (x=3,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000411 # (x=4,y=17) 
    sw      $t0, BREAK_BLOCK
    
    li      $t0, 0x00000212 # (x=2,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000312 # (x=3,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000412 # (x=4,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000512 # (x=5,y=18) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000413 # (x=4,y=19) 
    sw      $t0, BREAK_BLOCK

    #wood collector
    li      $t0, 0x00000811 # (x=8,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000813 # (x=8,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000911 # (x=9,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000912 # (x=9,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000913 # (x=9,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000a11 # (x=10,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000a12 # (x=10,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000a13 # (x=10,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000b11 # (x=11,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000b12 # (x=11,y=18) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000c12 # (x=12,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000d12 # (x=13,y=18) 
    sw      $t0, BREAK_BLOCK

    #destroy tree
    li      $t0, 0x00000e11 # (x=14,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000f11 # (x=15,y=17) 
    sw      $t0, BREAK_BLOCK
    
    # stone collector
    #li      $t0, 0x00000c11 # (x=12,y=17) 
    #sw      $t0, BREAK_BLOCK
    #li      $t0, 0x00000c13 # (x=12,y=19) 
    #sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000f10 # (x=15,y=19) 床下面的石头
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00001011 # (x=15,y=19) 床右面的石头
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000d11 # (x=13,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000d13 # (x=13,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000e12 # (x=14,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000e13 # (x=14,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000f12 # (x=15,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000f13 # (x=15,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00001011 # (x=16,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00001012 # (x=16,y=18) 
    sw      $t0, BREAK_BLOCK

    li      $t1, 0
    sw      $t1, ANGLE
    li      $t1, 1
    sw      $t1, ANGLE_CONTROL
    li      $t2, 2
    sw      $t2, VELOCITY
    j       turn_left_blue

build_bed_blue:

    li      $t1, 0
    sw      $t1, ANGLE
    li      $t1, 1
    sw      $t1, ANGLE_CONTROL
    li      $t2, 0
    sw      $t2, VELOCITY

    li      $t3, 5
    sw      $t3, CRAFT          # build bed

    li      $t3, 0x00050f11     # place bed
    sw      $t3, PLACE_BLOCK    

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040e11     # place stone on the left of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f12     # place stone on the bot of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t0, 0x00000f10 # (x=15,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f10     # place stone on the top of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00041011     # place stone on the right of the bed
    sw      $t3, PLACE_BLOCK   

    li      $t0, 0x0f11 #  19 drink water
    sw      $t0, USE_BLOCK 

    



loop_blue: # Once done, enter an infinite loop so that your bot can be graded by QtSpimbot once 10,000,000 cycles have elapsed

    li      $t0, 0x00000e09 #  床左上的上面的石头 1
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000f09 #  2
    sw      $t0, BREAK_BLOCK
    

    li      $t0, 0x00000d10 #  床左上的左面的石头 4
    sw      $t0, BREAK_BLOCK



    li      $t0, 0x00000e10 #  床左上角的石头 5
    sw      $t0, BREAK_BLOCK


    li      $t0, 0x00000f10 #  床上的石头 6
    sw      $t0, BREAK_BLOCK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f10     # place stone on the top of the bed
    sw      $t3, PLACE_BLOCK    


    li      $t0, 0x00001010 #  床右上角的树 7
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00001110 #  床右上角的树旁的树 8
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000c11 #  9
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000d11 #  10
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000e11 #  11
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040e11     # place stone on the left of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t0, 0x00001011 #  12
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00041011     # place stone on the right of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t0, 0x00001111 #  13
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000d12 #  15
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000e12 #  16
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000f12 #  17
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f12     # place stone on the right of the bed
    sw      $t3, PLACE_BLOCK   

    li      $t0, 0x00001012 #  18
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000e13 #  20
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000f13 #  21
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x1112 #  19 drink water
    sw      $t0, USE_BLOCK

    j loop_blue


    j   end_me

    red:
    li $t1, 0
    sw $t1, ANGLE
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t2, 1
    sw $t2, VELOCITY
        
    # YOUR CODE GOES HERE!!!!!!


puzzzle_part:
    li      $s0, 0
for:
    bge     $s0, 4, end_for
    li      $s1, 0
    

    la      $t0, puzzle
    sw      $t0, REQUEST_PUZZLE

pending_:
    beq     $s1, 0, pending_

    la      $a2, sol_t
    la      $a1, puzzle
    add     $a0, $a1, 16 

    jal     count_disjoint_regions
    la      $t0, sol_t
    lw      $t0, 4($t0)
    sw      $t0, SUBMIT_SOLUTION
    add     $s0, $s0, 1
    j       for
end_for:

move_down:
    lw      $t4, BOT_Y      # load spimbot y loc
    bge     $t4, 140, turn_right

    li      $t1, 90
    sw      $t1, ANGLE
    li      $t1, 1
    sw      $t1, ANGLE_CONTROL
    li      $t2, 10
    sw      $t2, VELOCITY
    j       move_down

turn_right:


    lw      $t3, BOT_X      # load spimbot x loc
    bge     $t3, 124, build_bed
    
    #wool collector
    li      $t0, 0x00000111 # (x=1,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000211 # (x=2,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000311 # (x=3,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000411 # (x=4,y=17) 
    sw      $t0, BREAK_BLOCK
    
    li      $t0, 0x00000212 # (x=2,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000312 # (x=3,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000412 # (x=4,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000512 # (x=5,y=18) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000413 # (x=4,y=19) 
    sw      $t0, BREAK_BLOCK

    #wood collector
    li      $t0, 0x00000811 # (x=8,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000813 # (x=8,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000911 # (x=9,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000912 # (x=9,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000913 # (x=9,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000a11 # (x=10,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000a12 # (x=10,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000a13 # (x=10,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000b11 # (x=11,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000b12 # (x=11,y=18) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000c12 # (x=12,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000d12 # (x=13,y=18) 
    sw      $t0, BREAK_BLOCK

    #destroy tree
    li      $t0, 0x00000e11 # (x=14,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000f11 # (x=15,y=17) 
    sw      $t0, BREAK_BLOCK
    
    # stone collector
    #li      $t0, 0x00000c11 # (x=12,y=17) 
    #sw      $t0, BREAK_BLOCK
    #li      $t0, 0x00000c13 # (x=12,y=19) 
    #sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000f10 # (x=15,y=19) 床下面的石头
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00001011 # (x=15,y=19) 床右面的石头
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000d11 # (x=13,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000d13 # (x=13,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000e12 # (x=14,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000e13 # (x=14,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000f12 # (x=15,y=18) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00000f13 # (x=15,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00001011 # (x=16,y=17) 
    sw      $t0, BREAK_BLOCK
    li      $t0, 0x00001012 # (x=16,y=18) 
    sw      $t0, BREAK_BLOCK

    li      $t1, 0
    sw      $t1, ANGLE
    li      $t1, 1
    sw      $t1, ANGLE_CONTROL
    li      $t2, 2
    sw      $t2, VELOCITY
    j       turn_right

build_bed:

    li      $t1, 0
    sw      $t1, ANGLE
    li      $t1, 1
    sw      $t1, ANGLE_CONTROL
    li      $t2, 0
    sw      $t2, VELOCITY

    li      $t3, 5
    sw      $t3, CRAFT          # build bed

    li      $t3, 0x00050f11     # place bed
    sw      $t3, PLACE_BLOCK    

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040e11     # place stone on the left of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f12     # place stone on the bot of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t0, 0x00000f10 # (x=15,y=19) 
    sw      $t0, BREAK_BLOCK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f10     # place stone on the top of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00041011     # place stone on the right of the bed
    sw      $t3, PLACE_BLOCK   

    li      $t0, 0x0f11 #  19 drink water
    sw      $t0, USE_BLOCK 

    



loop_: # Once done, enter an infinite loop so that your bot can be graded by QtSpimbot once 10,000,000 cycles have elapsed

    li      $t0, 0x00000e09 #  床左上的上面的石头 1
    sw      $t0, BREAK_BLOCK

    li      $t0, 0x00000f09 #  2
    sw      $t0, BREAK_BLOCK
    

    li      $t0, 0x00000d10 #  床左上的左面的石头 4
    sw      $t0, BREAK_BLOCK



    li      $t0, 0x00000e10 #  床左上角的石头 5
    sw      $t0, BREAK_BLOCK


    li      $t0, 0x00000f10 #  床上的石头 6
    sw      $t0, BREAK_BLOCK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f10     # place stone on the top of the bed
    sw      $t3, PLACE_BLOCK    


    li      $t0, 0x00001010 #  床右上角的树 7
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00001110 #  床右上角的树旁的树 8
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000c11 #  9
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000d11 #  10
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000e11 #  11
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040e11     # place stone on the left of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t0, 0x00001011 #  12
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00041011     # place stone on the right of the bed
    sw      $t3, PLACE_BLOCK    

    li      $t0, 0x00001111 #  13
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000d12 #  15
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000e12 #  16
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000f12 #  17
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t3, 4
    sw      $t3, CRAFT          # build stone
    li      $t3, 0x00040f12     # place stone on the right of the bed
    sw      $t3, PLACE_BLOCK   

    li      $t0, 0x00001012 #  18
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000e13 #  20
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x00000f13 #  21
    sw      $t0, BREAK_BLOCK
    sw      $t0, ATTACK

    li      $t0, 0x1112 #  19 drink water
    sw      $t0, USE_BLOCK

    j loop_

end_me:
    

.kdata
chunkIH:    .space 40
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
    move    $k1, $at        # Save $at
                            # NOTE: Don't touch $k1 or else you destroy $at!
.set at
    la      $k0, chunkIH
    sw      $a0, 0($k0)        # Get some free registers
    sw      $v0, 4($k0)        # by storing them to a global variable
    sw      $t0, 8($k0)
    sw      $t1, 12($k0)
    sw      $t2, 16($k0)
    sw      $t3, 20($k0)
    sw      $t4, 24($k0)
    sw      $t5, 28($k0)

    # Save coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    mfhi    $t0
    sw      $t0, 32($k0)
    mflo    $t0
    sw      $t0, 36($k0)

    mfc0    $k0, $13                # Get Cause register
    srl     $a0, $k0, 2
    and     $a0, $a0, 0xf           # ExcCode field
    bne     $a0, 0, non_intrpt



interrupt_dispatch:                 # Interrupt:
    mfc0    $k0, $13                # Get Cause register, again
    beq     $k0, 0, done            # handled all outstanding interrupts

    and     $a0, $k0, BONK_INT_MASK     # is there a bonk interrupt?
    bne     $a0, 0, bonk_interrupt

    and     $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
    bne     $a0, 0, timer_interrupt

    and     $a0, $k0, REQUEST_PUZZLE_INT_MASK
    bne     $a0, 0, request_puzzle_interrupt

    and     $a0, $k0, RESPAWN_INT_MASK
    bne     $a0, 0, respawn_interrupt

    li      $v0, PRINT_STRING       # Unhandled interrupt types
    la      $a0, unhandled_str
    syscall
    j       done

bonk_interrupt:
    sw      $0, BONK_ACK
    la      $t0, has_bonked
    li      $t1, 1
    sb      $t1, 0($t0)
    #Fill in your bonk handler code here
    j       interrupt_dispatch      # see if other interrupts are waiting

timer_interrupt:
    sw      $0, TIMER_ACK
    li $s7, 1
    j        interrupt_dispatch     # see if other interrupts are waiting

request_puzzle_interrupt:
    sw      $0, REQUEST_PUZZLE_ACK
    #Fill in your puzzle interrupt code here
    li      $s1, 1
    sw      $s1, REQUEST_PUZZLE_ACK

    j       interrupt_dispatch

respawn_interrupt:
    sw      $0, RESPAWN_ACK
    #Fill in your respawn handler code here
    j       interrupt_dispatch

non_intrpt:                         # was some non-interrupt
    li      $v0, PRINT_STRING
    la      $a0, non_intrpt_str
    syscall                         # print out an error message
    # fall through to done

done:
    la      $k0, chunkIH

    # Restore coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    lw      $t0, 32($k0)
    mthi    $t0
    lw      $t0, 36($k0)
    mtlo    $t0

    lw      $a0, 0($k0)             # Restore saved registers
    lw      $v0, 4($k0)
    lw      $t0, 8($k0)
    lw      $t1, 12($k0)
    lw      $t2, 16($k0)
    lw      $t3, 20($k0)
    lw      $t4, 24($k0)
    lw      $t5, 28($k0)

.set noat
    move    $at, $k1        # Restore $at
.set at
    eret

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
        sub	$sp, $sp, 24
	sw	$ra, 0 ($sp)
	sw	$s0, 4 ($sp)                    # marker
        sw      $s1, 8 ($sp)                    # canvas
        sw      $s2, 12($sp)                    # region_count
        sw      $s3, 16($sp)                    # row
        sw      $s4, 20($sp)                    # col
	
        move    $s0, $a0
        move    $s1, $a1
	li	$s2, 0			        # unsigned int region_count = 0;
        
        
        li      $s3, 0                          # row = 0
outer_loop:                                     # for (unsigned int row = 0; row < canvas->height; row++) {
        lw      $t0, 0($s1)                     # canvas->height
        bge     $s3, $t0, end_outer_loop        # row < canvas->height : fallthrough

        li      $s4, 0                          # col = 0
inner_loop:                                     # for (unsigned int col = 0; col < canvas->width; col++) {
        lw      $t0, 4($s1)                     # canvas->width
        bge     $s4, $t0, end_inner_loop        # col < canvas->width : fallthrough

        
        # unsigned char curr_char = canvas->canvas[row][col];
        lw      $t1, 12($s1)                    # &(canvas->canvas)
        mul     $t2, $s3, 4                     # $t2 = row * 4
        add     $t2, $t2, $t1                   # $t2 = canvas->canvas + row * sizeof(char*) = canvas[row]
        lw	$t1, 0($t2)		        # $t1 = &char = char* = & canvas[row][0]
        add	$t1, $s4, $t1           	# $t1 = &canvas[row][col]
        lb	$t1, 0($t1)		        # $t1 = canvas[row][col] = curr_char

        lb      $t2, 8($s1)                     # $t2 = canvas->pattern 

        # temps:        $t1 = curr_char         $t2 = canvas->pattern

        # if (curr_char != canvas->pattern && curr_char != marker) {
        beq     $t1, $t2, endif                 # if (curr_char != canvas->pattern) fall
        beq	$t1, $s0, endif                 # if (curr_char != marker)          fall
        
        add     $s2, $s2, 1                     # region_count ++;
        move    $a0, $s3                        # (row,
        move    $a1, $s4                        #  col,
        move    $a2, $s0                        #  marker,
        move    $a3, $s1                        #  canvas);
        jal     flood_fill                      # flood_fill(row, col, marker, canvas);
 
endif:


        add     $s4, $s4, 1                     # col++
        j       inner_loop                      # loop again
end_inner_loop:


        add     $s3, $s3, 1                     # row++
        j       outer_loop                      # loop again
end_outer_loop:

	move	$v0, $s2		# Copy return val
	lw	$ra, 0($sp)
	lw	$s0, 4 ($sp)                    # marker
        lw      $s1, 8 ($sp)                    # canvas
        lw      $s2, 12($sp)                    # region_count
        lw      $s3, 16($sp)                    # row
        lw      $s4, 20($sp)                    # col

	add	$sp, $sp, 24
	jr      $ra


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
        sub     $sp, $sp, 20
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)

        move    $s0, $a0                # line
        move    $s1, $a1                # canvas
        move    $s2, $a2                # solution

        li      $s3, 0                  # unsigned int i = 0;
loop:
        lw	$t0, 0($s0)		# $t0 = lines->num_lines
        bge     $s3, $t0, end           # i < lines->num_lines : fallthrough
        
        #lines->coords[0][i];
        lw	$t1, 4($s0)		# $t1 = &(lines->coords[0][0])
        lw	$t2, 8($s0)		# $t2 = &(lines->coords[1][0])

        mul     $t3, $s3, 4             # i * sizeof(int*)
        add     $t1, $t3, $t1           # $t1 = &(lines->coords[0][i])
        add     $t2, $t3, $t2           # $t2 = &(lines->coords[1][i])

        lw      $a0, 0($t1)             # $a0 = lines->coords[0][i] = start_pos
        lw      $a1, 0($t2)             # $a1 = lines->coords[0][i] = end_pos
        move    $a2, $s1                # $a2 = canvas
        jal     draw_line               # draw_line(start_pos, end_pos, canvas);

        li      $a0, 65                 # Immediate value A
        rem     $t1, $s3, 2             # i % 2
        add     $a0, $a0, $t1           # 'A' or 'B'
        move    $a1, $s1
        jal     count_disjoint_regions_step  # count_disjoint_regions_step('A' + (i % 2), canvas);
        # $v0 = count_disjoint_regions_step('A' + (i % 2), canvas);

        lw      $t0, 4($s2)             # &counts = &counts[0]
        mul     $t1, $s3, 4             #  i * sizeof(unsigned int)
        add     $t0, $t1, $t0           # *counts[i]
        sw      $v0, 0($t0)

##         // Update the solution struct. Memory for counts is preallocated.
##         solution->counts[i] = count;


        add     $s3, $s3, 1             # i++
        j       loop
end:
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        add     $sp, $sp, 20
        jr      $ra


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
        lw      $t0, 4($a2)     # t0 = width = canvas->width
        li      $t1, 1          # t1 = step_size = 1
        sub     $t2, $a1, $a0   # t2 = end_pos - start_pos
        blt     $t2, $t0, cont
        move    $t1, $t0        # step_size = width;
cont:
        move    $t3, $a0        # t3 = pos = start_pos
        add     $t4, $a1, $t1   # t4 = end_pos + step_size
        lw      $t5, 12($a2)    # t5 = &canvas->canvas
        lbu     $t6, 8($a2)     # t6 = canvas->pattern
for_loop:
        beq     $t3, $t4, end_for_3
        div     $t3, $t0        #
        mfhi    $t7             # t7 = pos % width
        mflo    $t8             # t8 = pos / width
        mul     $t9, $t8, 4		# t9 = pos/width*4
        add     $t9, $t9, $t5   # t9 = &canvas->canvas[pos / width]
        lw      $t9, 0($t9)     # t9 = canvas->canvas[pos / width]
        add     $t9, $t9, $t7
        sb      $t6, 0($t9)     # canvas->canvas[pos / width][pos % width] = canvas->pattern
        add     $t3, $t3, $t1   # pos += step_size
        j       for_loop
        
end_for_3:
        jr      $ra

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
        # Your code goes here :)
	blt	$a0, $zero, end_33		# row < 0 
	blt	$a1, $zero, end_33		# col < 0
	lw	$t0, 0($a3)		# $t0 = canvas->height
	bge	$a0, $t0, end_33		# row >= canvas->height
	lw	$t0, 4($a3)		# $t0 = canvas->width
	bge	$a1, $t0, end_33		# col >= canvas->width
	j 	recur			# NONE TRUE

recur:
	# Find curr
	lw	$t0, 12($a3)		# canvas->canvas
	mul	$t1, $a0, 4		# row * sizeof(char*)
	add	$t1, $t1, $t0		# $t1 = canvas->canvas + row * sizeof(char*) = canvas[row]
	lw	$t2, 0($t1)		# $t2 = &char = char* = & canvas[row][0]
	add	$t2, $a1, $t2		# $t2 = &canvas[row][col]
	lb	$t3, 0($t2)		# $t3 = curr
	
	lb	$t4, 8($a3)		# $t4 = canvas->pattern
	
	beq	$t3, $t4, end_33		# curr == canvas->pattern : break 
	beq	$t3, $a2, end_33		# curr == marker          : break
	
	#FLOODFILL
	sb	$a2, ($t2) 
	
	# Save depenedecies
	sub	$sp, $sp, 12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	move	$s0, $a0
	move	$s1, $a1
	
	sub	$a0, $s0, 1
	move	$a1, $s1
	jal	flood_fill

	move	$a0, $s0
	add	$a1, $s1, 1
	jal	flood_fill

	add	$a0, $s0, 1
	move	$a1, $s1
	jal	flood_fill

	move	$a0, $s0
	sub	$a1, $s1, 1
	jal	flood_fill
	
	# Restore VARS
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	add	$sp, $sp, 12
end_33:
	jr 	$ra
