	.data

	.global prompt
	.global mydata

start_prompt:	.string "Press sw1 or any key to continue:", 0
switch_counter:	.byte	0x00	; This is where you can store data. 
UART_counter:	.byte	0x00			; The .byte assembler directive stores a byte
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
	
ptr_to_start_prompt:		.word start_prompt
ptr_to_switch_counter:		.word switch_counter
ptr_to_UART_counter:		.word UART_counter

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
    PUSH {lr, r4-r11}          ; store regs
    ; Configure UART for interrupts
    
    MOV  r11, #0xc038
    MOVT r11, #0x4000          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    ORR r4, r4, #8             ; r4 |= #8
    
    MOV  r11, #0xc038
    MOVT r11, #0x4000          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    ; Set processor to allow for interrupts from UART0
    
    MOV  r11, #0xe100
    MOVT r11, #0xe000          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    ORR r4, r4, #16            ; r4 |= #16
    
    MOV  r11, #0xe100
    MOVT r11, #0xe000          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    POP {lr, r4-r11}           ; restore saved regs
    MOV pc, lr                 ; return to source call


gpio_interrupt_init:
    PUSH {lr, r4-r11}          ; store regs
    
    ; Set interrupt to be edge sensitive
    MOV  r11, #0x5404
    MOVT r11, #0x4002          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    AND r4, r4, #0xf7          ; r4 &= #0xf7
    
    MOV  r11, #0x5404
    MOVT r11, #0x4002          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    ; Set trigger for interrupt to be single edge
    MOV  r11, #0x5408
    MOVT r11, #0x4002          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    AND r4, r4, #0xf7          ; r4 &= #0xf7
    
    MOV  r11, #0x5408
    MOVT r11, #0x4002          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    ; Set the falling edge to be the trigger (triggers on press, not release)
    MOV  r11, #0x540c
    MOVT r11, #0x4002          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    AND r4, r4, #0xf7          ; r4 &= #0xf7
    
    MOV  r11, #0x540c
    MOVT r11, #0x4002          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    ; Enable the the interrupt
    MOV  r11, #0x5410
    MOVT r11, #0x4002          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    ORR r4, r4, #0x08          ; r4 |= #0x08
    
    MOV  r11, #0x5410
    MOVT r11, #0x4002          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    ; Set processor to allow interrupts from GPIO port F 
    MOV  r11, #0x5410
    MOVT r11, #0x4002          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    ORR r4, r4, #0x20000000    ; r4 |= #0x20000000
    
    MOV  r11, #0x5410
    MOVT r11, #0x4002          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    
    POP {lr, r4-r11}           ; restore saved regs
    MOV pc, lr                 ; return to source call             ; return to source call


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
    MOVT r11, #0x4002			; Address for interrupt
    LDRB r4, [r11]          	; Load interrup value
    ORR r4, r4, #8          	; Set bit 4 to 1
	STRB r4, [r11]				; Store back to clear interrupt

	; Increment the switch counter, load it, increment, store
    ldr r11, ptr_to_switch_counter	; Load the address
    LDRB r4, [r11]					; Read the value into r4
	ADD r4, r4, #1					; Increment the value
	STRB r4, [r11]					; Store the value
    
	; Display the graph
	BL display_graph

	; Restore registers
    POP {r4-r11}

	; Return to interrupted instruction
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
    PUSH {lr, r4-r11}          ; store regs
    
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
