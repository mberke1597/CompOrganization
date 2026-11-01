	.file	"main.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_zmmul1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
# GNU C99 (xPack GNU RISC-V Embedded GCC x86_64) version 15.2.0 (riscv-none-elf)
#	compiled by GNU C version 15.2.0, GMP version 6.3.0, MPFR version 4.2.2, MPC version 1.3.1, isl version isl-0.27-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -mabi=ilp32 -misa-spec=20191213 -march=rv32im_zmmul -O0 -std=c99 -ffreestanding -fno-builtin
	.text
	.globl	SID
	.section	.srodata,"a"
	.align	2
	.type	SID, @object
	.size	SID, 4
SID:
	.word	1230021
	.globl	data
	.bss
	.align	2
	.type	data, @object
	.size	data, 180
data:
	.zero	180
	.globl	median
	.section	.sbss,"aw",@nobits
	.align	2
	.type	median, @object
	.size	median, 4
median:
	.zero	4
	.globl	min_v
	.align	2
	.type	min_v, @object
	.size	min_v, 4
min_v:
	.zero	4
	.globl	max_v
	.align	2
	.type	max_v, @object
	.size	max_v, 4
max_v:
	.zero	4
	.globl	swaps
	.align	2
	.type	swaps, @object
	.size	swaps, 4
swaps:
	.zero	4
	.text
	.align	2
	.globl	lcg_next
	.type	lcg_next, @function
lcg_next:
	addi	sp,sp,-32	#,,
	sw	ra,28(sp)	#,
	sw	s0,24(sp)	#,
	addi	s0,sp,32	#,,
	sw	a0,-20(s0)	# x, x
# src/main.c:10:     return 1664525u * x + 1013904223u;
	lw	a4,-20(s0)		# tmp137, x
	li	a5,1662976		# tmp139,
	addi	a5,a5,1549	#, tmp138, tmp139
	mul	a4,a4,a5	# _1, tmp137, tmp138
# src/main.c:10:     return 1664525u * x + 1013904223u;
	li	a5,1013903360		# tmp141,
	addi	a5,a5,863	#, tmp140, tmp141
	add	a5,a4,a5	# tmp140, _3, _1
# src/main.c:11: }
	mv	a0,a5	#, <retval>
	lw	ra,28(sp)		#,
	lw	s0,24(sp)		#,
	addi	sp,sp,32	#,,
	jr	ra		#
	.size	lcg_next, .-lcg_next
	.align	2
	.globl	out_of_order
	.type	out_of_order, @function
out_of_order:
	addi	sp,sp,-32	#,,
	sw	ra,28(sp)	#,
	sw	s0,24(sp)	#,
	addi	s0,sp,32	#,,
	sw	a0,-20(s0)	# a, a
	sw	a1,-24(s0)	# b, b
	sw	a2,-28(s0)	# desc, desc
# src/main.c:15:     if (desc)
	lw	a5,-28(s0)		# tmp138, desc
	beq	a5,zero,.L4	#, tmp138,,
# src/main.c:16:         return a < b;
	lw	a4,-20(s0)		# tmp140, a
	lw	a5,-24(s0)		# tmp141, b
	slt	a5,a4,a5	# tmp141, tmp142, tmp140
	andi	a5,a5,0xff	# _1, _1
	j	.L5		#
.L4:
# src/main.c:17:     return a > b;
	lw	a4,-20(s0)		# tmp144, a
	lw	a5,-24(s0)		# tmp145, b
	sgt	a5,a4,a5	# tmp146, tmp144, tmp145
	andi	a5,a5,0xff	# _2, _2
.L5:
# src/main.c:18: }
	mv	a0,a5	#, <retval>
	lw	ra,28(sp)		#,
	lw	s0,24(sp)		#,
	addi	sp,sp,32	#,,
	jr	ra		#
	.size	out_of_order, .-out_of_order
	.align	2
	.globl	generate
	.type	generate, @function
generate:
	addi	sp,sp,-32	#,,
	sw	ra,28(sp)	#,
	sw	s0,24(sp)	#,
	addi	s0,sp,32	#,,
# src/main.c:22:     unsigned int x = (unsigned int)SID;
	li	a5,1228800		# tmp138,
	addi	a5,a5,1221	#, SID.0_1, tmp138
# src/main.c:22:     unsigned int x = (unsigned int)SID;
	sw	a5,-20(s0)	# SID.0_1, x
# src/main.c:23:     for (int i = 0; i < N; i++) {
	sw	zero,-24(s0)	#, i
# src/main.c:23:     for (int i = 0; i < N; i++) {
	j	.L7		#
.L8:
# src/main.c:24:         x = lcg_next(x);
	lw	a0,-20(s0)		#, x
	call	lcg_next		#
	sw	a0,-20(s0)	#, x
# src/main.c:25:         data[i] = (int)((x >> 16) % 1000u);
	lw	a5,-20(s0)		# tmp139, x
	srli	a4,a5,16	#, _2, tmp139
# src/main.c:25:         data[i] = (int)((x >> 16) % 1000u);
	li	a5,274878464		# tmp142,
	addi	a5,a5,-557	#, tmp141, tmp142
	mulhu	a5,a4,a5	# tmp140, _2, tmp141
	srli	a5,a5,6	#, _3, tmp140
	li	a3,1000		# tmp144,
	mul	a5,a5,a3	# tmp143, _3, tmp144
	sub	a5,a4,a5	# _3, _2, tmp143
# src/main.c:25:         data[i] = (int)((x >> 16) % 1000u);
	mv	a3,a5	# _4, _3
# src/main.c:25:         data[i] = (int)((x >> 16) % 1000u);
	lui	a5,%hi(data)	# tmp145,
	addi	a4,a5,%lo(data)	# tmp146, tmp145,
	lw	a5,-24(s0)		# tmp147, i
	slli	a5,a5,2	#, tmp148, tmp147
	add	a5,a4,a5	# tmp148, tmp149, tmp146
	sw	a3,0(a5)	# _4, data[i_6]
# src/main.c:23:     for (int i = 0; i < N; i++) {
	lw	a5,-24(s0)		# tmp151, i
	addi	a5,a5,1	#, i_14, tmp151
	sw	a5,-24(s0)	# i_14, i
.L7:
# src/main.c:23:     for (int i = 0; i < N; i++) {
	lw	a4,-24(s0)		# tmp152, i
	li	a5,44		# tmp153,
	ble	a4,a5,.L8	#, tmp152, tmp153,
# src/main.c:27: }
	nop	
	nop	
	lw	ra,28(sp)		#,
	lw	s0,24(sp)		#,
	addi	sp,sp,32	#,,
	jr	ra		#
	.size	generate, .-generate
	.align	2
	.globl	sort
	.type	sort, @function
sort:
	addi	sp,sp,-48	#,,
	sw	ra,44(sp)	#,
	sw	s0,40(sp)	#,
	addi	s0,sp,48	#,,
	sw	a0,-36(s0)	# desc, desc
# src/main.c:31:     for (int pass = 0; pass < N - 1; pass++)
	sw	zero,-20(s0)	#, pass
# src/main.c:31:     for (int pass = 0; pass < N - 1; pass++)
	j	.L10		#
.L14:
# src/main.c:32:         for (int j = 0; j < N - 1 - pass; j++)
	sw	zero,-24(s0)	#, j
# src/main.c:32:         for (int j = 0; j < N - 1 - pass; j++)
	j	.L11		#
.L13:
# src/main.c:33:             if (out_of_order(data[j], data[j + 1], desc)) {
	lui	a5,%hi(data)	# tmp144,
	addi	a4,a5,%lo(data)	# tmp145, tmp144,
	lw	a5,-24(s0)		# tmp146, j
	slli	a5,a5,2	#, tmp147, tmp146
	add	a5,a4,a5	# tmp147, tmp148, tmp145
	lw	a3,0(a5)		# _1, data[j_12]
# src/main.c:33:             if (out_of_order(data[j], data[j + 1], desc)) {
	lw	a5,-24(s0)		# tmp149, j
	addi	a5,a5,1	#, _2, tmp149
# src/main.c:33:             if (out_of_order(data[j], data[j + 1], desc)) {
	lui	a4,%hi(data)	# tmp150,
	addi	a4,a4,%lo(data)	# tmp151, tmp150,
	slli	a5,a5,2	#, tmp152, _2
	add	a5,a4,a5	# tmp152, tmp153, tmp151
	lw	a5,0(a5)		# _3, data[_2]
	lw	a2,-36(s0)		#, desc
	mv	a1,a5	#, _3
	mv	a0,a3	#, _1
	call	out_of_order		#
	mv	a5,a0	# _4,
# src/main.c:33:             if (out_of_order(data[j], data[j + 1], desc)) {
	beq	a5,zero,.L12	#, _4,,
# src/main.c:34:                 int t = data[j];
	lui	a5,%hi(data)	# tmp154,
	addi	a4,a5,%lo(data)	# tmp155, tmp154,
	lw	a5,-24(s0)		# tmp156, j
	slli	a5,a5,2	#, tmp157, tmp156
	add	a5,a4,a5	# tmp157, tmp158, tmp155
	lw	a5,0(a5)		# tmp159, data[j_12]
	sw	a5,-28(s0)	# tmp159, t
# src/main.c:35:                 data[j] = data[j + 1];
	lw	a5,-24(s0)		# tmp160, j
	addi	a5,a5,1	#, _5, tmp160
# src/main.c:35:                 data[j] = data[j + 1];
	lui	a4,%hi(data)	# tmp161,
	addi	a4,a4,%lo(data)	# tmp162, tmp161,
	slli	a5,a5,2	#, tmp163, _5
	add	a5,a4,a5	# tmp163, tmp164, tmp162
	lw	a4,0(a5)		# _6, data[_5]
# src/main.c:35:                 data[j] = data[j + 1];
	lui	a5,%hi(data)	# tmp165,
	addi	a3,a5,%lo(data)	# tmp166, tmp165,
	lw	a5,-24(s0)		# tmp167, j
	slli	a5,a5,2	#, tmp168, tmp167
	add	a5,a3,a5	# tmp168, tmp169, tmp166
	sw	a4,0(a5)	# _6, data[j_12]
# src/main.c:36:                 data[j + 1] = t;
	lw	a5,-24(s0)		# tmp170, j
	addi	a5,a5,1	#, _7, tmp170
# src/main.c:36:                 data[j + 1] = t;
	lui	a4,%hi(data)	# tmp171,
	addi	a4,a4,%lo(data)	# tmp172, tmp171,
	slli	a5,a5,2	#, tmp173, _7
	add	a5,a4,a5	# tmp173, tmp174, tmp172
	lw	a4,-28(s0)		# tmp175, t
	sw	a4,0(a5)	# tmp175, data[_7]
# src/main.c:37:                 swaps++;
	lui	a5,%hi(swaps)	# tmp176,
	lw	a5,%lo(swaps)(a5)		# swaps.1_8, swaps
	addi	a4,a5,1	#, _9, swaps.1_8
	lui	a5,%hi(swaps)	# tmp177,
	sw	a4,%lo(swaps)(a5)	# _9, swaps
.L12:
# src/main.c:32:         for (int j = 0; j < N - 1 - pass; j++)
	lw	a5,-24(s0)		# tmp179, j
	addi	a5,a5,1	#, j_26, tmp179
	sw	a5,-24(s0)	# j_26, j
.L11:
# src/main.c:32:         for (int j = 0; j < N - 1 - pass; j++)
	li	a4,44		# tmp180,
	lw	a5,-20(s0)		# tmp181, pass
	sub	a5,a4,a5	# _10, tmp180, tmp181
# src/main.c:32:         for (int j = 0; j < N - 1 - pass; j++)
	lw	a4,-24(s0)		# tmp182, j
	blt	a4,a5,.L13	#, tmp182, _10,
# src/main.c:31:     for (int pass = 0; pass < N - 1; pass++)
	lw	a5,-20(s0)		# tmp184, pass
	addi	a5,a5,1	#, pass_19, tmp184
	sw	a5,-20(s0)	# pass_19, pass
.L10:
# src/main.c:31:     for (int pass = 0; pass < N - 1; pass++)
	lw	a4,-20(s0)		# tmp185, pass
	li	a5,43		# tmp186,
	ble	a4,a5,.L14	#, tmp185, tmp186,
# src/main.c:39: }
	nop	
	nop	
	lw	ra,44(sp)		#,
	lw	s0,40(sp)		#,
	addi	sp,sp,48	#,,
	jr	ra		#
	.size	sort, .-sort
	.align	2
	.globl	stats
	.type	stats, @function
stats:
	addi	sp,sp,-32	#,,
	sw	ra,28(sp)	#,
	sw	s0,24(sp)	#,
	addi	s0,sp,32	#,,
# src/main.c:43:     min_v = max_v = data[0];
	lui	a5,%hi(data)	# tmp143,
	addi	a5,a5,%lo(data)	# tmp144, tmp143,
	lw	a4,0(a5)		# _1, data[0]
# src/main.c:43:     min_v = max_v = data[0];
	lui	a5,%hi(max_v)	# tmp145,
	sw	a4,%lo(max_v)(a5)	# _1, max_v
# src/main.c:43:     min_v = max_v = data[0];
	lui	a5,%hi(max_v)	# tmp146,
	lw	a4,%lo(max_v)(a5)		# max_v.2_2, max_v
	lui	a5,%hi(min_v)	# tmp147,
	sw	a4,%lo(min_v)(a5)	# max_v.2_2, min_v
# src/main.c:44:     for (int i = 1; i < N; i++) {
	li	a5,1		# tmp148,
	sw	a5,-20(s0)	# tmp148, i
# src/main.c:44:     for (int i = 1; i < N; i++) {
	j	.L16		#
.L19:
# src/main.c:45:         if (data[i] < min_v)
	lui	a5,%hi(data)	# tmp149,
	addi	a4,a5,%lo(data)	# tmp150, tmp149,
	lw	a5,-20(s0)		# tmp151, i
	slli	a5,a5,2	#, tmp152, tmp151
	add	a5,a4,a5	# tmp152, tmp153, tmp150
	lw	a4,0(a5)		# _3, data[i_10]
# src/main.c:45:         if (data[i] < min_v)
	lui	a5,%hi(min_v)	# tmp154,
	lw	a5,%lo(min_v)(a5)		# min_v.3_4, min_v
# src/main.c:45:         if (data[i] < min_v)
	bge	a4,a5,.L17	#, _3, min_v.3_4,
# src/main.c:46:             min_v = data[i];
	lui	a5,%hi(data)	# tmp155,
	addi	a4,a5,%lo(data)	# tmp156, tmp155,
	lw	a5,-20(s0)		# tmp157, i
	slli	a5,a5,2	#, tmp158, tmp157
	add	a5,a4,a5	# tmp158, tmp159, tmp156
	lw	a4,0(a5)		# _5, data[i_10]
# src/main.c:46:             min_v = data[i];
	lui	a5,%hi(min_v)	# tmp160,
	sw	a4,%lo(min_v)(a5)	# _5, min_v
.L17:
# src/main.c:47:         if (data[i] > max_v)
	lui	a5,%hi(data)	# tmp161,
	addi	a4,a5,%lo(data)	# tmp162, tmp161,
	lw	a5,-20(s0)		# tmp163, i
	slli	a5,a5,2	#, tmp164, tmp163
	add	a5,a4,a5	# tmp164, tmp165, tmp162
	lw	a4,0(a5)		# _6, data[i_10]
# src/main.c:47:         if (data[i] > max_v)
	lui	a5,%hi(max_v)	# tmp166,
	lw	a5,%lo(max_v)(a5)		# max_v.4_7, max_v
# src/main.c:47:         if (data[i] > max_v)
	ble	a4,a5,.L18	#, _6, max_v.4_7,
# src/main.c:48:             max_v = data[i];
	lui	a5,%hi(data)	# tmp167,
	addi	a4,a5,%lo(data)	# tmp168, tmp167,
	lw	a5,-20(s0)		# tmp169, i
	slli	a5,a5,2	#, tmp170, tmp169
	add	a5,a4,a5	# tmp170, tmp171, tmp168
	lw	a4,0(a5)		# _8, data[i_10]
# src/main.c:48:             max_v = data[i];
	lui	a5,%hi(max_v)	# tmp172,
	sw	a4,%lo(max_v)(a5)	# _8, max_v
.L18:
# src/main.c:44:     for (int i = 1; i < N; i++) {
	lw	a5,-20(s0)		# tmp174, i
	addi	a5,a5,1	#, i_21, tmp174
	sw	a5,-20(s0)	# i_21, i
.L16:
# src/main.c:44:     for (int i = 1; i < N; i++) {
	lw	a4,-20(s0)		# tmp175, i
	li	a5,44		# tmp176,
	ble	a4,a5,.L19	#, tmp175, tmp176,
# src/main.c:50:     median = data[(N - 1) / 2];
	lui	a5,%hi(data)	# tmp177,
	addi	a5,a5,%lo(data)	# tmp178, tmp177,
	lw	a4,88(a5)		# _9, data[22]
# src/main.c:50:     median = data[(N - 1) / 2];
	lui	a5,%hi(median)	# tmp179,
	sw	a4,%lo(median)(a5)	# _9, median
# src/main.c:51: }
	nop	
	lw	ra,28(sp)		#,
	lw	s0,24(sp)		#,
	addi	sp,sp,32	#,,
	jr	ra		#
	.size	stats, .-stats
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16	#,,
	sw	ra,12(sp)	#,
	sw	s0,8(sp)	#,
	addi	s0,sp,16	#,,
# src/main.c:55:     generate();
	call	generate		#
# src/main.c:56:     sort(SID & 1);
	li	a5,1228800		# tmp138,
	addi	a5,a5,1221	#, SID.5_1, tmp138
	andi	a5,a5,1	#, _2, SID.5_1
	mv	a0,a5	#, _2
	call	sort		#
# src/main.c:57:     stats();
	call	stats		#
# src/main.c:58:     return 0;
	li	a5,0		# _7,
# src/main.c:59: }
	mv	a0,a5	#, <retval>
	lw	ra,12(sp)		#,
	lw	s0,8(sp)		#,
	addi	sp,sp,16	#,,
	jr	ra		#
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
