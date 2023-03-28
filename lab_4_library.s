        .text
        .global uart_init
        .global gpio_btn_and_LED_init
        .global keypad_init ; Downloaded from the course website
        .global output_character
        .global read_character
        .global read_string
        .global output_string
        .global read_from_push_btns
        .global illuminate_LEDs
        .global illuminate_RGB_LED
        .global read_tiva_push_button
        .global read_from_keypad
        .global string2int
        .global int2string

gpio_btn_and_LED_init:
        PUSH {lr}
        ; Enable clock for port F and D
        MOV r1, #0xE608
        MOVT r1, #0x400F
        mov r0, #0x2B
        STRB r0, [r1]

        ; Setting the direction for port F, 0 button, 1 for RGB LEDs, for tiva board
        MOV r1, #0x5400
        MOVT r1, #0x4002
        mov r0, #0x0E
        STRB r0, [r1]

        ; Setting the direction for port B, 4 LEDs
        MOV r1, #0x5400
        MOVT r1, #0x4000
        mov r0, #0x0F
        STRB r0, [r1]

        ; Setting the direction for port D, 0 button, for keypad
        MOV r1, #0x7400
        MOVT r1, #0x4000
        mov r0, #0x00
        STRB r0, [r1]

        ; Set the pin to be digital for the tiva button and LED's
        MOV r1, #0x551C
        MOVT r1, #0x4002
        mov r0, #0x1F
        STRB r0, [r1]

        ; Set the pin to be digital for the base board LED's
        MOV r1, #0x551C
        MOVT r1, #0x4000
        mov r0, #0x0F
        STRB r0, [r1]

        ; Set the pin to be digital for the button on base board
        MOV r1, #0x751C
        MOVT r1, #0x4000
        mov r0, #0x0F
        STRB r0, [r1]

        ; Set the PUR for pin 4 for the push button
        MOV r1, #0x5510
        MOVT r1, #0x4002
        mov r0, #0x10
        STRB r0, [r1]

        ; Set the PUR for pin 4 for the push button
        MOV r1, #0x751C
        MOVT r1, #0x4000
        mov r0, #0x0F
        STRB r0, [r1]

        POP {lr}
        MOV pc, lr

read_from_keypad:
        PUSH {lr}

        BL keypad_init

        MOV r3, #1
keypadloop:
        ; select 1 pin in port D to scan
        MOV r1, #0x7000
        MOVT r1, #0x4000
        STRB r3, [r1, #0x3FC]

        ; read the pins from port A
        MOV r1, #0x4000
        MOVT r1, #0x4000
        LDRB r2, [r1, #0x3FC]

        ; if any of them are pressed, we return
        CMP r2, #0
        BGT exitkeypadloop
        ; otherwise keep going

        ; get ready to scan the next key
        LSL r3, r3, #1

        ; if we haven't scanned the last row yet, keep going
        CMP r3, #0
        BNE keypadloop

        ; if that was the last row, reset r3 back to scan
        ; all the rows again
        MOV r3, #1
        B keypadloop
exitkeypadloop:

        ; shift r2 back because there are two unused pins in the beginning
        LSR r2, r2, #2

;   r2 1 2 3 4
; r3
; 1    1 2 3
; 2    4 5 6
; 3    7 8 9
; 4      0

        ; if r3 is 8, key 0 was pressed and we can just return
        MOV r0, #0
        CMP r3, #8
        BEQ exitkeypadread

        ; basically just hardcoding mapping
        ; 1 2 4 8 to 1 2 3 4
        CMP r3, #4
        BNE r3not4
        MOV r3, #3
r3not4:
        CMP r3, #8
        BNE r3not8
        MOV r3, #4
r3not8:
        CMP r2, #4
        BNE r2not4
        MOV r2, #3
r2not4:
        CMP r2, #8
        BNE r2not8
        MOV r2, #4
r2not8:

        ; r0 = r2+(r3-1)*3
        SUB r3, r3, #1
        MOV r1, #3
        MUL r3, r3, r1
        ADD r0, r3, r2
        ; r0 now contains the number that was pressed

exitkeypadread:

        ; we needed to save r0 since the init overwrites it.
        PUSH {r0}
        BL gpio_btn_and_LED_init
        POP {r0}

        ; restore lr and return
        POP {lr}
        MOV pc, lr

read_from_push_btns:
        ; save registers we'll be using
        PUSH {lr,r4}

        ; setting regs we'll be using
        MOV r4, #0
        MOV r3, #0

        ; reading the values from port D
        MOV r1, #0x7000
        MOVT r1, #0x4000
        LDRB r0, [r1, #0x3FC]

        ; reversing the order of the bits we read from the GPIO
        AND r3, r0, #1
        LSL r3, r3, #3
        ORR r4, r4, r3

        AND r3, r0, #2
        LSL r3, r3, #1
        ORR r4, r4, r3

        AND r3, r0, #4
        LSR r3, r3, #3
        ORR r4, r4, r3

        AND r3, r0, #8
        LSR r3, r3, #1
        ORR r4, r4, r3
        
        ; move the result into return register
        MOV r0, r4

        ; restore regs and return
        POP {lr, r4}
        MOV pc, lr

read_tiva_push_button:
        PUSH {lr} ; save regs

        ; read the gpio for port B
        MOV r1, #0x5000
        MOVT r1, #0x4002
        LDRB r0, [r1, #0x3FC]

        ; invert the bits we just read because PUR is 1.
        MVN r0, r0
        ; make sure we're selecting only that bit and
        ; shift it to the beginning
        AND r0, r0, #0x10
        LSR r0, r0, #4

        ; restore regs and return
        POP {lr}
        MOV pc, lr

illuminate_LEDs:
        PUSH {lr} ; save regs

        ; make sure we're not writing extra bits to the gpio
        AND  r0, r0, #0xF

        ; write the bits for the LEDs to the gpio
        MOV r1, #0x5000
        MOVT r1, #0x4000
        STRB r0, [r1, #0x3FC]

        ; restore regs and return
        POP {lr}
        MOV pc, lr

illuminate_RGB_LED:
        PUSH {lr} ; save regs

        ; make sure we're not writing extra bits
        AND  r0, r0, #0x7

        ; shift left once because there's an extra bit
        ; at the beginning of the port
        LSL r0, r0, #0x1

        ; load the value from the port
        ; since it contains both inputs and outputs wee don't
        ; want to overwrite it
        MOV r1, #0x5000
        MOVT r1, #0x4002
        LDRB r2, [r1]

        ; clear the bits and set them
        BFC r2, #0x1, #0x3
        ORR r0, r0, r2
        ; write the result back to the port
        STRB r0, [r1, #0x3FC]

        POP {lr} ; restore regs and return
        MOV pc, lr

read_string:
        PUSH {lr}   ; Store register lr on stack

        MOV r1, r0 ; copying the pointer

readstringloop:
        BL read_character ; read a character
        BL output_character
        ; output the character immediately so the user can see what they're typing

        CMP r0, #0x0d ; exit if the user hits enter
        BEQ exitreadstring

	STRB r0, [r1]  ; write the character to the string buffer
	ADD r1, r1, #1 ; increment the point

        B readstringloop ; go back up

exitreadstring:

	; newline for formatting
	; carriage return has already been outputted above, so we don't need to do that.
        MOV r0, #0x0a
        BL output_character

        MOV r0, #0 ; add the null char
        STRB r0, [r1]

        POP {lr}
        mov pc, lr


output_string:
        PUSH {lr}   ; Store register lr on stack

        MOV r1, r0 ; copying the pointer

outputstringloop:
        LDRB r0, [r1] ; getting the char at the pointer (ptr[0])

        CMP r0, #0 ; if the char is null char, exit
        BEQ exitoutputstring

        BL output_character ; call the output char function to transmit r0 over uart

        ADD r1, r1, #1 ; increment char pointer

        B outputstringloop ; go back up

exitoutputstring:

        ; outputting '\r\n' to make formatting nicer
        MOV r0, #0x0d
        BL output_character
        MOV r0, #0x0a
        BL output_character

        POP {lr}
        mov pc, lr

read_character:
        PUSH {lr}   ; Store register lr on stack

        MOV r9, r7 ; save reg

checkread:
        MOV r7, #0xC018 ; r7 = checkaddr
        MOVT r7, #0x4000
        LDRB r3, [r7]     ; r3 = r7[0]
        AND r3, r3, #0x10 ; bit twiddling
        CMP r3, #0
        BGT checkread

        MOV r8, #0xC000
        MOVT r8, #0x4000
        LDRB r0, [r8] ; r0 = (r8 = 0x4000C000)[0]

        MOV r7, r9 ; restore saved reg

        POP {lr}
        mov pc, lr


output_character:
        PUSH {lr}   ; Store register lr on stack

        MOV r9, r7 ; saving reg

checkdisplay:
        MOV r7, #0xC018 ; r7 = checkaddr
        MOVT r7, #0x4000
        LDRB r3, [r7] 	  ; r3 = r7[0]
        AND r3, r3, #0x20 ; bit twiddling
        CMP r3, #0
        BGT checkdisplay

        MOV r8, #0xC000
        MOVT r8, #0x4000
        STRB r0, [r8] ; (r8 = 0x4000C000)[0] = r0

        MOV r7, r9 ; restore saved reg

        POP {lr}
        mov pc, lr


uart_init:
        PUSH {lr}  ; Store register lr on stack
	
        ; copied comments from lab3wrapper.c obviously

        /* Provide clock to UART0  */
	; (*((volatile uint32_t *)(0x400FE618))) = 1;
        MOV r0, #0xe618
        MOVT r0, #0x400f
        MOV r1, #1
        STRW r1, [r0]

	/* Enable clock to PortA  */
	; (*((volatile uint32_t *)(0x400FE608))) = 1;
        MOV r0, #0xe608
        MOVT r0, #0x400f
        MOV r1, #1
        STRW r1, [r0]

	/* Disable UART0 Control  */
	; (*((volatile uint32_t *)(0x4000C030))) = 0;
        MOV r0, #0xc030
        MOVT r0, #0x4000
        MOV r1, #0
        STRW r1, [r0]

	/* Set UART0_IBRD_R for 115,200 baud */
	; (*((volatile uint32_t *)(0x4000C024))) = 8;
	MOV r0, #0xc024
	MOVT r0, #0x4000
	MOV r1, #8
	STRW r1, [r0]

	/* Set UART0_FBRD_R for 115,200 baud */
	; (*((volatile uint32_t *)(0x4000C028))) = 44;
        MOV r0, #0xc028
        MOVT r0, #0x4000
        MOV r1, #44
        STRW r1, [r0]

	/* Use System Clock */
	; (*((volatile uint32_t *)(0x4000CFC8))) = 0;
        MOV r0, #0xcfc8
        MOVT r0, #0x4000
        MOV r1, #0
        STRW r1, [r0]

	/* Use 8-bit word length, 1 stop bit, no parity */
	; (*((volatile uint32_t *)(0x4000C02C))) = 0x60;
        MOV r0, #0xc02c
        MOVT r0, #0x4000
        MOV r1, #0x60
        STRW r1, [r0]

	/* Enable UART0 Control  */
	; (*((volatile uint32_t *)(0x4000C030))) = 0x301;
        MOV r0, #0xc030
        MOVT r0, #0x4000
        MOV r1, #0x0301
        STRW r1, [r0]

	/* Make PA0 and PA1 as Digital Ports  */
	; (*((volatile uint32_t *)(0x4000451C))) |= 0x03;
        MOV r0, #0x451c
        MOVT r0, #0x4000
        LDRB r1, [r0]
        ORR r1, r1, #0x03
        STRW r1, [r0]

	/* Change PA0,PA1 to Use an Alternate Function  */
	; (*((volatile uint32_t *)(0x40004420))) |= 0x03;
        MOV r0, #0x4420
        MOVT r0, #0x4000
        LDRB r1, [r0]
        ORR r1, r1, #0x03
        STRW r1, [r0]

	/* Configure PA0 and PA1 for UART  */
	; (*((volatile uint32_t *)(0x4000452C))) |= 0x11;
        MOV r0, #0x452c
        MOVT r0, #0x4000
        LDRB r1, [r0]
        ORR r1, r1, #0x11
        STRW r1, [r0]

        POP {lr}
        mov pc, lr

int2string:
        PUSH {lr}      ; Store register lr on stack

	; r0: int, r1: char*
        
        ; we know this is totally broken and not how this is
        ; supposed to be done but it's from lab3 and we're
        ; not going to change it without being able to test again
        ; before submitting lab4
        MOV r9, r4
        MOV r10, r5
        MOV r11, r6

        MOV r5, #10
        MOV r6, r0
        MOV r2, #0

charactercounterloop:

        ADD r2, r2, #1;  increment i
        SDIV r6, r6, r5; number //= 10 (floor divide by 10)

        CMP r6, #0;
        BGT charactercounterloop; return to the top

        ADD r1, r1, r2
        SUB r1, r1, #1
        STRB r6, [r1, #1]

nextplace:

        MOV r4, r0
        sdiv r2, r4, r5
        mul r3, r2, r5 ; r4 %= 10
        sub r4, r4, r3

        ; converting r4 from 0-9 to an ascii char '0'-'9'
	; 0x30 == '0' etc
        ADD r4, r4, #0x30
        STRB r4, [r1] ; storing into the buffer
        SUB r1, r1, #1 ; decrementing the pointer (because the digits are read in reverse)
        MOV r11, #10
        SDIV r0, r0, r11

        CMP r0, #0 ; same loop condition as above.  (r0 // 10) == 0 means we've exhausted all digits
        BNE nextplace  ; go back up

        MOV r4, r9
        MOV r5, r10
        MOV r6, r11

        POP {lr}
        mov pc, lr


string2int:
        PUSH {lr}   ; Store register lr on stack

        ;SUB r1, r1, #6

        MOV r2, #0

nextload:
        LDRB r1, [r0] ; load a character from the string at r0
        CMP r1, #0x0  ; if it's the null character, we're done.
        BEQ exitstring1intloop

        MOV r11, #1       ; placeholder for calculations
        MUL r2, r2, r11   ; r2 *= 10
        SUB r3, r1, #0x30 ; r2 = r1-'0'
        ADD r2, r2, r3    ; accumulator

        ADD r0, r0, #1

        B nextload
exitstring1intloop:

        MOV r0, r2 ; put r2 into return register

        POP {lr}
        mov pc, lr

        .end
