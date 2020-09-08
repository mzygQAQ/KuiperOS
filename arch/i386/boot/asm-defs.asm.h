;段属性常量
DA_32   equ 0x4000
DA_DR   equ 0x90
DA_DRW  equ 0x92
DA_DRWA equ 0x93
DA_C    equ 0x98
DA_CR   equ 0x9a
DA_CC0  equ 0x9c
DA_CC0R equ 0x9e

;选择子相关的属性
SA_RPL0 equ 0
SA_RPL1 equ 1
SA_RPL2 equ 2
SA_RPL3 equ 3

SA_TIG equ 0
SA_TIL equ 4

%macro Descriptor 3 						;%1段基址(32bit) %2段界限(20bit) %3段属性(12bit,设置时提供16bit,8-12填充0000)
	dw %2 & 0xffff							;段界限part1
	dw %1 & 0xffff							;段基址part1
	db (%1 >> 16) & 0xff					;段基址part2
	dw ((%2 >> 8) & 0xf00) | (%3 & 0xf0ff)	;其他属性part1+段界限part2+其他属性part2		
	db (%1 >> 24) & 0xff					;段基址part3 
%endmacro
