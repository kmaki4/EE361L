.data
MESS_EXIT:  .asciiz  "\nExit Program\n"

.text   
.globl main      

main:

L1:	
	jal	getc			# Go to getc
	addi	$sp,$sp,-4	# Push $v0 on the stack
	sw		$v0,0($sp)	# Based on this, I want to adjust getc to still use $v0
	move	$a0,$v0

	jal		putc		# Go to putc
	lw		$v0,0($sp)	# Pop $v0 from the stack
	addi	$sp,$sp,4
	li		$s0,10		# 10 = <enter> in ASCII
	bne		$v0,$s0,L1

	la		$a0,MESS_EXIT
	li		$v0,4
	syscall

    li	$v0,10       	# exit(0)
    syscall         

# Not much to say here, follow the handout
getc:	
	lw 		$t0,0xffff0000
	andi	$t0,$t0,1
	beq		$t0,$0,getc	# This part is different from the algorithm on the handout, bne does not work
	lw		$v0,0xffff0004
	jr		$ra

putc:	
	lw 		$t0,0xffff0008
	andi	$t0,$t0,1
	beq		$t0,$0,putc # This part is different from the algorithm on the handout, bne does not work
	sw		$a0,0xffff000c
	jr		$ra