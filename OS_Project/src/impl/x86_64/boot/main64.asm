global long_mode_start ; long_mode_start label made global so the main.asm file can load it
extern kernel_main

section .text
bits 64 ; set bits to 64bit
long_mode_start:
    mov ax, 0 ; loads 0 into data segment registers so cpu instructions will function correctly
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax 

    ; print `OK`
	mov dword [0xb8000], 0x2f4b2f4f
    mov dword [0xb8004], 0x20202020
    mov dword [0xb8008], 0x20202020
    mov dword [0xb800a], 0x20202020
    mov dword [0xb800b], 0x20202020
    mov dword [0xb800c], 0x20202020
    mov dword [0xb800d], 0x20202020
    mov dword [0xb800e], 0x20202020
    mov dword [0xb800f], 0x20202020

        call kernel_main
    hlt 