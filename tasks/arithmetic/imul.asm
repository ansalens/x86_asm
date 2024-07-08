; Signed multiplication with simple numbers
section .text
	global asm_func

asm_func:
	; mov eax, 3
	mov al, 3
	mov edx, 5
	imul edx	; multiply EAX with EDX and store in EAX

	mov ecx, -15
	mov eax, -15
	imul eax, ecx	; imul can take 2 operands explicitly 

	imul eax, 15	; imul can also take numbers directly
	ret
