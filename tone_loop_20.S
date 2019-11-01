;;; tone_loop_20.S
;;;
;;;  Created: 6/5/2018 11:38:12 AM
;;;   Author: aprimatic
;;;
;;; Copyright 2018 APWizardry LLC
;;;
;;; Redistribution and use in source and binary forms, with or
;;; without modification, are permitted provided that the following
;;; conditions are met:
;;;
;;; 1. Redistributions of source code must retain the above
;;; copyright notice, this list of conditions and the following
;;; disclaimer.
;;;
;;; 2. Redistributions in binary form must reproduce the above
;;; copyright notice, this list of conditions and the following
;;; disclaimer in the documentation and/or other materials provided
;;; with the distribution.
;;;
;;; 3. Neither the name of the copyright holder nor the names of
;;; its contributors may be used to endorse or promote products
;;; derived from this software without specific prior written
;;; permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
;;; CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
;;; INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
;;; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
;;; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
;;; NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;;; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
;;; EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#define __SFR_OFFSET 0

#include <avr/io.h>

;;; Registers that aren't used with immediate modes
#define togD      r2
#define togB      r3
#define prev_togD r4
#define prev_togB r5
#define tcnt_l    r6
#define tcnt_h    r7
#define cnt       r8
#define tc        r9
#define c_zero    r10

;;; Registers that are used with immediate modes
#define tmp       r16
#define phase     r17
#define dly_lsb   r18
#define dly_msb   r19
#define min_val   r20
#define next_min  r21

;;; Pointers to arrays
#define p_cnt   0x100
#define p_tc    0x110
#define p_phase 0x120

;;; Pointer to 256-byte buffer
#define p_buf   0x200

.section .text
.global TIMER1_COMPA_vect

;;; Timer 1 Output Compare Interrupt Service Routine
;;; Preserves: Flags
;;; Modifies:
;;; r0, r1, tcnt_l(r8), tcnt_h(r9), tmp(r16),
;;; dly_lsb(r18), dly_msb(r19), XL(r30)
TIMER1_COMPA_vect:
;;; PUSH FLAGS
        IN      r0,0x3f                 ; 1
        PUSH    r0                      ; 2
;;; Read TCNT1
        LDS     tmp,TCNT1L              ; 2
;;; Compensate for 2-cycle instructions delaying interrupt for 1cc
        LDS     r0,OCR1AL               ; 2
;;; Subtract OCRA
        SUB     tmp,r0                  ; 1
;;; Subtract elapsed time to enter ISR
        SUBI    tmp,12                  ; 1
;;; If we were interrupted on a 2cc instruction, branch
        BRNE    dly0                    ; 2

;;; We were interrupted on a 1cc instruction
;;; Add one extra NOP to equalize the paths
        NOP                             ; 1-1
        NOP                             ; 1
                                        ;---
                                        ; 11/12
;;; This is the 20cc loop if dly_val == 0
dly0:   LD      r0,X+                   ; 2
        OUT     PIND,r0                 ; 1
        LD      r0,X+                   ; 2
        OUT     PINB,r0                 ; 1
        LD      dly_lsb,X+              ; 2
        INC     XL                      ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        TST     dly_lsb                 ; 1
        BREQ    dly0                    ; 2
                                        ;---
                                        ; 20
;;; This is the 40cc loop if dly_val == 1
        CPI     dly_lsb,1               ; 1-1
        BREQ    dly1                    ; 2
                                        ;---
                                        ; 2
;;; This is the 60cc loop if dly_val == 2
        CPI     dly_lsb,2               ; 1-1
        BREQ    dly2                    ; 2
                                        ;---
                                        ; 2
;;; Multiply delay by 20
        LDI     tmp,20                  ; 1-1
        MUL     dly_lsb,tmp             ; 2
        MOVW    dly_lsb,r0              ; 1
;;; Adjust delay
        SUBI    dly_lsb,30              ; 1
        SBC     dly_msb,c_zero          ; 1
;;; Get current timer value
        LDS     tcnt_l,TCNT1L           ; 2
        LDS     tcnt_h,TCNT1H           ; 2
;;; Add adjusted delay to current timer value
        ADD     tcnt_l,dly_lsb          ; 1
        ADC     tcnt_h,dly_msb          ; 1
;;; Set up next Output Compare
        STS     OCR1AH,tcnt_h           ; 2
        STS     OCR1AL,tcnt_l           ; 2

        POP     r0                      ; 2
        OUT     0x3f,r0                 ; 1
        RETI                            ; 4
                                        ;---
                                        ; 22
;;; These extra cycles keep dly1 and dly2 on 20cc boundaries
dly2:   NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
                                        ;---
                                        ; 18
;;; Fall through
dly1:   NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        NOP                             ; 1
        RJMP    dly0                    ; 2
                                        ;---
                                        ; 18
.global main
;;; Start of code
main: CLI
        CLR     c_zero
;;; Set PORTD to all outputs
        LDI     tmp,0xff
        OUT     DDRD,tmp
;;; Set PORTB to outputs on bottom 4 bits
        LDI     tmp,0x0f
        OUT     DDRB,tmp

;;; Initialize tc
;;; Initialize cnt
        LDI     tmp,119         ; C8
        STS     p_tc,tmp
        STS     p_cnt,tmp
        LDI     tmp,126         ; B7
        STS     p_tc+1,tmp
        STS     p_cnt+1,tmp
        LDI     tmp,134         ; A#7
        STS     p_tc+2,tmp
        STS     p_cnt+2,tmp
        LDI     tmp,142         ; A7
        STS     p_tc+3,tmp
        STS     p_cnt+3,tmp
        LDI     tmp,150         ; G#7
        STS     p_tc+4,tmp
        STS     p_cnt+4,tmp
        LDI     tmp,159         ; G7
        STS     p_tc+5,tmp
        STS     p_cnt+5,tmp
        LDI     tmp,169         ; F#7
        STS     p_tc+6,tmp
        STS     p_cnt+6,tmp
        LDI     tmp,179         ; F7
        STS     p_tc+7,tmp
        STS     p_cnt+7,tmp
        LDI     tmp,189         ; E7
        STS     p_tc+8,tmp
        STS     p_cnt+8,tmp
        LDI     tmp,201         ; D#7
        STS     p_tc+9,tmp
        STS     p_cnt+9,tmp
        LDI     tmp,213         ; D7
        STS     p_tc+10,tmp
        STS     p_cnt+10,tmp
        LDI     tmp,225         ; C#7
        STS     p_tc+11,tmp
        STS     p_cnt+11,tmp

;;; Initialize phases
        LDI     tmp,1
        STS     p_phase,tmp
        LDI     tmp,1
        STS     p_phase+1,tmp
        LDI     tmp,0
        STS     p_phase+2,tmp
        LDI     tmp,0
        STS     p_phase+3,tmp
        LDI     tmp,1
        STS     p_phase+4,tmp
        LDI     tmp,1
        STS     p_phase+5,tmp
        LDI     tmp,0
        STS     p_phase+6,tmp
        LDI     tmp,0
        STS     p_phase+7,tmp
        LDI     tmp,1
        STS     p_phase+8,tmp
        LDI     tmp,0
        STS     p_phase+9,tmp
        LDI     tmp,0
        STS     p_phase+10,tmp
        LDI     tmp,1
        STS     p_phase+11,tmp

;;; Set up rptr register
        LDI     XL,lo8(p_buf)
        LDI     XH,hi8(p_buf)

;;; Set up wptr regsiter
        LDI     ZL,lo8(p_buf)
        LDI     ZH,hi8(p_buf)

;;; Set up initial min_val
; uint16_t = min_val = 119;
        LDI     tmp,119
        MOV     min_val,tmp

;;; Start with no toggle
        CLR     prev_togB
        CLR     prev_togD

;;; Set up Timer1
;;; Inital TCNT = 0
        STS     TCNT1H,c_zero
        STS     TCNT1L,c_zero
;;; Initial OCR1A = 0x0800
;;; This allows the main loop to get a few dozen entries ahead of
;;; the ISR
        LDI     tmp,8
        STS     OCR1AH,tmp
        STS     OCR1AL,c_zero

;;; Normal Port Operation
;;; clkIO/1 (no prescaling)
        CLR     tmp
        STS     TCCR1A,tmp
        LDI     tmp,1<<CS10
        STS     TCCR1B,tmp

;;; Enable OCR1A Interrupt
        LDI     tmp,1<<OCIE1A
        STS     TIMSK1,tmp

;;; Enable Interrupts
        SEI

;;; Set up MSB of Y register (doesn't ever change)
        LDI     YH,hi8(p_cnt)

;;; Main loop
; while (1) {
;   next_min = 255;
lp0:    LDI     next_min,255
;   tog = 0;
        CLR     togD

        LDI     YL,11
;   for(int ii = 11; ii >= 0; ii--) {
;   cnt[ii] -= min_val;
lp1:    LDD     cnt,Y+(p_cnt&0xff)
        SUB     cnt,min_val
        CLC
;   if (cnt[ii] == 0) {
        BRNE    ar1

;     cnt[ii] = tc[ii];
        LDD     tc,Y+(p_tc&0xff)
        MOV     cnt,tc
        LDD     phase,Y+(p_phase&0xff)
;     tc[ii] += phase[ii];
        ADD     tc,phase
        STD     Y+(p_tc&0xff),tc
;     phase[ii] = -phase[ii];
        NEG     phase
        STD     Y+(p_phase&0xff),phase
;     tog |= (1<<ii);
        SEC

ar1:    ROL     togD
        ROL     togB
;   }
        STD     Y+(p_cnt&0xff),cnt

;   if (cnt[ii] < next_min) {
        CP      cnt,next_min
        BRSH    ar2

; next_min = cnt[ii];
        MOV     next_min,cnt
;   }
ar2:    SUBI    YL,1
        BRCC    lp1
; }
;;; Store toggle bits and delay into table
; buf[wptr++] = prev_tog & 0xff;
        ST      Z+,prev_togD
; buf[wptr++] = prev_tog >> 8;
        ST      Z+,prev_togB
; buf[wptr++] = min_val - 1;
        DEC     min_val
        ST      Z+,min_val
; wptr = (wptr + 1) & 0xff;
        INC     ZL

; min_val = next_min;
        MOV     min_val,next_min
; prev_tog = tog;
        MOVW    prev_togD,togD

; while (rptr == wptr)
;   ;
lp2:    CP      XL,ZL
        BREQ    lp2
;;; Go back to top
; }
        RJMP    lp0