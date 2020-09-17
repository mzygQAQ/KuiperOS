%include "asm-defs.asm.h"

org 0x9000

jmp CODE16_SEGMENT

;===========================================================================================================================================
[section .gdt]
;							    段基址		段界限							段属性
GDT_ENTRY		: 
NOTUSE_DESC		: Descriptor 	0,		   0,								0		            ;第0个描述符占位不使用
CODE32_DESC		: Descriptor    0,         CODE32_SEGMENT_LEN - 1,			DA_C    + DA_32		;32位代码段描述符表
VIDEO_DESC		: Descriptor    0xb8000,   0x07fff,							DA_DRWA + DA_32		;Vga-Text模式显卡内存段描述符表
DATA32_DESC     : Descriptor    0,         DATA32_SEGMENT_LEN - 1,          DA_DR   + DA_32		;只读数据段描述符号
STACK32_DESC    : Descriptor    0,         STACK32_SEGMENT_LEN - 1,         DA_DRW  + DA_32		;可读可写
TASK1_LDT_DESC  : Descriptor    0,         TASK1_LDT_LEN - 1,               DA_LDT  + DA_32     ;对应的表又是一张局部描述符表
GDT_LEN	 equ $ - GDT_ENTRY					                                                    ;全局描述符表的长度
GDT_PTR:
    dw GDT_LEN - 1                                                                  ;GDT界限
    dd 0                                                                            ;16位代码段运行时需要设置为正确的长度
																					;直接定义GDT_ENTRY的话nasm会错链接问题
;==========================================================================================================================================

;定义选择子
Code32Selector    equ (0x001 << 3) + SA_TIG + SA_RPL0
VideoSelector	  equ (0x002 << 3) + SA_TIG + SA_RPL0
Data32Selector	  equ (0x003 << 3) + SA_TIG + SA_RPL0
Stack32Selector   equ (0x004 << 3) + SA_TIG + SA_RPL0
Task1LdtSelector  equ (0x005 << 3) + SA_TIG + SA_RPL0

[section .s16]
[bits 16]
CODE16_SEGMENT:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

	;初始化CODE32_DESC的段基址,.gdt中定义的是0,这里需要设置为正确的值
	mov esi,CODE32_SEGMENT
	mov edi,CODE32_DESC
	call init_descriptor_seg_base

	;初始化DATA32_DESC的段基址,.gdt中定义的是0,这里需要设置为正确的值
	mov esi,DATA32_SEGMENT
	mov edi,DATA32_DESC
	call init_descriptor_seg_base

	;初始化STACK32_DESC的段基址,.gdt中定义的是0,这里需要设置为正确的值
	mov esi, STACK32_SEGMENT
	mov edi, STACK32_DESC
	call init_descriptor_seg_base

	;task1相关
	mov esi, TASK1_LDT_SEGMENT
	mov edi, TASK1_LDT_DESC
	call init_descriptor_seg_base
	mov esi, TASK1_CODE_SEGMENT
	mov edi, TASK1_CODE_DESC
	call init_descriptor_seg_base
	mov esi, TASK1_DATA_SEGMENT
	mov edi, TASK1_DATA_DESC
	call init_descriptor_seg_base
	mov esi, TASK1_STACK_SEGMENT
	mov edi, TASK1_STACK_DESC
	call init_descriptor_seg_base

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
	xor eax, eax
	mov eax, cr0
	or eax, 0x01
	mov cr0, eax

	jmp dword Code32Selector : 0

;@param esi section label
;@param edi descriptor label
init_descriptor_seg_base:
	push eax

	xor eax, eax
	mov ax, cs
	shl eax, 4
	add eax, esi
	mov word [edi + 2], ax
	shr eax, 16
	mov byte [edi + 4], al
	mov byte [edi + 7], ah

	pop eax
	ret


[section .s32]
[bits 32]
CODE32_SEGMENT:

	mov ax, Stack32Selector
	mov ss, ax
	mov eax, STACK32_SEGMENT_LEN - 1
	mov esp, eax

	mov ax, VideoSelector
	mov gs, ax
	
	mov ax, Data32Selector
	mov ds, ax

	mov ebp, KUIPER_OS_OFFSET
	mov bx, 0x0c
	mov dx, 0x0100
	call write_string32

	mov ax, Task1LdtSelector
	lldt ax

	; 执行task1
	jmp dword Task1CodeSelector : 0

	jmp CODE32_SEGMENT

;保护模式的打印字符串，前提是gs已经放入了显存的选择子.
;@param ds:ebp straddr
;@param bx     print attr
;@param dx	   dh:row dl:col
write_string32:
	push eax
	push ecx
	push edx
	push edi
	push ebp
wrt32_print:
	mov cl, [ds:ebp]
	cmp cl, 0
	jz wrt32_done
	mov eax, 80
	mul dh
	add al, dl
	shl eax, 1	; x 2
	mov edi, eax
	mov ah, bl	; attr
	mov al, cl	; char to print
	mov word [gs:edi], ax
	inc ebp
	inc dl; 这里考虑换行
	jmp wrt32_print
wrt32_done:
	pop ebp
	pop edi
	pop edx
	pop ecx
	pop eax
	ret

CODE32_SEGMENT_LEN equ $ - CODE32_SEGMENT

;================================================================================
[section .dat]
[bits 32]
DATA32_SEGMENT:
	KUIPER_OS	db 'KuiperOS-PM', 0
    KUIPER_OS_OFFSET     equ KUIPER_OS - $$	;和实模式不同，这里是起始地址在段内的偏移量

DATA32_SEGMENT_LEN   equ $ - DATA32_SEGMENT
;================================================================================

;================================================================================
;这里定义4kb内存作为保护模式下的栈空间
[section .gs32]
[bits 32]
STACK32_SEGMENT:
	times 4096 db 0
STACK32_SEGMENT_LEN	  equ $ - STACK32_SEGMENT
;================================================================================


;================================================================================
[section .task1_ldt]
[bits 32]
TASK1_LDT_SEGMENT:
TASK1_LDT_ENTRY:
TASK1_CODE_DESC:    Descriptor          0,           TASK1_CODE_SEGMENT_LEN - 1,     DA_C   + DA_32
TASK1_DATA_DESC:    Descriptor          0,           TASK1_DATA_SEGMENT_LEN - 1,     DA_DR  + DA_32
TASK1_STACK_DESC:   Descriptor          0,           TASk1_STACK_BASE_ADDR,          DA_DRW + DA_32

TASK1_LDT_LEN        equ $ - TASK1_LDT_ENTRY

Task1CodeSelector    equ (0x0000 << 3) + SA_TIL + SA_RPL0
Task1DataSelector    equ (0x0001 << 3) + SA_TIL + SA_RPL0
Task1StackSelector   equ (0x0002 << 3) + SA_TIL + SA_RPL0
;================================================================================
[section .task1_data]
[bits 32]
TASK1_DATA_SEGMENT:
	TASK1_ECHO_STR	db "task1 was running on the cpu",0
	TASK1_ECHO_STR_OFFSET equ TASK1_ECHO_STR - $$

	TASK1_DATA_SEGMENT_LEN equ $ - TASK1_DATA_SEGMENT

[section .task1_code]
[bits 32]
TASK1_CODE_SEGMENT:
	mov ax, VideoSelector
	mov gs, ax

	mov ax, Task1DataSelector
	mov ds, ax

	mov ax, Task1StackSelector
	mov ss, ax
	mov eax, TASk1_STACK_BASE_ADDR
	mov esp, eax

	mov ebp, TASK1_ECHO_STR_OFFSET
	mov bx, 0x0c
	mov dx, 0x0200
	call task1_write_string32

task1_spin:
	jmp task1_spin


;保护模式的打印字符串，前提是gs已经放入了显存的选择子.
;@param ds:ebp straddr
;@param bx     print attr
;@param dx	   dh:row dl:col
task1_write_string32:
	push eax
	push ecx
	push edx
	push edi
	push ebp
task1_wrt32_print:
	mov cl, [ds:ebp]
	cmp cl, 0
	jz task1_wrt32_done
	mov eax, 80
	mul dh
	add al, dl
	shl eax, 1	; x 2
	mov edi, eax
	mov ah, bl	; attr
	mov al, cl	; char to print
	mov word [gs:edi], ax
	inc ebp
	inc dl; 这里考虑换行
	jmp task1_wrt32_print
task1_wrt32_done:
	pop ebp
	pop edi
	pop edx
	pop ecx
	pop eax
	ret

	TASK1_CODE_SEGMENT_LEN equ $ - TASK1_CODE_SEGMENT

[section .task1_stack]
[bits 32]
TASK1_STACK_SEGMENT:
	times 512 db 0
	TASK1_STACK_SEGMENT_LEN equ $ - TASK1_STACK_SEGMENT
	TASk1_STACK_BASE_ADDR	equ TASK1_STACK_SEGMENT_LEN - 1