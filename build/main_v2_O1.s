	.file	"main_v2.c"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_zmmul1p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
# GNU C99 (xPack GNU RISC-V Embedded GCC x86_64) version 15.2.0 (riscv-none-elf)
#	compiled by GNU C version 15.2.0, GMP version 6.3.0, MPFR version 4.2.2, MPC version 1.3.1, isl version isl-0.27-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -mabi=ilp32 -misa-spec=20191213 -march=rv32im_zmmul -O1 -std=c99 -ffreestanding -fno-builtin
	.text
	.align	2
	.globl	lcg_next
	.type	lcg_next, @function
lcg_next:
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	li	a5,1662976		# tmp144,
	addi	a5,a5,1549	#, tmp139, tmp144
	mul	a0,a0,a5	# _1, x, tmp139
# src/main_v2.c:11: }
	li	a5,1013903360		# tmp145,
	addi	a5,a5,863	#, tmp141, tmp145
	add	a0,a0,a5	# tmp141,, _1
	ret	
	.size	lcg_next, .-lcg_next
	.align	2
	.globl	out_of_order
	.type	out_of_order, @function
out_of_order:
# src/main_v2.c:15:     if (desc)
	bne	a2,zero,.L5	#, desc,,
# src/main_v2.c:17:     return a > b;
	sgt	a0,a0,a1	# _2, a, b
# src/main_v2.c:18: }
	ret	
.L5:
# src/main_v2.c:16:         return a < b;
	slt	a0,a0,a1	# b, _2, a
	ret	
	.size	out_of_order, .-out_of_order
	.align	2
	.globl	generate
	.type	generate, @function
generate:
	lui	a2,%hi(.LANCHOR0)	# tmp144,
	addi	a2,a2,%lo(.LANCHOR0)	# ivtmp.18, tmp144,
	addi	t1,a2,180	#, _20, ivtmp.18
# src/main_v2.c:22:     unsigned int x = (unsigned int)SID;
	li	a4,1228800		# tmp158,
	addi	a4,a4,1221	#, x, tmp158
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	li	a6,1662976		# tmp159,
	addi	a6,a6,1549	#, tmp146, tmp159
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	li	a0,1013903360		# tmp160,
	addi	a0,a0,863	#, tmp148, tmp160
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	li	a1,274878464		# tmp161,
	addi	a1,a1,-557	#, tmp152, tmp161
	li	a7,1000		# tmp156,
.L7:
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	mul	a4,a4,a6	# _11, x, tmp146
# src/main_v2.c:10:     return 1664525u * x + 1013904223u;
	add	a4,a4,a0	# tmp148, x, _11
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	srli	a3,a4,16	#, _1, x
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	mulhu	a5,a3,a1	# tmp151, _1, tmp152
	srli	a5,a5,6	#, tmp154, tmp151
	mul	a5,a5,a7	# tmp155, tmp154, tmp156
	sub	a3,a3,a5	# _2, _1, tmp155
# src/main_v2.c:25:         data[i] = (int)((x >> 16) % 1000u);
	sw	a3,0(a2)	# _2, MEM[(int *)_8]
# src/main_v2.c:23:     for (int i = 0; i < N; i++) {
	addi	a2,a2,4	#, ivtmp.18, ivtmp.18
	bne	a2,t1,.L7	#, ivtmp.18, _20,
# src/main_v2.c:27: }
	ret	
	.size	generate, .-generate
	.align	2
	.globl	sort
	.type	sort, @function
sort:
	lui	a7,%hi(.LANCHOR0)	# tmp143,
	addi	a7,a7,%lo(.LANCHOR0)	# _4, tmp143,
	addi	a1,a7,176	#, ivtmp.33, _4
# src/main_v2.c:31:     int s = 0;
	li	a6,0		# s,
	j	.L10		#
.L18:
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	blt	a4,a3,.L12	#, _1, _3,
.L13:
# src/main_v2.c:33:         for (int j = 0; j < N - 1 - pass; j++)
	addi	a5,a5,4	#, ivtmp.25, ivtmp.25
	beq	a5,a1,.L17	#, ivtmp.25, ivtmp.33,
.L14:
	mv	a2,a5	# _39, ivtmp.25
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	lw	a4,0(a5)		# _1, MEM[(int *)_39]
	lw	a3,4(a5)		# _3, MEM[(int *)_39 + 4B]
# src/main_v2.c:15:     if (desc)
	bne	a0,zero,.L18	#, desc,,
# src/main_v2.c:34:             if (out_of_order(data[j], data[j + 1], desc)) {
	ble	a4,a3,.L13	#, _1, _3,
.L12:
# src/main_v2.c:36:                 data[j] = data[j + 1];
	sw	a3,0(a2)	# _3, MEM[(int *)_39]
# src/main_v2.c:37:                 data[j + 1] = t;
	sw	a4,4(a2)	# _1, MEM[(int *)_39 + 4B]
# src/main_v2.c:38:                 s++;
	addi	a6,a6,1	#, s, s
	j	.L13		#
.L17:
# src/main_v2.c:32:     for (int pass = 0; pass < N - 1; pass++)
	addi	a1,a1,-4	#, ivtmp.33, ivtmp.33
	beq	a7,a1,.L15	#, _4, ivtmp.33,
.L10:
# src/main_v2.c:30: {
	mv	a5,a7	# ivtmp.25, _4
	j	.L14		#
.L15:
# src/main_v2.c:40:     swaps = s;
	lui	a5,%hi(swaps)	# tmp144,
	sw	a6,%lo(swaps)(a5)	# s, swaps
# src/main_v2.c:41: }
	ret	
	.size	sort, .-sort
	.align	2
	.globl	stats
	.type	stats, @function
stats:
# src/main_v2.c:45:     min_v = max_v = data[0];
	lui	a1,%hi(.LANCHOR0)	# tmp145,
	addi	a1,a1,%lo(.LANCHOR0)	# tmp144, tmp145,
	lw	a3,0(a1)		# min_v_lsm.37, data[0]
# src/main_v2.c:45:     min_v = max_v = data[0];
	lui	a5,%hi(max_v)	# tmp146,
	sw	a3,%lo(max_v)(a5)	# min_v_lsm.37, max_v
# src/main_v2.c:45:     min_v = max_v = data[0];
	lui	a5,%hi(min_v)	# tmp147,
	sw	a3,%lo(min_v)(a5)	# min_v_lsm.37, min_v
	addi	a5,a1,4	#, ivtmp.47, tmp144
	addi	a1,a1,180	#, _4, tmp144
	mv	a2,a3	# max_v_lsm.39, min_v_lsm.37
	li	a7,0		# max_v_lsm_flag.40,
	li	a6,0		# min_v_lsm_flag.38,
# src/main_v2.c:47:         if (data[i] < min_v)
	li	a0,1		# min_v_lsm_flag.38,
	j	.L22		#
.L21:
# src/main_v2.c:46:     for (int i = 1; i < N; i++) {
	addi	a5,a5,4	#, ivtmp.47, ivtmp.47
	beq	a1,a5,.L26	#, _4, ivtmp.47,
.L22:
# src/main_v2.c:47:         if (data[i] < min_v)
	lw	a4,0(a5)		# _2, MEM[(int *)_30]
# src/main_v2.c:47:         if (data[i] < min_v)
	bge	a4,a3,.L20	#, _2, min_v_lsm.37,
# src/main_v2.c:48:             min_v = data[i];
	mv	a3,a4	# min_v_lsm.37, _2
# src/main_v2.c:47:         if (data[i] < min_v)
	mv	a6,a0	# min_v_lsm_flag.38, min_v_lsm_flag.38
.L20:
# src/main_v2.c:49:         if (data[i] > max_v)
	ble	a4,a2,.L21	#, _2, max_v_lsm.39,
# src/main_v2.c:50:             max_v = data[i];
	mv	a2,a4	# max_v_lsm.39, _2
# src/main_v2.c:49:         if (data[i] > max_v)
	mv	a7,a0	# max_v_lsm_flag.40, min_v_lsm_flag.38
	j	.L21		#
.L26:
	beq	a7,zero,.L23	#, max_v_lsm_flag.40,,
	lui	a5,%hi(max_v)	# tmp150,
	sw	a2,%lo(max_v)(a5)	# max_v_lsm.39, max_v
.L23:
	beq	a6,zero,.L24	#, min_v_lsm_flag.38,,
	lui	a5,%hi(min_v)	# tmp151,
	sw	a3,%lo(min_v)(a5)	# min_v_lsm.37, min_v
.L24:
# src/main_v2.c:52:     median = data[(N - 1) / 2];
	lui	a5,%hi(.LANCHOR0+88)	# tmp153,
# src/main_v2.c:52:     median = data[(N - 1) / 2];
	lw	a4,%lo(.LANCHOR0+88)(a5)		# data[22], data[22]
	lui	a5,%hi(median)	# tmp152,
	sw	a4,%lo(median)(a5)	# data[22], median
# src/main_v2.c:53: }
	ret	
	.size	stats, .-stats
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16	#,,
	sw	ra,12(sp)	#,
# src/main_v2.c:57:     generate();
	call	generate		#
# src/main_v2.c:58:     sort(SID & 1);
	li	a0,1		#,
	call	sort		#
# src/main_v2.c:59:     stats();
	call	stats		#
# src/main_v2.c:61: }
	li	a0,0		#,
	lw	ra,12(sp)		#,
	addi	sp,sp,16	#,,
	jr	ra		#
	.size	main, .-main
	.globl	swaps
	.globl	max_v
	.globl	min_v
	.globl	median
	.globl	data
	.globl	SID
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	data, @object
	.size	data, 180
data:
	.zero	180
	.section	.sbss,"aw",@nobits
	.align	2
	.type	swaps, @object
	.size	swaps, 4
swaps:
	.zero	4
	.type	max_v, @object
	.size	max_v, 4
max_v:
	.zero	4
	.type	min_v, @object
	.size	min_v, 4
min_v:
	.zero	4
	.type	median, @object
	.size	median, 4
median:
	.zero	4
	.section	.srodata,"a"
	.align	2
	.type	SID, @object
	.size	SID, 4
SID:
	.word	1230021
	.ident	"GCC: (xPack GNU RISC-V Embedded GCC x86_64) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
