;; Copyright (c) 2022, David Hauweele
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are met:
;;
;; 1. Redistributions of source code must retain the above copyright notice, this
;;    list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright notice,
;;    this list of conditions and the following disclaimer in the documentation
;;    and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

global errx_r15,err_r15,warn_r15,warnx_r15,errsys_r15
extern errx,err,warn,warnx,errno

section .text
; configure error message via register r15
_err_wrapper_r15:
  mov rdi, 1
  mov rsi, r15
  mov al, 0
  call r11
errx_r15:
  mov r11, errx
  jmp _err_wrapper_r15
err_r15:
  mov r11, err
  jmp _err_wrapper_r15
warn_r15:
  mov r11, warn
  jmp _err_wrapper_r15
warnx_r15:
  mov r11, warnx
  jmp _err_wrapper_r15

; check if a syscall returned correctly
errsys_r15:
  push 0                        ; we don't want to touch the carry
%ifdef FreeBSD
  jnc .exit
  mov qword [errno], rax
  jmp err_r15
%elifdef Linux
  cmp rax, 0
  jns .exit
  sub 0, rax
  mov qword [errno], rax
  jmp err_r15
%endif
.exit:
  add rsp, 8
  ret
