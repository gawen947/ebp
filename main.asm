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

global main
extern strcmp,printf,errx,err
extern errx_r15,err_r15,patch

section .rodata
  progName     db "Exe-Binary-Patcher (EBP)",0
  versionMajor dq 0
  versionMinor dq 1
  versionPatch dq 0
  versionFmt   db `%s v%ld.%ld.%ld\n`,0

  helpMsgFmt   incbin "help_msg_fmt.txt"
  helpMsgFmt0  db 0

  ; commands
  cmdHelp      db "help",0
  cmdVersion   db "version",0
  cmdPatch     db "patch",0
  cmdDiff      db "diff",0
  cmdsStr      dq cmdHelp, cmdVersion, cmdPatch, cmdDiff, 0
  cmdsFun      dq cmd_help, cmd_version, cmd_patch, cmd_diff, 0

  ; all error messages
  errInvalidNbArgs db "require at least one argument",0
  errPatchInvalidNbArgs db "patch EXE < PATCH",0
  errDiffInvalidNbArgs  db "diff OLD_EXE NEW_EXE",0
  errUnknownCmd    db "unknown command (for a list type 'help')",0

section .bss
  progExeName RESQ 1            ; argv[0]

section .text
show_version:
  sub rsp, 8                    ; stack align on 16-byte
  mov rdi, versionFmt
  mov rsi, progName
  mov rdx, [versionMajor]
  mov rcx, [versionMinor]
  mov r8,  [versionPatch]
  mov al, 0                     ; #vector args for varrargs
  call printf
  add rsp, 8
  ret

; cmd_* (rdi=argc, rsi=argv)
cmd_help:
  sub rsp, 8                    ; stack align on 16-byte
  mov rdi, helpMsgFmt
  mov rsi, [progExeName]
  mov al, 0
  call printf
  add rsp, 8
  ret

cmd_version:
  sub rsp, 8                    ; stack align on 16-byte
  call show_version
  add rsp, 8
  ret

cmd_patch:
  sub rsp, 8
  mov r15, errPatchInvalidNbArgs
  cmp rdi, 3
  jnz errx_r15

  mov rdi, [rsi+16]             ; rdi = argv[2]
  call patch

  add rsp, 8
  ret

cmd_diff:
  sub rsp, 8
  mov r15, errDiffInvalidNbArgs
  cmp rdi, 5
  jnz errx_r15

  mov rdi, [rsi+16]             ; rdi = argv[2]
  mov rsi, [rsi+24]             ; rsi = argv[3]
;  call diff

  add rsp, 8
  ret

main:
  push rbp
  mov  rbp, rsp

  ; command line:
  ;   rdi = argc
  ;   rsi = argv
  ;   [rsi]   = argv[0]
  ;   [rsi+8] = argv[1]
  ;   ...
  push rdi                      ; [rbp-8]   = rdi = argc
  push rsi                      ; [rbp-16]  = rsi = argv

  push r13                      ; save callee-saved
  push r14
  push r15
  sub rsp, 8                    ; stack align on 16-byte

  mov rsi, [rsi]                ; rsi = argv[0]
  mov [progExeName], rsi        ; progExeName = argv[0]

  cmp rdi, 2                    ; check that we have at least one argument
  jns .cont0

  mov r15, errInvalidNbArgs
  jmp errx_r15

.cont0:
  mov r13, cmdsStr-8            ; cmdsStr: char **s = { "cmd1", "cmd2", ...,  0 };
  mov r14, cmdsFun-8            ; cmdsFun: void **f = { cmd_fun1, cmd_fun2, ..., 0 };
  mov r15, errUnknownCmd

.loop0:
  add r13, 8
  add r14, 8

  mov rsi, [r13]

  test rsi, rsi                 ; last command?
  jz errx_r15

  mov rdi, [rbp-16]             ; rdi = argv
  mov rdi, [rdi+8]              ; rdi = argv[1]
  call strcmp
  test rax, rax
  jnz .loop0

  mov rdi, [rbp-8]
  mov rsi, [rbp-16]
  call [r14]

  mov rax, 0

.quit:
  add rsp, 8
  pop r15                       ; restore callee-saved
  pop r14
  pop r13

  mov rsp, rbp
  pop rbp
  ret
