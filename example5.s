.data
MESS_EXIT:  .asciiz  "\nExit Program\n"

.text   
.globl main             
main:
L1:	jal	getc		# Call getc
	addi	$sp,$sp,-4	# Push $v0 on the stack
	sw	$v0,0($sp)
	move	$a0,$v0		# Call putc
	jal	putc
	lw	$v0,0($sp)	# Pop $v0 from the stack
	addi	$sp,$sp,4
	li	$s0,10		# 10 = <enter> in ASCII
	bne	$v0,$s0,L1

	la	$a0,MESS_EXIT
	li	$v0,4
	syscall
        li	$v0,10       	# exit(0)
        syscall          

getc:	li	$v0,12
	syscall
	jr	$ra

putc:	li	$v0,11
	syscall
	jr	$ra