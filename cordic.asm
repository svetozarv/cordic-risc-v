.eqv CON_PUTINT,  1
.eqv CON_PUTSTR,  4
.eqv CON_PUTCHAR, 11
.eqv CON_GETINT,  5
.eqv SYS_EXIT0,   10

    .data
    .align 4
atan_LUT:                     # Represented in BAM, 1° ≈ 11930464.711
    .word 536870912           # arctan(2^-0), approx. 45°
    .word 316933405           # arctan(2^-1), approx. 26.56°
    .word 167458907           # arctan(2^-2), approx. 14.03°
    .word 85004756            # arctan(2^-3), approx. 7.12°
    .word 42667331            # arctan(2^-4), approx. 3.57°
    .word 21354465            # arctan(2^-5), approx. 1.79°
    .word 10679838            # arctan(2^-6), approx. 0.896°
    .word 5340245             # arctan(2^-7), approx. 0.448°
    .word 2670163             # arctan(2^-8), ...
    .word 1335086             # arctan(2^-9)
    .word 667544              # arctan(2^-10)
    .word 333772              # arctan(2^-11)
    .word 166886              # arctan(2^-12)
    .word 83443               # arctan(2^-13)
    .word 41721               # arctan(2^-14)
    .word 20860               # arctan(2^-15)
    .word 10430               # arctan(2^-16)
    .word 5215                # arctan(2^-17)
    .word 2607                # arctan(2^-18)
    .word 1303                # arctan(2^-19)
    .word 651                 # arctan(2^-20)
    .word 325                 # arctan(2^-21)
    .word 162                 # arctan(2^-22)
    .word 81                  # arctan(2^-23)
    .word 40                  # arctan(2^-24)
    .word 20                  # arctan(2^-25)
    .word 10                  # arctan(2^-26)
    .word 5                   # arctan(2^-27)
    .word 2                   # arctan(2^-28)
    .word 1                   # arctan(2^-29)
    # 30 iterations, no sense in more because our precision is limited
prompt:	            .asciz "\nEnter degrees:"
result_sine:	    .asciz "\nsin: "
result_cosine:	    .asciz "\ncos: "
accumulator_BAM:	.asciz "\nZ = "
in_Q229:	        .asciz "\nin_Q229: "
human_readable:	    .asciz "\nHuman readable: "

    .text
    .global main
main:
    li a7, CON_PUTSTR
    la a0, prompt
    ecall

    li a7, CON_GETINT
    ecall

    li a7, 11930465	    # = (2**31 / 180) ; conversion to BAM
    mul s2, a0, a7      # s2 = Z (accumulator in BAM)
    li s0, 326017688    # x = K, (K = 0.6072529350 ; 1(one) in Q2.29 = 536870912)
    li s1, 0            # y = 0
    li s3, 30           # loop counter
    la s4, atan_LUT

    beqz s2, handle_0

mainloop:
    beqz s3, end

    li a7, 0x80000000
    and a2, s2, a7	    # save sign of Z in a2
    mv a0, s0           # save current x and y
    mv a1, s1

    # shift them
    mv a3, s3		    # i
    neg a3, a3		    # -i
    addi a3, a3, 30	    # 30 - i
    sra s0, a1, a3	    # y_i >> i
    sra s1, a0, a3	    # x_i >> i

    lw a4, (s4)

    neg s0, s0
    beqz a2, compas_positive    # multiply the result by the sign of Z
    neg s0, s0
    neg s1, s1
    neg a4, a4
compas_positive:
    add s0, s0, a0      # add and save everything to the x and y
    add s1, s1, a1

    sub s2, s2, a4      # Z_new = Z_old - atan_LUT[i]

    addi s4, s4, 4	    # update pointers
    addi s3, s3, -1
    b mainloop
handle_0:
    li s0, 1
    li s1, 0
end:
    # ============ print results in Q2.29 (Fixed point format) ============
    li a7, CON_PUTSTR
    la a0, in_Q229
    ecall

    li a7, CON_PUTSTR
    la a0, result_cosine
    ecall
    li a7, CON_PUTINT
    mv a0, s0
    ecall

    li a7, CON_PUTSTR
    la a0, result_sine
    ecall
    li a7, CON_PUTINT
    mv a0, s1
    ecall

    li a7, CON_PUTSTR
    la a0, accumulator_BAM
    ecall
    li a7, CON_PUTINT
    mv a0, s2
    ecall

    # ============ print results in human readable format ============
    li a7, CON_PUTCHAR
    li a0, '\n'
    ecall
    li a7, CON_PUTSTR
    la a0, human_readable
    ecall

    # ========== print cos ==========
    li a7, CON_PUTSTR
    la a0, result_cosine
    ecall

    bgez s0, cos_is_positive
    li a7, CON_PUTCHAR  # print minus and negate so latter computing is easier
    li a0, '-'
    ecall
    neg s0, s0
cos_is_positive:
    li a7, CON_PUTINT
    mv a0, s0
    srai a0, a0, 29     # integer part
    ecall

    li a7, CON_PUTCHAR
    li a0, '.'
    ecall

    mv t0, s0
    li t1, 0x1FFFFFFF	# bitmask for 29 first bits
    li t2, 10
    and t0, t0, t1	    # get the 29 bits
loop_print_cos:
    beqz t0, end_of_print_cos
    mul t3, t0, t2 	    # multiply by ten (could be implemented with bitshift, lea or eqv.)
    mulhu t4, t0, t2
    slli t4, t4, 3
    srli t3, t3, 29
    or t5, t3, t4	    # combine result of multiplication from t4 and t3

    li a7, CON_PUTINT
    mv a0, t5
    ecall

    and t0, t3, t1 	    # clear the integer part in t3 (prepare for the next iteration)
    b loop_print_cos
end_of_print_cos:

    li a7, SYS_EXIT0
    ecall
