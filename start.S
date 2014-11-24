/*
 * Copyright (C) 2014 Andrei Warkentin <andrey.warkentin@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#define SERIAL_BASE 0x70006000

.macro dputc,val
        mov     x0, \val
        bl      putc
.endm

.macro dputs,string
        ldr     x0, =\string
        bl      puts
.endm

.globl asm_start
/*
 * x0 contains the FDT blob PA, which we don't use
 */
asm_start:
        b       asm_real          // branch to kernel start, magic
        .long   0                 // reserved
        .quad   0x0               // Image load offset from start of RAM, unused
        .quad   0                 // reserved
        .quad   0                 // reserved
        .quad   0                 // reserved
        .quad   0                 // reserved
        .quad   0                 // reserved
        .byte   0x41              // Magic number, "ARM\x64"
        .byte   0x52
        .byte   0x4d
        .byte   0x64
        .word   0                 // reserved
asm_real:
        dputs   string1           // Hello!
        dputs   string2           // CurrentEL =
        mrs     x0, CurrentEL
        lsr     x0, x0, #2
        bl      puthex
        dputc   #'\n'
        dputc   #'\r'
        dputs   string3           // SCTLR_EL1 =
        mrs     x0, sctlr_el1
        bl      puthex
        dputc   #'\n'
        dputc   #'\r'

        ldr     x0, =stack_end
        mov     sp, x0
        bl      demo              // Draw to the fb

        dputs   string4           // Bye!
1:      b       1b

/*
 * Print a char in x0.
 *
 * Destroys x0, x1.
 */
putc:
        ldr     x1, =SERIAL_BASE
        strb    w0, [x1]
1:      ldrb    w0, [x1, #20]     // LSR
        tbz     w0, #5, 1b        // THRE == 0
        ret

/*
 * Print a string in x0.
 *
 * Destroys x0, x1, x2
 */
puts:
        ldr     x1, =SERIAL_BASE
1:      ldrb    w2, [x0]
        cbz     w2, 3f
        strb    w2, [x1]
2:      ldrb    w2, [x1, #20]     // LSR
        tbz     w2, #5, 2b        // THRE == 0
        add     x0, x0, #1
        b       1b
3:      ret

/*
 * Print a hex value in x0.
 *
 * Destroys x0, x1, x2, x3, x4.
 */
puthex:
        rev     x0, x0
        ldr     x4, =SERIAL_BASE
        mov     x1, #8
1:      subs    x1, x1, #1
        b.mi    6f
        and     x3, x0, #15
        lsr     x0, x0, #4
        and     x2, x0, #15
        lsr     x0, x0, #4
        cmp     x3, #10
        b.lt    2f
        add     x3, x3, #7
2:      add     x3, x3, #'0'
        cmp     x2, #10
        b.lt    3f
        add     x2, x2, #7
3:      add     x2, x2, #'0'
        strb    w2, [x4]
4:      ldrb    w2, [x4, #20] // LSR
        tbz     w2, #5, 4b    // THRE == 0
        strb    w3, [x4]
5:      ldrb    w3, [x4, #20] // LSR
        tbz     w3, #5, 5b    // THRE == 0
        b       1b
6:      ret

.section .data
.align 4
stack:
        .fill 512, 8, 0
stack_end:
string1: .asciz "Hello!\r\n"
string2: .asciz "CurrentEL = "
string3: .asciz "SCTLR_EL1 = "
string4: .asciz "Bye!\r\n"

