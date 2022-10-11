
.data   
MSG1:           .asciiz       "civic"
MSG2:           .asciiz       "wiliki"
MSG3:           .space        40
MSG_YES:        .asciiz       ": yes\n"
MSG_NO:         .asciiz       ": no\n"
PROMPT:         .asciiz       "Enter a word: "
END_SPACE:      .asciiz       " "
END_ENTER:      .asciiz       "\n"

.text                                  # This is for the program
.globl main                            # This allows the label 'main' to be recognized

#----- display_result(char msg[], int result) -----
display_result:
        li      $v0, 4
        syscall
        beq     $a1, $0,disp_res_no
        li      $v0, 4                 # display 'yes'
        la      $a0, MSG_YES
        syscall
        j       disp_res_done

disp_res_no:
        li      $v0, 4
        la      $a0, MSG_NO
        syscall

disp_res_done:
        jr   $ra

#----- msg_length(char msg[])-----
# Changed from the original to make less confusing
msg_length:
        add     $v0, $0, $0             # Set the length count to 0
        move    $t0, $a0                # $t0 now contains the start of the string which was passed from $a0

        la      $t2, END_ENTER          # Set up the break condition for a newline input
        lbu     $t2, 0($t2)             # Overwrite $t2 to be the content of address saved in $t2 (address of END_ENTER)
        la      $t3, END_SPACE          # Set up the break condition for a space input
        lbu     $t3, 0($t3)             # Overwrite $t3 to be the content of address saved in $t2 (address of END_ENTER)

        j       msg_length_loop         # I added this line here so that we for sure know
                                        # that we are moving into a loop function

msg_length_loop:
        lbu     $t1, 0($t0)             # Lets load the first byte into $t1
        beq     $t1, $0,msg_length_done # Determine if we hit a zero byte, and if we did, we can exit the loop

        beq     $t1, $t2,msg_length_done# New condition to check if a newline input termination
        beq     $t1, $t3,msg_length_done# New condition to check for a space input termination

        addi    $t0, $t0, 1             # Move $t0 to the next byte
        addi    $v0, $v0, 1             # Increment the length count by 1
        j       msg_length_loop         # Lets keep going on with the loop

msg_length_done:
        jr      $ra                     # If we are met conditions to exit the loop, let's return back 
                                        # to main (the original caller). Note that the length of the string we 
                                        # just found is stored in $v0

#----- palindrome(char msg[], int length) -----
# The algorithm we need to implement here is simple. First we'd like to check if the first byte of the string
# is equivalent to the last byte (of course not including a zero byte), then work inwards to check each corresponding
# byte.
# What exactly will I need?
# I'm going to need:
#       - The address of the string
#       - 2 registers to serve as indexers (address indexers)
#       - 2 registers to save the byte chars
#       - A condition to break away early in case the string is not a palindrome
#       - An early stop condition to be efficient can be implemented as well so we don't have to cross index.
#         Since a palindrome is expected to be symmetrical, we only need to go through the algorithm as long as
#         the right hand index > left hand index. Otherwise, we have met in the middle and can break early.
palindrome:
        move    $t0, $a0                # Address of the string is saved to $t0 (this will be the left hand indexer)
        move    $t2, $a1                # Length of string stored in $t2
        add     $t2, $t0, $t2           # Overwrite $t2, with the address of the last byte of the message
                                        # $t2 will serve as my right hand indexer
        addi    $t2, $t2, -1
        lbu     $t3, 0($t0)             # Store the content contained in the address stored in $t0 to $t3
        lbu     $t4, 0($t2)             # Store the content contained in the address stored in $t2 to $t4
        bne     $t3, $t4, palindrome_no # If the bytes indexed aren't equal then it's not a palindrome
        addi    $t0, $t0, 1             # Move left hand indexer in by 1 byte (to the right)
        addi    $t2, $t2, -1            # Move right hand indexer in by 1 byte (to the left)
        slt     $t6, $t2, $t0           # Is the right hand indexer less than the left hand indexer?
                                        # the next line will check the boolean result (1 if true, 0 if false)
        beq     $t6, $zero, palindrome_done

palindrome_no:
        li      $v0, 0  
        jr      $ra

palindrome_done:
        li      $v0, 1
        jr      $ra

main:
        la      $a0, MSG1               # Save the address of MSG1 (civic) to $a0
        jal     msg_length              # Determine the length of the message
                                        # Note that the length value gets saved to 
        move    $a1, $v0                # Lets move the length result ($v0) to $a1
        jal     palindrome              # Now let's determine if the string is a palindrome
        move    $a1, $v0                # Lets move the boolean palindrome result into $a1 to be processed by display_result
        jal     display_result          # Go display the result

        la      $a0, MSG2               # Same as previous
        jal     msg_length
        move    $a1, $v0
        jal     palindrome
        move    $a1, $v0
        jal     display_result

        li      $v0, 4                  # Here I will use $a0 just as a temporary storage, we will use $a0 as we have been after
        la      $a0, PROMPT             # Let's display this prompt to have the user enter a word
        syscall

        li      $v0, 8                  # Get ready to take in a string
        la      $a0, MSG3               # Tell the system where to store the string ($a0)
        li      $a1, 40                 # We must also tell the system the max space alloted for the user input
        syscall

# At this point, note that we will need to adjust the message length functions to accomodate for the user entering a new line command
# (return/enter button) which is equivalent to 'a' in the ascii hexadecimal. Many of you were wondering why your message lengths were
# returning an extra character and this is where the problem is.

# How do we take care of this?
# I have opted to set labels in the .data section to provide stopping conditions for the new and improved message length function
        la      $a0, MSG3               # Same as previous
        jal     msg_length
        move    $a1, $v0
        jal     palindrome
        move    $a1, $v0
        jal     display_result
       
        li  $v0,10                      # Exit
        syscall          
