;段属性常量
DA_32   equ 0x4000

DA_DR   equ 0x90
DA_DRW  equ 0x92
DA_DRWA equ 0x93
DA_C    equ 0x98    ;代表该段是可执行代码段
DA_CR   equ 0x9a
DA_CC0  equ 0x9c
DA_CC0R equ 0x9e

;标识段类型的属性
DA_LDT           equ 0x82 ;代表该段是一个局部描述符表
DA_TASK_GATE     equ 0x85 ;代表任务门
DA_I386_TSS      equ 0x89 ;代表386人物状态段
DA_I386C_GATE    equ 0x8c ;代表386调用门
DA_I386I_GATE    equ 0x8e ;代表386中断门
DA_I386T_GATE    equ 0x8f ;代表386陷阱门

;段的特权级别
DA_DPL0 equ 0x00
DA_DPL1 equ 0x20
DA_DPL2 equ 0x40
DA_DPL3 equ 0x60

;描述符标的类型: 全局描述符表 + 局部描述符表
SA_TIG equ 0   ;0[0]00
SA_TIL equ 4   ;0[1]00

;请求的特权级别，用于选择子
SA_RPL0 equ 0  ;00[00]
SA_RPL1 equ 1  ;00[01]
SA_RPL2 equ 2  ;00[10]
SA_RPL3 equ 3  ;00[11]

;

;段描述符的宏定义
%macro Descriptor 3 						;%1段基址(32bit) %2段界限(20bit) %3段属性(12bit,设置时提供16bit,8-12填充0000)
	dw %2 & 0xffff							;段界限part1
	dw %1 & 0xffff							;段基址part1
	db (%1 >> 16) & 0xff					;段基址part2
	dw ((%2 >> 8) & 0xf00) | (%3 & 0xf0ff)	;其他属性part1+段界限part2+其他属性part2		
	db (%1 >> 24) & 0xff					;段基址part3 
%endmacro

;描述符的宏定义
%macro Gate 4
    dw (%2 & 0xffff)                        ;偏移地址1
	dw %1                                   ;选择子
	dw (%3 & 0x1f) | ((%4 << 8) & 0xff00)   ;属性
	dw ((%2 >> 16) & 0xffff)                ;偏移地址2
%endmacro






; NOTES:
; CallGate只支持从低特权级跳转到高特权级别，无法从高特权级别到低特权级别