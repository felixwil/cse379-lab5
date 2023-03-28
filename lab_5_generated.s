simple_read_character:
    PUSH {lr, r4-r11}          ; store regs
    
    MOV  r11, #0xc000
    MOVT r11, #0x4000          ; setting the address
    LDRB r0, [r11]             ; loading the data into r0
    
    
    POP {lr, r4-r11}           ; restore saved regs
    MOV pc, lr                 ; return to source call


Switch_Handler:
    PUSH {r4-r11}

    ; clearing the interrupt
    MOV  r11, #0x541c
    MOVT r11, #0x4002          ; setting the address
    LDRB r4, [r11]             ; loading the data into r4
    
    ORR r4, r4, #8             ; r4 |= #8
    
    MOV  r11, #0x541c
    MOVT r11, #0x4002          ; setting the address
    STRB r4, [r11]             ; storing the data from r4
    
    ldr r11, ptr_to_mydata     ; set bit 4
    LDRB r4, [r11]
    ADD r4, r4, #1             ; r4 += #1
    
    STRB r4, [r11]             ; increment counter
    POP {r4-r11}
    BX lr


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
    MOV pc, lr                 ; return to source call


