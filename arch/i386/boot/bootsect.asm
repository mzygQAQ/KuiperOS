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
nop	                ; jmp short _start 机器码占用2个字节，添加nop填充满3字节，使得符合Fat12FS格式

fat12_header:
    BS_OEMName     db "KuiperOS"
    BPB_BytsPerSec dw 512
    BPB_SecPerClus db 1
    BPB_RsvdSecCnt dw 1
    BPB_NumFATs    db 2
    BPB_RootEntCnt dw 224
    BPB_TotSec16   dw 2880
    BPB_Media      db 0xF0
    BPB_FATSz16    dw 9
    BPB_SecPerTrk  dw 18
    BPB_NumHeads   dw 2
    BPB_HiddSec    dd 0
    BPB_TotSec32   dd 0
    BS_DrvNum      db 0
    BS_Reserved1   db 0
    BS_BootSig     db 0x29
    BS_VolID       dd 0
    BS_VolLab      db "KuiperOSSSS"
    BS_FileSysType db "FAT12   "

_start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BaseOfStack ; The stack swims from high address to low address

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
	
	;从磁盘上读取loader程序并将CPU控制权进行转让



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
	int 10h
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

loader_not_found:

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

str_loader_not_found:
    db "ERROR: Loader not found"
    db 0x0d, 0x0a
len_loader_not_found equ ($ - str_loader_not_found)

times 510-($-$$) db 0x00

boot_flag:
    dw 0xaa55
