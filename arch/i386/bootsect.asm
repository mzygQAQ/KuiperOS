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


start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax

	call print_msg
	
spin:
	hlt
	jmp spin

print_msg:
	mov ax, boot_msg
	mov bp, ax
	mov cx, 14
	mov ax, 0x1301
	mov bx, 0x000c
	mov dl, 0
	int 10h
	ret	

boot_msg:	db 0x0d, 0x0a
		db "Loading..."
		db 0x0d, 0x0a

times 510-($-$$) db 0x00

boot_flag:	dw 0xaa55
