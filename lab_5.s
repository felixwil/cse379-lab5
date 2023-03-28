	.data

	.global prompt
	.global mydata

prompt:	.string "Your prompt with instructions is place here", 0
mydata:	.byte	0x20	; This is where you can store data. 
			; The .byte assembler directive stores a byte
			; (initialized to 0x20) at the label mydata.  
			; Halfwords & Words can be stored using the 
			; directives .half & .word 

	.text
	
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler		; This is needed for Lab #6
	.global simple_read_character
	.global output_character	; This is from your Lab #4 Library
	.global read_string		; This is from your Lab #4 Library
	.global output_string		; This is from your Lab #4 Library
	.global uart_init		; This is from your Lab #4 Library
	.global lab5
	
ptr_to_prompt:		.word prompt
ptr_to_mydata:		.word mydata

lab5:	; This is your main routine which is called from your C wrapper    
	PUSH {lr}   		; Store lr to stack
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_mydata

    bl uart_init
	bl uart_interrupt_init
	bl uart_interrupt_init

	; This is where you should implement a loop, waiting for the user to 
	; enter a q, indicating they want to end the program.
 
	POP {lr}		; Restore lr from the stack
	MOV pc, lr



uart_interrupt_init:
		
	; Configure UART for interrupts

	; Set processor to allow for interrupts from UART0

	MOV pc, lr


gpio_interrupt_init:
	; Initialize sw1 using code from previous labs

	; Set interrupt to be edge sensitive

	; Set trigger for interrupt to be single edge

	; Set the falling edge to be the trigger (triggers on press, not release)

	; Enable the the interrupt

	; Set processor to allow interrupts from GPIO port F 


	MOV pc, lr


UART0_Handler: 
	; NEEDS TO MAINTAIN REGISTERS R4-R11, R0-R3;R12;LR;PC DONT NEED PRESERVATION (BUT WOULDN'T HURT)
	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping 
	; them to & from the stack at the beginning & end of the handler

	; Save registers

	; Clear the interrupt

	; Load UART counter and then increment it

	; Display the graph

	; Store the UART counter

	; Restore registers

	BX lr       	; Return

Switch_Handler:
	; Save registers
    PUSH {r4-r11}

    ; Clear the interrupt, using load -> or -> store to not overwrite other data
    MOV  r11, #0x541c
    MOVT r11, #0x4002          ; setting the address
    LDRB r0, [r11]             ; loading the data into r0
    
    ORR r0, r0, #8             ; r0 |= #8
    ldr r11, ptr_to_mydata     ; set bit 4
    LDRB r0, [r11]
    
    ADD r0, r0, #1             ; r0 += #1
    STRB r0, [r11]             ; increment counter
    POP {r4-r11}
    BX lr

Timer_Handler:
	; NEEDS TO MAINTAIN REGISTERS R4-R11, R0-R3;R12;LR;PC DONT NEED PRESERVATION (BUT WOULDN'T HURT)
	; Your code for your Timer handler goes here.  It is not needed
	; for Lab #5, but will be used in Lab #6.  It is referenced here
	; because the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for 
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r11 by pushing then popping 
	; them to & from the stack at the beginning & end of the handler.

	BX lr       	; Return


simple_read_character:
    PUSH {lr, r4-r11}           ; store regs
    
    MOV  r11, #0xc000
    MOVT r11, #0x4000          ; setting the address
    LDRB r0, [r11]             ; loading the data into r0
    
    POP {lr, r4-r11}           ; restore saved regs
    MOV pc, lr                 ; return to source call

output_character: 
	
	MOV PC,LR      	; Return


read_string: 
	
	MOV PC,LR      	; Return


output_string: 
	
	MOV PC,LR      	; Return


display_graph:

	MOV PC,LR		; Return


	.end
