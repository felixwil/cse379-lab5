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
    LDRB r0, [r11]             ; loading the data into r0
    
    ORR r0, r0, #8             ; r0 |= #8
    ldr r11, ptr_to_mydata     ; set bit 4
    LDRB r0, [r11]
    
    ADD r0, r0, #1             ; r0 += #1
    STRB r0, [r11]             ; increment counter
    POP {r4-r11}
    BX lr


