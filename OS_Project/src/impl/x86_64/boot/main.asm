global start
extern long_mode_start ; external so it can be reached by main64.asm

section .text
bits 32
start:
	mov esp, stack_top 

	call check_multiboot ; check if loaded by multiboot bootloader
	call check_cpuid ; cpu instruction that provides information
	call check_long_mode ; checks if 64bit can be enabled

	; paging allows mapping of virtual addresses to physical addresses using page tables. single page is 4 kilobytes 
	call setup_page_tables
	call enable_paging

	lgdt [gdt64.pointer]; load global descriptor table, given the pointer set up 
	jmp gdt64.code_segment:long_mode_start ; load code segment into code selector. defined by code segment offset

	; print `OK`
	; mov dword [0xb8000], 0x2f4b2f4f
	hlt

check_multiboot:
	call print_eax_hex
	cmp eax, 0x36d76289 ; eax register stores this magic value
	jne .no_multiboot
	ret
.no_multiboot:
	mov al, "M" ; moves "m" for multiboot to al register
	jmp error ; jumps to error if not booted from multiboot

print_eax_hex:
    pusha                    ; Save all registers
    mov ecx, 8               ; We will print 8 hex digits (32 bits / 4 bits per hex digit)
    mov edi, 0xb8000         ; Start address for VGA text memory
    mov ebx, eax             ; Copy eax into ebx for manipulation

.print_loop:
    ; Shift the highest nibble into the lowest 4 bits
    mov eax, ebx             ; Copy original number to eax
    shl eax, 28              ; Move highest nibble to the lowest position
    shr eax, 28              ; Remove all but the lowest 4 bits

    ; Convert the nibble to a hex character
    add al, '0'              ; Convert to ASCII by adding '0'
    cmp al, '9'              ; Check if it's in the range 0–9
    jbe .write_char          ; If so, skip adjustment
    add al, 7                ; Adjust to turn it into A–F

.write_char:
    mov [edi], ax            ; Write the character (ASCII code in AL, color in AH)
    add edi, 2               ; Move to the next character slot in VGA memory

    ; Prepare for next nibble
    shl ebx, 4               ; Shift left by 4 bits to bring the next nibble up
    loop .print_loop         ; Repeat for the next hex digit

    popa                     ; Restore all registers
    ret

check_cpuid: ; tries to flip flag of cpuid register to 1
	pushfd
	pop eax
	mov ecx, eax
	xor eax, 1 << 21
	push eax
	popfd
	pushfd
	pop eax
	push ecx
	popfd
	cmp eax, ecx ; all this is to change the bit manually to 1, then check if cpu changed it back to 0 or not
	je .no_cpuid
	ret
.no_cpuid:
	mov al, "C"
	jmp error

check_long_mode:
	mov eax, 0x80000000
	cpuid ; takes eax register as implicit argument
	cmp eax, 0x80000001 ; value will be increased if supported, checks equality
	jb .no_long_mode

	mov eax, 0x80000001
	cpuid ; now will store to edx register
	test edx, 1 << 29
	jz .no_long_mode

	ret

.no_long_mode:
	mov al, "L" ; moves "L" to al register as error for no long no_long_mode
	jmp error

setup_page_tables:
	mov eax, page_table_l3
	; pages are lined at 4096 bytes > log base 2 of 4096 tells us the first 12 bits of every entry is always 0, cpu uses them to store flags instead
	or eax, 0b11 ; present, writable
	mov [page_table_l4], eax

	mov eax, page_table_l2
	or eax, 0b11 ; present, writable
	mov [page_table_l3], eax
	; l2 will be able to address physical memory and have page tables of 2mb  the remaining 9 bits will be an offset into physical memory

	mov ecx, 0 ; counter
.loop:
	mov eax, 0x200000 ; 2MiB
	mul ecx
	or eax, 0b10000011 ; present, writable, huge page. fist 1 after b is huge page flag
	mov [page_table_l2 + ecx * 8], eax
		

	inc ecx ; increment counter
	cmp ecx, 512 ; checks if whole table is mapped (512 entries)
	jne .loop ; if not, continue

	ret

enable_paging:
	; pass page table location to cpu 
	mov eax, page_table_l4
	mov cr3, eax

	; enable PAE
	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	; enable long mode
	mov ecx, 0xC0000080 ; mov magic value to ecx register
	rdmsr ; use read model specific register
	or eax, 1 << 8 ; enables flag at bit 8 
	wrmsr

	; enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	ret


error:
	mov dword [0xb8000], 0x4f524f45 ; moves "e" to video memory address 0xb8000, 1 byte
	mov dword [0xb8004], 0x4f3a4f52
	mov dword [0xb8008], 0x4f204f20
	mov byte  [0xb800a], al ; loads the byte stored in the al register "M"
	hlt

section .bss ; reserved for when bootloader loads kernel. ESP register used to find current address of stack frame (stack pointer)
align 4096
page_table_l4:
	resb 4096
page_table_l3:
	resb 4096
page_table_l2:
	resb 4096

stack_bottom:
	resb 4096 * 4 ; reserves 16k of memory for stack
stack_top:

section .rodata ; read only data section
gdt64: ; defines 64bit descriptor table
	dq 0 ; zero entry
.code_segment: equ $ - gdt64 ; $ is current address, offset inside descriptor table. current address - start of table
	dq (1 << 43) | (1 <<44) | (1 << 47) | (1 << 53) ; code segment. enables executable flag, set desc flag to 1 for code and data segment, present flag, enable 64 bit flag
.pointer: ; to global descriptor table
	dw $ - gdt64 - 1 ; length of the table - 1
	dq gdt64 
