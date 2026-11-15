	.file	"main_v2.c"
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
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	lw	a4,-20(s0)		# tmp137, x
	li	a5,1662976		# tmp139,
	addi	a5,a5,1549	#, tmp138, tmp139
	mul	a4,a4,a5	# _1, tmp137, tmp138
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	li	a5,1013903360		# tmp141,
	addi	a5,a5,863	#, tmp140, tmp141
	add	a5,a4,a5	# tmp140, _3, _1
# src/main_v2.c:11: }
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
# src/main_v2.c:15:     if (desc)
	lw	a5,-28(s0)		# tmp138, desc
	beq	a5,zero,.L4	#, tmp138,,
# src/main_v2.c:16:         return a < b;
	lw	a4,-20(s0)		# tmp140, a
	lw	a5,-24(s0)		# tmp141, b
	slt	a5,a4,a5	# tmp141, tmp142, tmp140
	andi	a5,a5,0xff	# _1, _1
	j	.L5		#
.L4:
# src/main_v2.c:17:     return a > b;
	lw	a4,-20(s0)		# tmp144, a
	lw	a5,-24(s0)		# tmp145, b
	sgt	a5,a4,a5	# tmp146, tmp144, tmp145
	andi	a5,a5,0xff	# _2, _2
.L5:
# src/main_v2.c:18: }
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
# src/main_v2.c:22:     unsigned int x = (unsigned int)SID;
	li	a5,1228800		# tmp138,
	addi	a5,a5,1221	#, SID.0_1, tmp138
# src/main_v2.c:22:     unsigned int x = (unsigned int)SID;
	sw	a5,-20(s0)	# SID.0_1, x
# src/main_v2.c:23:     for (int i = 0; i < N; i++) {
	sw	zero,-24(s0)	#, i
# src/main_v2.c:23:     for (int i = 0; i < N; i++) {
	j	.L7		#
.L8:
# src/main_v2.c:24:         x = lcg_next(x);
	lw	a0,-20(s0)		#, x
	call	lcg_next		#
	sw	a0,-20(s0)	#, x
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	lw	a5,-20(s0)		# tmp139, x
	srli	a4,a5,16	#, _2, tmp139
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	li	a5,274878464		# tmp142,
	addi	a5,a5,-557	#, tmp141, tmp142
	mulhu	a5,a4,a5	# tmp140, _2, tmp141
	srli	a5,a5,6	#, _3, tmp140
	li	a3,1000		# tmp144,
	mul	a5,a5,a3	# tmp143, _3, tmp144
	sub	a5,a4,a5	# _3, _2, tmp143
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	mv	a3,a5	# _4, _3
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	lui	a5,%hi(data)	# tmp145,
	addi	a4,a5,%lo(data)	# tmp146, tmp145,
	lw	a5,-24(s0)		# tmp147, i
	slli	a5,a5,2	#, tmp148, tmp147
	add	a5,a4,a5	# tmp148, tmp149, tmp146
	sw	a3,0(a5)	# _4, data[i_6]
# src/main_v2.c:23:     for (int i = 0; i < N; i++) {
	lw	a5,-24(s0)		# tmp151, i
	addi	a5,a5,1	#, i_14, tmp151
	sw	a5,-24(s0)	# i_14, i
.L7:
# src/main_v2.c:23:     for (int i = 0; i < N; i++) {
	lw	a4,-24(s0)		# tmp152, i
	li	a5,44		# tmp153,
	ble	a4,a5,.L8	#, tmp152, tmp153,
# src/main_v2.c:27: }
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
# src/main_v2.c:31:     int s = 0;
	sw	zero,-20(s0)	#, s
# src/main_v2.c:32:     for (int pass = 0; pass < N - 1; pass++)
	sw	zero,-24(s0)	#, pass
# src/main_v2.c:32:     for (int pass = 0; pass < N - 1; pass++)
	j	.L10		#
.L14:
# src/main_v2.c:33:         for (int j = 0; j < N - 1 - pass; j++)
	sw	zero,-28(s0)	#, j
# src/main_v2.c:33:         for (int j = 0; j < N - 1 - pass; j++)
	j	.L11		#
.L13:
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	lui	a5,%hi(data)	# tmp142,
	addi	a4,a5,%lo(data)	# tmp143, tmp142,
	lw	a5,-28(s0)		# tmp144, j
	slli	a5,a5,2	#, tmp145, tmp144
	add	a5,a4,a5	# tmp145, tmp146, tmp143
	lw	a3,0(a5)		# _1, data[j_13]
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	lw	a5,-28(s0)		# tmp147, j
	addi	a5,a5,1	#, _2, tmp147
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	lui	a4,%hi(data)	# tmp148,
	addi	a4,a4,%lo(data)	# tmp149, tmp148,
	slli	a5,a5,2	#, tmp150, _2
	add	a5,a4,a5	# tmp150, tmp151, tmp149
	lw	a5,0(a5)		# _3, data[_2]
	lw	a2,-36(s0)		#, desc
	mv	a1,a5	#, _3
	mv	a0,a3	#, _1
	call	out_of_order		#
	mv	a5,a0	# _4,
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	beq	a5,zero,.L12	#, _4,,
# src/main_v2.c:35:                 int t = data[j];
	lui	a5,%hi(data)	# tmp152,
	addi	a4,a5,%lo(data)	# tmp153, tmp152,
	lw	a5,-28(s0)		# tmp154, j
	slli	a5,a5,2	#, tmp155, tmp154
	add	a5,a4,a5	# tmp155, tmp156, tmp153
	lw	a5,0(a5)		# tmp157, data[j_13]
	sw	a5,-32(s0)	# tmp157, t
# src/main_v2.c:36:                 data[j] = data[j + 1];
	lw	a5,-28(s0)		# tmp158, j
	addi	a5,a5,1	#, _5, tmp158
# src/main_v2.c:36:                 data[j] = data[j + 1];
	lui	a4,%hi(data)	# tmp159,
	addi	a4,a4,%lo(data)	# tmp160, tmp159,
	slli	a5,a5,2	#, tmp161, _5
	add	a5,a4,a5	# tmp161, tmp162, tmp160
	lw	a4,0(a5)		# _6, data[_5]
# src/main_v2.c:36:                 data[j] = data[j + 1];
	lui	a5,%hi(data)	# tmp163,
	addi	a3,a5,%lo(data)	# tmp164, tmp163,
	lw	a5,-28(s0)		# tmp165, j
	slli	a5,a5,2	#, tmp166, tmp165
	add	a5,a3,a5	# tmp166, tmp167, tmp164
	sw	a4,0(a5)	# _6, data[j_13]
# src/main_v2.c:37:                 data[j + 1] = t;
	lw	a5,-28(s0)		# tmp168, j
	addi	a5,a5,1	#, _7, tmp168
# src/main_v2.c:37:                 data[j + 1] = t;
	lui	a4,%hi(data)	# tmp169,
	addi	a4,a4,%lo(data)	# tmp170, tmp169,
	slli	a5,a5,2	#, tmp171, _7
	add	a5,a4,a5	# tmp171, tmp172, tmp170
	lw	a4,-32(s0)		# tmp173, t
	sw	a4,0(a5)	# tmp173, data[_7]
# src/main_v2.c:38:                 s++;
	lw	a5,-20(s0)		# tmp175, s
	addi	a5,a5,1	#, s_28, tmp175
	sw	a5,-20(s0)	# s_28, s
.L12:
# src/main_v2.c:33:         for (int j = 0; j < N - 1 - pass; j++)
	lw	a5,-28(s0)		# tmp177, j
	addi	a5,a5,1	#, j_29, tmp177
	sw	a5,-28(s0)	# j_29, j
.L11:
# src/main_v2.c:33:         for (int j = 0; j < N - 1 - pass; j++)
	li	a4,44		# tmp178,
	lw	a5,-24(s0)		# tmp179, pass
	sub	a5,a4,a5	# _8, tmp178, tmp179
# src/main_v2.c:33:         for (int j = 0; j < N - 1 - pass; j++)
	lw	a4,-28(s0)		# tmp180, j
	blt	a4,a5,.L13	#, tmp180, _8,
# src/main_v2.c:32:     for (int pass = 0; pass < N - 1; pass++)
	lw	a5,-24(s0)		# tmp182, pass
	addi	a5,a5,1	#, pass_22, tmp182
	sw	a5,-24(s0)	# pass_22, pass
.L10:
# src/main_v2.c:32:     for (int pass = 0; pass < N - 1; pass++)
	lw	a4,-24(s0)		# tmp183, pass
	li	a5,43		# tmp184,
	ble	a4,a5,.L14	#, tmp183, tmp184,
# src/main_v2.c:40:     swaps = s;
	lui	a5,%hi(swaps)	# tmp185,
	lw	a4,-20(s0)		# tmp186, s
	sw	a4,%lo(swaps)(a5)	# tmp186, swaps
# src/main_v2.c:41: }
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
# src/main_v2.c:45:     min_v = max_v = data[0];
	lui	a5,%hi(data)	# tmp143,
	addi	a5,a5,%lo(data)	# tmp144, tmp143,
	lw	a4,0(a5)		# _1, data[0]
# src/main_v2.c:45:     min_v = max_v = data[0];
	lui	a5,%hi(max_v)	# tmp145,
	sw	a4,%lo(max_v)(a5)	# _1, max_v
# src/main_v2.c:45:     min_v = max_v = data[0];
	lui	a5,%hi(max_v)	# tmp146,
	lw	a4,%lo(max_v)(a5)		# max_v.1_2, max_v
	lui	a5,%hi(min_v)	# tmp147,
	sw	a4,%lo(min_v)(a5)	# max_v.1_2, min_v
# src/main_v2.c:46:     for (int i = 1; i < N; i++) {
	li	a5,1		# tmp148,
	sw	a5,-20(s0)	# tmp148, i
# src/main_v2.c:46:     for (int i = 1; i < N; i++) {
	j	.L16		#
.L19:
# src/main_v2.c:47:         if (data[i] < min_v)
	lui	a5,%hi(data)	# tmp149,
	addi	a4,a5,%lo(data)	# tmp150, tmp149,
	lw	a5,-20(s0)		# tmp151, i
	slli	a5,a5,2	#, tmp152, tmp151
	add	a5,a4,a5	# tmp152, tmp153, tmp150
	lw	a4,0(a5)		# _3, data[i_10]
# src/main_v2.c:47:         if (data[i] < min_v)
	lui	a5,%hi(min_v)	# tmp154,
	lw	a5,%lo(min_v)(a5)		# min_v.2_4, min_v
# src/main_v2.c:47:         if (data[i] < min_v)
	bge	a4,a5,.L17	#, _3, min_v.2_4,
# src/main_v2.c:48:             min_v = data[i];
	lui	a5,%hi(data)	# tmp155,
	addi	a4,a5,%lo(data)	# tmp156, tmp155,
	lw	a5,-20(s0)		# tmp157, i
	slli	a5,a5,2	#, tmp158, tmp157
	add	a5,a4,a5	# tmp158, tmp159, tmp156
	lw	a4,0(a5)		# _5, data[i_10]
# src/main_v2.c:48:             min_v = data[i];
	lui	a5,%hi(min_v)	# tmp160,
	sw	a4,%lo(min_v)(a5)	# _5, min_v
.L17:
# src/main_v2.c:49:         if (data[i] > max_v)
	lui	a5,%hi(data)	# tmp161,
	addi	a4,a5,%lo(data)	# tmp162, tmp161,
	lw	a5,-20(s0)		# tmp163, i
	slli	a5,a5,2	#, tmp164, tmp163
	add	a5,a4,a5	# tmp164, tmp165, tmp162
	lw	a4,0(a5)		# _6, data[i_10]
# src/main_v2.c:49:         if (data[i] > max_v)
	lui	a5,%hi(max_v)	# tmp166,
	lw	a5,%lo(max_v)(a5)		# max_v.3_7, max_v
# src/main_v2.c:49:         if (data[i] > max_v)
	ble	a4,a5,.L18	#, _6, max_v.3_7,
# src/main_v2.c:50:             max_v = data[i];
	lui	a5,%hi(data)	# tmp167,
	addi	a4,a5,%lo(data)	# tmp168, tmp167,
	lw	a5,-20(s0)		# tmp169, i
	slli	a5,a5,2	#, tmp170, tmp169
	add	a5,a4,a5	# tmp170, tmp171, tmp168
	lw	a4,0(a5)		# _8, data[i_10]
# src/main_v2.c:50:             max_v = data[i];
	lui	a5,%hi(max_v)	# tmp172,
	sw	a4,%lo(max_v)(a5)	# _8, max_v
.L18:
# src/main_v2.c:46:     for (int i = 1; i < N; i++) {
	lw	a5,-20(s0)		# tmp174, i
	addi	a5,a5,1	#, i_21, tmp174
	sw	a5,-20(s0)	# i_21, i
.L16:
# src/main_v2.c:46:     for (int i = 1; i < N; i++) {
	lw	a4,-20(s0)		# tmp175, i
	li	a5,44		# tmp176,
	ble	a4,a5,.L19	#, tmp175, tmp176,
# src/main_v2.c:52:     median = data[(N - 1) / 2];
	lui	a5,%hi(data)	# tmp177,
	addi	a5,a5,%lo(data)	# tmp178, tmp177,
	lw	a4,88(a5)		# _9, data[22]
# src/main_v2.c:52:     median = data[(N - 1) / 2];
	lui	a5,%hi(median)	# tmp179,
	sw	a4,%lo(median)(a5)	# _9, median
# src/main_v2.c:53: }
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
# src/main_v2.c:57:     generate();
	call	generate		#
# src/main_v2.c:58:     sort(SID & 1);
	li	a5,1228800		# tmp138,
	addi	a5,a5,1221	#, SID.4_1, tmp138
	andi	a5,a5,1	#, _2, SID.4_1
	mv	a0,a5	#, _2
	call	sort		#
# src/main_v2.c:59:     stats();
	call	stats		#
# src/main_v2.c:60:     return 0;
	li	a5,0		# _7,
# src/main_v2.c:61: }
	mv	a0,a5	#, <retval>
	lw	ra,12(sp)		#,
	lw	s0,8(sp)		#,
	addi	sp,sp,16	#,,
	jr	ra		#
	.size	main, .-main
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
