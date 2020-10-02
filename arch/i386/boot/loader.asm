%include "constants_defs.asm"

org 0x9000

jmp CODE16_SEGMENT

;===========================================================================================================================================
[section .gdt]
;							      段基址		段界限							段属性
GDT_ENTRY		  : 
NOTUSE_DESC		  : Descriptor 	  0,		 0,								    0		            ;第0个描述符占位不使用
CODE32_DESC		  : Descriptor    0,         CODE32_SEGMENT_LEN - 1,			DA_C    + DA_32 + DA_DPL0		;32位代码段描述符表
VIDEO_DESC		  : Descriptor    0xb8000,   0x07fff,							DA_DRWA + DA_32 + DA_DPL3		;Vga-Text模式显卡内存段描述符表
DATA32_DESC       : Descriptor    0,         DATA32_SEGMENT_LEN - 1,            DA_DR   + DA_32	+ DA_DPL0	;只读数据段描述符号
STACK32_DESC      : Descriptor    0,         STACK32_SEGMENT_LEN - 1,           DA_DRW  + DA_32	+ DA_DPL0	;可读可写
FUNCTION_DESC     : Descriptor    0,         FUNCTION_SEGMENT_LEN - 1,          DA_C    + DA_32 + DA_DPL0   ;可执行
TASK1_LDT_DESC    : Descriptor    0,         TASK1_LDT_SEGMENT_LEN -1,          DA_LDT  + DA_DPL0           ;局部描述服
TSS_DESC          : Descriptor    0,         TSS_SEGMENT_LEN - 1,               DA_I386_TSS + DA_DPL0       ;TSS     

;调用门描述符定义                选择子              偏移地址         参数数     属性
FUNC_CG_ADD_DESC  : Gate      FunctionSelector,   CG_ADD_OFFSET,   0,         DA_I386C_GATE + DA_DPL3         
FUNC_CG_SUB_DESC  : Gate      FunctionSelector,   CG_SUB_OFFSET,   0,         DA_I386C_GATE + DA_DPL3
FUNC_CG_WRT32_DESC: Gate      FunctionSelector,   write_string32_offset,0,    DA_I386C_GATE + DA_DPL3


GDT_LEN	 equ $ - GDT_ENTRY                                                          ;全局描述符表的长度
GDT_PTR:
    dw GDT_LEN - 1                                                                  ;GDT界限
    dd 0                                                                            ;16位代码段运行时需要设置为正确的长度
																					;直接定义GDT_ENTRY的话nasm会错链接问题
;==========================================================================================================================================

;定义选择子
Code32Selector        equ (0x001 << 3) + SA_TIG + SA_RPL0
VideoSelector	      equ (0x002 << 3) + SA_TIG + SA_RPL3
Data32Selector	      equ (0x003 << 3) + SA_TIG + SA_RPL0
Stack32Selector       equ (0x004 << 3) + SA_TIG + SA_RPL0
FunctionSelector      equ (0x005 << 3) + SA_TIG + SA_RPL0
Task1LdtSelector      equ (0x006 << 3) + SA_TIG + SA_RPL0
TssSelector           equ (0x007 << 3) + SA_TIG + SA_RPL0
FuncCgAddSelector     equ (0x008 << 3) + SA_TIG + SA_RPL3
FuncCgSubSelector     equ (0x009 << 3) + SA_TIG + SA_RPL3
FuncCgWrt32Selector   equ (0x00A << 3) + SA_TIG + SA_RPL3

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

	;初始化函数段
	mov esi, FUNCTION_SEGMENT
	mov edi, FUNCTION_DESC
	call init_descriptor_seg_base

	;初始化tss
	mov esi, TSS_SEGMENT
	mov edi, TSS_DESC
	call init_descriptor_seg_base

	;初始化task1的ldt描述符号
	mov esi, TASK1_LDT_SEGMENT;
	mov edi, TASK1_LDT_DESC
	call init_descriptor_seg_base

	;初始化task1的代码数据和堆栈
	mov esi, TASK1_CODE_SEGMENT;
	mov edi, TASK1_CODE_DESC
	call init_descriptor_seg_base
	mov esi, TASK1_DATA_SEGMENT;
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

[section .tss]
[bits 32]
TSS_SEGMENT:
	dd 0
	dd TopOfStack32		;ring0 esp
	dd Stack32Selector  ;ring0 ss
	dd 0                ;ring1 esp
	dd 0                ;ring1 ss
	dd 0                ;ring2 esp
	dd 0                ;ring2 ss
	times 4 * 18 dd 0
	dw 0
	dw $ - TSS_SEGMENT + 2
	db 0xff
TSS_SEGMENT_LEN equ $ - TSS_SEGMENT

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
	call FuncCgWrt32Selector : 0
	;call FunctionSelector : write_string32_offset

	;mov ax, 3
	;mov bx, 1
	; call FuncCgAddSelector : 0              ;利用调用门去调用函数
	;call FunctionSelector : CG_ADD_OFFSET     ;利用选择子+偏移地址调用函数

	;加载tss
	mov ax, TssSelector
	ltr ax

	;切换到task1执行, task1运行在用户态
	mov ax, Task1LdtSelector
	lldt ax
	;jmp Task1CodeSelector : 0 error: 特权级高的代码也不能直接跳转到低的代码段
	; 必须是使用retf,前提是先把目标段的堆栈信息和代码地址压入当前内核的堆栈中
	push Task1StackSelector
	push TASK1_STACK_SEGMENT_LEN - 1
	push Task1CodeSelector
	push 0
	retf

	jmp $
CODE32_SEGMENT_LEN equ $ - CODE32_SEGMENT
;================================================================================
[section .dat]
[bits 32]
DATA32_SEGMENT:
	KUIPER_OS	db 'KuiperOS entered x86_32 protect model', 0
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
TopOfStack32          equ STACK32_SEGMENT_LEN - 1
;================================================================================

;================================================================================
[section .func]
[bits 32]
FUNCTION_SEGMENT:

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
	retf
write_string32_offset  equ write_string32 - $$


;ax: a
;bx: b
;cx: a+b
AddFunc:
	mov cx, ax
	add cx, bx
	retf ;return far
CG_ADD_OFFSET    equ  AddFunc - $$

;ax: a
;bx: b
;cx: a-b
SubFunc:
	mov cx, ax
	sub cx, bx
	retf
CG_SUB_OFFSET   equ  SubFunc - $$

FUNCTION_SEGMENT_LEN  equ $ - FUNCTION_SEGMENT


;======================= Task1 start ===============================
[section .task1_ldt]
[bits 32]
TASK1_LDT_SEGMENT:
TASK1_CODE_DESC:    Descriptor 0, TASK1_CODE_SEGMENT_LEN-1,  DA_C   + DA_32 + DA_DPL3
TASK1_DATA_DESC:    Descriptor 0, TASK1_DATA_SEGMENT_LEN-1,  DA_DR  + DA_32 + DA_DPL3
TASK1_STACK_DESC:   Descriptor 0, TASK1_STACK_SEGMENT_LEN-1, DA_DRW + DA_32 + DA_DPL3
TASK1_LDT_SEGMENT_LEN  equ $ - TASK1_LDT_SEGMENT

; task1 ldt sectors
Task1CodeSelector  equ (0x000 << 3) + SA_TIL + SA_RPL3
Task1DataSelector  equ (0x001 << 3) + SA_TIL + SA_RPL3
Task1StackSelector equ (0x002 << 3) + SA_TIL + SA_RPL3

[section .task1_code]
[bits 32]
TASK1_CODE_SEGMENT:
	xor eax, eax
	xor ebx, ebx
	;模拟系统调用 ring3->ring0 需要切换到通过tss找到内核的栈
    mov ax, Task1DataSelector
    mov ds, ax
	mov ebp, taskNameOffset
	mov bx, 0x0c
	mov dx, 0x0200
	call FuncCgWrt32Selector : 0
	;call FunctionSelector : write_string32_offset  ;error: dpl=0, cpl=3
    
    ;TODO 从用户态程序返回内核态
    nop
	jmp $
TASK1_CODE_SEGMENT_LEN equ $ - TASK1_CODE_SEGMENT

[section .task1_data]
[bits 32]
TASK1_DATA_SEGMENT:

taskName: db 'kernel-daemon-task'
taskNameOffset equ taskName - $$

TASK1_DATA_SEGMENT_LEN equ $ - TASK1_DATA_SEGMENT

[section .task1_stack]
[bits 32]
TASK1_STACK_SEGMENT:
	times 512 db 0
TASK1_STACK_SEGMENT_LEN equ $ - TASK1_STACK_SEGMENT


;======================= Task1 end ===============================
