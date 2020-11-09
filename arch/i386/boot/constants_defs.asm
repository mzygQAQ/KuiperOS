;这里的属性用于GDT/IDT
;这里的定义很乱,有时间重构下,Intel的设计很恶心,这里diss一下
;段属性常量
DA_32   equ 0x4000

DA_G_4K    equ 0x8000 ;G=1 时，段界限的粒度为4KB
DA_G_BYTE  equ 0x0000 ;G=0 时，段界限的粒度为字节 

DA_DR   equ 0x90
DA_DRW  equ 0x92
DA_DRWA equ 0x93
DA_C    equ 0x98    ;代表该段是可执行代码段
DA_CR   equ 0x9a
DA_CC0  equ 0x9c    ;一致性
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




;SA_XX的属性用于选择子.
;描述符标的类型: 全局描述符表 + 局部描述符表
SA_TIG equ 0   ;0[0]00
SA_TIL equ 4   ;0[1]00

;请求的特权级别，用于选择子
SA_RPL0 equ 0  ;00[00]
SA_RPL1 equ 1  ;00[01]
SA_RPL2 equ 2  ;00[10]
SA_RPL3 equ 3  ;00[11]

;分页属性
;P:[0,1) 存在(Present)标志用于指明表项对地址转换是否有效。P=1表示有效；P=0表示无效。
;        在页转换过程中，如果说涉及的页目录或页表的表项无效，则会导致一个异常。
;        如果P=0，那么除表示表项无效外，其余位可供程序自由使用,可以用来存放该内存在磁盘的位置用于页面置换
;|AVL|00|D|A|00|U/S|R/W|P|

PG_ATTR_P 	equ 0x1 ;P位属性值 页面在内存中
PG_ATTR_NP  equ 0x0 ;P位属性值 页面不在内存中,CPU访问这个地址会产生缺页中断

PG_ATTR_RWX equ 0x2	;R/W属性位 可读/可写/可执行
PG_ATTR_RX  equ 0x0 ;R/W属性位 可读/可执行

PG_ATTR_USS equ 0x0 ;U/S 属性位值 代表系统级
PG_ATTR_USU equ 0x4	;U/S 属性位值 代表用户级

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