uart_interrupt_init:
    PSH {lr, r4-r11}           ; store regs
    
    MOV  r11, #0x5404
    MOVT r11, #0x4002          ; setting the address
    LDRB r0, [r11]             ; loading the data into r0
    
    AND r0, r0, #0x0000        ; r0 &= #0x0000
    ; sets port F to edge sensitive
    
    MOV  r11, #0x5404
    MOVT r11, #0x4002          ; setting the address
    STRB r0, [r11]             ; storing the data from r0
    
    POP {lr, r4-r11}           ; restore saved regs
    MOV pc, lr                 ; return to source call
