; Copyright (c) 2020 KuiperOS Developers

; MIT License

; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:

; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

org 0x7c00

BaseOfStack equ 0x7c00

jmp short _start
nop	                                    ; jmp short _start 机器码占用2个字节，添加nop填
                                        ; 充满3字节，使得符合Fat12FS格式

fat12_header:
    BS_OEMName     db "KuiperOS"        ; OEM字符串必须为8字节
    BPB_BytsPerSec dw 512               ; 每个扇区的字节数
    BPB_SecPerClus db 1                 ; 每簇占用的扇区数
    BPB_RsvdSecCnt dw 1                 ; 引导程序占用的扇区数
    BPB_NumFATs    db 2                 ; FAT表的记录数
    BPB_RootEntCnt dw 224               ; 最大根目录文件数
    BPB_TotSec16   dw 2880              ; 逻辑扇区总数量
    BPB_Media      db 0xF0              ; 媒体描述符(暂不知道用处)
    BPB_FATSz16    dw 9                 ; 每个FAT占用的扇区数量
    BPB_SecPerTrk  dw 18                ; 每个磁道的扇区数
    BPB_NumHeads   dw 2                 ; 磁头的数量
    BPB_HiddSec    dd 0                 ; 隐藏的扇区数
    BPB_TotSec32   dd 0                 ; ??
    BS_DrvNum      db 0                 ; 中断13的驱动器号
    BS_Reserved1   db 0                 ; 尚未使用
    BS_BootSig     db 0x29              ; 扩展引导标志
    BS_VolID       dd 0                 ; 卷序列号
    BS_VolLab      db "KuiperOSSSS"     ; 卷标必须为11字节
    BS_FileSysType db "FAT12   "        ; 文件系统的类型 必须8字节

_start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax

    ;设置栈空间,0x7c00-0x500之前大概有30kb的物理内存可以使用
    ;这个栈大小对于引导程序是十分足够的
    mov sp, BaseOfStack

    ;清除屏幕
    call clean_screen
	
    ;将光标设置到(0,0)处
    mov dx, 0
    call set_cursor

    ;输出引导信息
    mov ax, boot_msg
    mov bp, ax
    mov cx, BOOT_MSG_LEN
    call write_string

    ;

spin:
    hlt
    jmp spin

clean_screen:
    push ax
    push bx
    push cx
    push dx
    mov ah, 0x06    ;BIOS中断号
    mov al, 0
    mov cx, 0       ;(0,0)
    mov dx, 0x0c4f  ;(24,79)
    mov bh, 0x07    ;(黑底白字)
    int 0x10
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DL: x坐标
; DH: y坐标
set_cursor:
    push ax
    mov ah, 0x2
    int 0x10
    pop ax
    ret

; int 10h 0x13号中断
; AH - 0x13
; AL - 打印模式 1-光标移动 0-光标不移动
; BH - 视频页码
; BL - 如果AL寄存器为 1 或者 0，设置属性
; CX - 长度
; DH - 行坐标
; DL - 纵坐标
; ES:BP - 指针
write_string:
    push ax
    push bx
    mov ax, 0x1301
    mov bx, 0x0007
    int 0x10
    pop bx
    pop ax
    ret

; BIOS 0x13 00号软驱复位
; AH=0x00 DL=驱动器号
; NO_ARGUMENT
reset_floppy:
    push ax
    push dx
    mov ax, 0x00
    mov dl, [BS_DrvNum]    ; 0代表A盘
    int 0x13
    pop dx
    pop ax
    ret

;从磁盘读取数据到内
;入参1： AX:传入逻辑扇区号
;入参2： CX:需要读取的扇区数
;入参3： ES:BX:读取到的内存地址
;
;参考:
;0x13号中断 0x02号功能号
;AH=0x02
;AL=长度(扇区数)
;CH=柱面号
;CL=起始扇区号
;DH=磁头号
;DL=驱动器号
;ES:BP=读取到的内存地址
read_from_floppy:
    pusha
    call reset_floppy
    ; AX参数已就绪
    mov bl, [BPB_SecPerTrk]
    div bl
    ;IRQ
    mov ah, 0x02
    int 0x13
    popa
    ret


; =========================================
; for test case, can be delete after test
test_case:
str_src:
    db "str2"
str_dest:
    db "str2"
; =========================================

str_eq:
    db "equal"

str_noteq:
    db "notequal"

boot_msg:
    db "DEBUG: KuiperOS is booting..."
    db 0x0d, 0x0a
BOOT_MSG_LEN equ ($ - boot_msg)

no_loader_msg:
    db "ERROR: Cannot find the loader program!"
    db 0x0d, 0x0a
NO_LOADER_MSG_LEN equ ($ - no_loader_msg)

times 510-($-$$) db 0x00

boot_flag:
    dw 0xaa55
