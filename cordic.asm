.eqv CON_PUTINT, 1
.eqv CON_PUTSTR, 4
.eqv CON_GETINT, 5
.eqv SYS_EXIT0, 10

    .data
    .align 4
atan_LUT:                     # Represented in BAM, 1° ≈ 11930464.711
    .word 536870912           # arctan(2^-0), ok. 45 stopni
    .word 316933405           # arctan(2^-1), ok. 26.56 stopni
    .word 167458907           # arctan(2^-2), ok. 14.03 stopni
    .word 85004756            # arctan(2^-3), ok. 7.12 stopni
    .word 42667331            # arctan(2^-4), ok. 3.57 stopni
    .word 21354465            # arctan(2^-5), ...
    .word 10679838            # arctan(2^-6)
    .word 5340245             # arctan(2^-7)
    .word 2670163             # arctan(2^-8)
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
prompt:	            .asciz "Enter degrees:\n"
result_sine_Q229:	.asciz "sin:\n"
result_cosine_Q229:	.asciz "cos:\n"
accumulator_BAM:	.asciz "Z = :\n"

    .text
    .global main
main:
    li a7, CON_PUTSTR
    la a0, prompt
    ecall

    li a7, CON_GETINT
    ecall

    li a7, 11930465	# = (2**31 / 180) ; conversion to BAM
    mul s2, a0, a7      # s2 = Z (accumulator in BAM)
    li s0, 326017688    # x = K, (K = 0.6072529350 ; 1(one) in Q2.29 = 536870912)
    li s1, 0            # y = 0
    li s3, 30           # loop counter
    la s4, atan_LUT

mainloop:
    beqz s3, end
    beqz s2, handle_0

    # save sign of Z in a2
    andi a2, s2, 0x80000000

    # save current x and y
    mv a0, s0
    mv a1, s1

    # shift them
    mv a3, s3		# i
    neg a3, a3		# -i
    addi a3, a3, 30	# 30 - i
    sra a0, a0, a3	# x_i >> i
    sra a1, a1, a3	# y_i >> i

    # multiply the result by the sing of Z
    neg a0, a0
    beqz a2, compas_positive
    neg a0, a0
    neg a1, a1
compas_positive:
    # add and save everything to the x and y
    addi s0, s0, a0
    addi s1, s1, a1

    # Z_new = Z_old - atan_LUT[i]
    lw a4, (t4)
    sub s2, s2, a4

    # update pointers
    addi s4, s4, 4	# or 1 ????
    addi s3, s3, -1
    b mainloop
handle_0:
    mv s0, 1
    mv s1, 0

end:
    li a7, CON_PUTSTR
    la a0, result_cosine_Q229
    ecall
    li a7, CON_PUTINT
    li a0, s0
    ecall


    li a7, CON_PUTSTR
    la a0, result_sine_Q229
    ecall
    li a7, CON_PUTINT
    li a0, s1
    ecall

    li a7, CON_PUTSTR
    la a0, accumulator_BAM
    ecall
    li a7, CON_PUTINT
    li a0, s2
    ecall

    li a7, SYS_EXIT0
    ecall
