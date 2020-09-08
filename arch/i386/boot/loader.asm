%include "asm-defs.asm.h"

org 0x9000

jmp CODE16_SEGMENT

;======================================================================================

[section .gdt]
;							    段基址		段界限							段属性
GDT_ENTRY		: Descriptor 	0,		   0,								0		            ;第0个描述符占位不使用
CODE32_DESC		: Descriptor    0,         CODE32_SEGMENT_LEN - 1,			DA_C + DA_32		;

GDT_LEN	equ $ - GDT_ENTRY					                            ;全局描述符表的长度
GDT_PTR:
                dw GDT_LEN - 1                                          ;GDT的界限,即最后一个Descriptor的地址
                dd 0                                                    ;
;======================================================================================

;定义选择子
Code32Selector  equ (0x001 << 3) + SA_TIG + SA_RPL0


[section .s16]
[bits 16]
CODE16_SEGMENT:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

	;初始化CODE32_DESC的段基址,.gdt中定义的是0,这里需要设置为正确的
	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, CODE32_SEGMENT
	mov word [CODE32_DESC + 2], ax	;ax 16bit part1
	shr eax, 16
	mov byte [CODE32_DESC + 4], al	;part2
	mov byte [CODE32_DESC + 7], ah	;part3

	;设置GDT_PTR,.gd中定义的是0,这里需要设置成正确的值
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, GDT_ENTRY
	mov dword [GDT_PTR + 2], eax

	;加载GDT
	lgdt [GDT_PTR]

	;关闭中断
	cli

	;打开A20
	in al, 0x92
	or al, 00000010b
	out 0x92, al

	;设置CR0寄存器 跳转到32位保护模式
	xor eax,eax
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax

	jmp dword Code32Selector : 0


[section .s32]
[bits 32]
CODE32_SEGMENT:
	xor eax, eax
	jmp CODE32_SEGMENT

CODE32_SEGMENT_LEN equ $ - CODE32_SEGMENT
