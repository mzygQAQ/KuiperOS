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
nop	                ; fill to 3 bytes

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

    mov ax, boot_msg
    mov bp, ax
    mov cx, 14
    call print_str

spin:
	hlt
	jmp spin

; read_sector
; @param ax    : logic sector nbr
; @param cx    : total sectors you want read
; @param es:bx : memeory address you want to write
; @description:
; BIOS软驱数据读取:
; AH=0x02
; AL=长度(扇区)
; CH=柱面号 CL=起始的扇区号
; DH=磁头号 DL=驱动器号
; ES:BX=读取到内存的地址
; int 0x13
read_sector:
    push bx
    push cx
    push dx
    push ax

    call reset_floppy

    push bx
    push cx

    mov bl, [BPB_SecPerTrk]
    div bl
    mov cl, ah
    add cl, 1
    mov ch, al
    shr ch, 1
    mov dh, al
    and dh, 1
    mov dl, [BS_DrvNum]

    pop ax  ; cx -> ax
    pop bx

    mov ah, 0x02
read:
    int 0x13
    jc read
    pop ax
    pop dx
    pop cx
    pop bx

    ret

; reset_floppy
; @param void
; @description
; BIOS软驱复位:
; AH=0x00
; DL=驱动器号(0表示A盘)
; int 0x13
reset_floppy:
    push ax
    push dx
    mov ah, 0x00
    mov dl, [BS_DrvNum]
    int 0x13
    pop dx
    pop ax
    ret

;  print_str implemented by BIOS interupt
;  @param es:bp : str start
;  @param cx    : str length
print_str:
    mov ax, 0x1301
    mov bx, 0x0007
    int 0x10
    ret

; compare the memory if equal or not equal
; @param ds:si : src
; @param es:di : dest
; @param cx    : len
; @return cx == 0?
memcmp:
    push ax
    push si
    push di
_compare:
    cmp cx, 0
    jz _equal
    mov al, [si]
    cmp al, byte [di]
    jz _go_on
    jmp _not_equal
_go_on:
    inc si
    inc di
    dec cx
    jmp _compare
_equal:
_not_equal:
    pop di
    pop si
    pop ax
    ret

boot_msg:
    db 0x0d, 0x0a
    db "Loading..."
    db 0x0d, 0x0a

times 510-($-$$) db 0x00

boot_flag:
    dw 0xaa55
