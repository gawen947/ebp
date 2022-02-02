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

global patch
extern open
extern errsys_r15

%include "common.inc"

section .rodata
  errCannotOpen  db "cannot open file for patching",0
  errCannotClose db "cannot close patched file",0
  fileTest       db "nonexistent.txt",0

section .text

; rdi = char *file_to_patch
; patch is read from STDIN
patch:
  push rbp
  mov rbp, rsp

  mov r15, errCannotOpen
  mov rax, SYS_open
  mov rsi, O_RDWR
  syscall
  call errsys_r15
  mov r12, rax                  ; r12 = file_to_patch_fd

.close:
  mov r15, errCannotClose
  mov rax, SYS_close
  mov rdi, r12
  syscall
  call errsys_r15

  mov rsp, rbp
  pop rbp
  ret
