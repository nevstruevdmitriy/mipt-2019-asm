global run
global test
global my_printf

jmp run

section .data
retRef: resb 64                         ; Переменная хранящщая в себе ссылку возврата
section .text
;   Возвращается по ссылке на вершине стека. Никак не смог иначе
return:
    pop qword [retRef]
    jmp [retRef]

;   Функция, которая получает итый первый символ строки, и ложит его в rax
;   Параметры (из головы в хвост, Пушить в обратном!!!)
;   1   Строка
;   2   Индекс
section .data
getSymbol_RetRef:   resb    64          ; Возвратная ссылка
getSymbol_String:   resb    256         ; Строка
getSymbol_ind:      resb    8           ; Номер символа
section .text
getSymbol:
    pop qword [getSymbol_RetRef]
    pop qword [getSymbol_String]
    pop qword [getSymbol_ind]

    mov rax, qword [getSymbol_String]
    add rax, qword [getSymbol_ind]
    mov rax, qword [rax]
    and rax, 0xFF

    push qword [getSymbol_RetRef]
    ret


;   Функция, которая считает количество символов в строчке на вершине стека
;   Ответ помещается в rdx
section .data
strlen_RetRef:      resb    64          ; Возвратная ссылка
strlen_String:      resb    256         ; Строчка
section .text
strlen:
    pop qword [strlen_RetRef]
    pop qword [strlen_String]

    mov word [strlen_While_Ind], 0

    section .data
    strlen_While_Ind:       resb 8      ; Итератор
    section .text
    strlen_While:
        push qword [strlen_String]
        push qword [strlen_While_Ind]
        call getSymbol

        inc qword [strlen_While_Ind]
        
        cmp rax, 0x0A

        jne strlen_While

    mov rdx, qword [strlen_While_Ind]
    dec rdx
    push qword [strlen_RetRef]    
    ret

;   Функция, которая печатает символ
section .data
printSymbol_RetRef:     resb    64      ; Возвратная ссылка
printSymbol_Symbol:     resb    8       ; Символ печати
section .text
printSymbol:
    pop qword [printSymbol_RetRef]
    pop qword [printSymbol_Symbol]

    mov eax, 4                          ; Что-то напечатать
    mov rcx, $printSymbol_Symbol        ; Символ печати
    mov edx, 1                          ; количество
    int 0x80

    push qword [printSymbol_RetRef]
    ret

;   Функция, которая печатает цифру)))))
section .data
printDigit_RetRef:     resb     64      ; Возвратная ссылка
printDigit_Digit:      resb     64      ; Цифра
section .text
printDigit:
    pop qword [printDigit_RetRef]
    pop qword [printDigit_Digit]

    mov rcx, qword [printDigit_Digit]

    add rcx, strHex

    push qword [rcx]
    call printSymbol

    push qword [printDigit_RetRef]
    ret

;   Функция, которая печатает число в заданной системе исчесления в масив заданного размера
;   Параметры (из головы в хвост, Пушить в обратном!!!)
;   1   Система исчисление
;   2   Число
section .data
printNumber_RefRet      resb    64      ; Возвратная ссылка
printNumber_bais:       resb    64      ; Система исчисления
printNumber_Number:     resb    64      ; Число
section .text
printNumber:
    mov qword [printNumber__Ind], 1
    
    jmp printNumber_

    section .data
    printNumber__Ind:   resb    64      ; Количество циферок
    section .text
    printNumber_:
        inc qword [printNumber__Ind]

        pop qword [printNumber_RefRet]
        pop qword [printNumber_bais]
        pop qword [printNumber_Number]
        mov rax, qword [printNumber_Number]

        cmp rax, qword [printNumber_bais]

        push qword [printNumber_Number]
        jl printNumber_End
        pop qword [printNumber_Number]
    
        mov rdx, 0
        div qword [printNumber_bais]

        push rdx

        push rax
        push qword [printNumber_bais]
        push qword [printNumber_RefRet]

        jmp printNumber_
    
    printNumber_End:
        cmp qword [printNumber__Ind], 0
        dec qword [printNumber__Ind]

        push qword [printNumber_RefRet]
        je return
        pop qword [printNumber_RefRet]

        call printDigit
        jmp printNumber_End


;   Функция, которая переводит на новую строчку
section .data
section .text
printEnter:
    push 0x0A
    call printSymbol
    ret

;   Функция, которая печатает строку, лежащую на вершине стека
section .data
printS_RetRef:      resb    64          ; Возвратная ссылка
printS_String:      resb    256         ; Строчка
section .text
printS:
    pop qword [printS_RetRef]
    pop qword [printS_String]

    push qword [printS_String]
    call strlen

    mov eax, 4                          ; Что-то напечатать
    mov rcx, qword [printS_String]      ; Что печатать
    int 0x80

    push qword [printS_RetRef]
    ret

;   Функция, которая печатает число, лежащее на вершине стека
section .data
printD_RetRef:      resb    64          ; Возвратная ссылка
section .text
printD:
    pop qword [printD_RetRef]
    
    push 10
    push qword [printD_RetRef]
    jmp printNumber


;   Функция, которая печатает число, лежащее на вершине стека
section .data
printX_RetRef:      resb    64          ; Возвратная ссылка
section .text
printX:
    pop qword [printX_RetRef]
    
    push 16
    push qword [printX_RetRef]
    jmp printNumber

;   Функция, которая печатает число, лежащее на вершине стека
section .data
printB_RetRef:      resb    64          ; Возвратная ссылка
section .text
printB:
    pop qword [printB_RetRef]
    
    push 2
    push qword [printB_RetRef]
    jmp printNumber


;   Функция, которая печатает символ, лежащее на вершине стека
section .data
printC_RetRef:      resb    64          ; Возвратная ссылка
section .text
printC:
    pop qword [printC_RetRef]

    push qword [printC_RetRef]
    jmp printSymbol


;   Функция, которая печатает параметр, в зависимости от типа
;   Параметры (С головы стека в хвост, пушить в обратном!!!):
;   1   Тип
;   2   Параметр
section .data
printfType_RetRef:  resb    64          ; Возвратная ссылка
printfType_Type:    resb    64          ; Тип параметра на вершине стека
section .text
printfType:
    pop qword [printfType_RetRef]
    pop qword [printfType_Type]

    push qword [printfType_RetRef]

    cmp qword [printfType_Type], 's'    
    je printS

    cmp qword [printfType_Type], 'd'    
    je printD

    cmp qword [printfType_Type], 'x'    
    je printX

    cmp qword [printfType_Type], 'b'    
    je printB

    cmp qword [printfType_Type], 'c'
    je printC

    mov eax, 4                          ; Что-то напечатать
    mov rcx, printfType_Type            ; Что печатать
    mov edx, 1                          ; количество
    int 0x80
    
    ret

;   Функция, которая печатает форматированную строчку по правилам:
;   %s -> строчка
;   %d -> число
;   %% -> процент
;   На вершине стека лежит форматированная строка (типа "Dimka %s")
;   Далее идут параметры слева направо
;   Соотвественно пушить надо в обратном порядке!!!
section .data
printf_RetRef:  resb    64              ; Возвратная ссылка
printf_String:  resb    256             ; Строка
section .text
printf:
    pop qword [printf_RetRef]
    pop qword [printf_String]

    ; Я посмотрел на команду loop, для этой задачи оно не подходит((
    section .data
    printf_While_Ind    resb    64      ; Счётчик цикла
    printf_While_Symbol resb    64      ; Текущий символ
    printf_While_Type   resb    64      ; Тип параметра, на верхужке стека
    section .text
    mov qword [printf_While_Ind], 0
    printf_While:
        push qword [printf_While_Ind]
        push qword [printf_String]
        call getSymbol
        mov qword [printf_While_Symbol], rax

        inc qword [printf_While_Ind]

        cmp rax, '%'
        
        push rax                        ; Печатаем текущий смивол
        push printf_While_End           ; Вернёмся к концу цикла
        jne printSymbol

        pop rbx                         ; Надо отчистить стек, если не прошло
        pop rbx
        mov rbx, 0

        ; У нас случай % -> надо выпопить параметр, и обработать его)
        push qword [printf_While_Ind]
        push qword [printf_String]
        call getSymbol

        inc qword [printf_While_Ind]

        push rax
        call printfType

        printf_While_End:
            cmp qword [printf_While_Symbol], 0x0A
            jne printf_While

    push qword [printf_RetRef]
    ret

; Функция - обёртка над printf
section .data
run_RetRef:     resb        64          ; Возвратная ссылка
section .text
run:
    pop qword [run_RetRef]

    push r9
    push r8
    push rcx
    push rdx
    push rsi
    push rdi
    
    call printf

    push qword [run_RetRef]
    ret
; Функция, для тестирования 
test:
    mov rax, qword [strPrarmN]

    push rax
    push 10
    call printNumber                    ; Должно вывести 113113, выводит непонятно что

    call printEnter

    mov rax, 113113

    push rax
    push 10
    call printNumber                    ; Должно вывести 113113, что и выводит

    ret
section .data

strHex:
    db "0123456789ABCDEF"

strFormat: 
    db "hmm, %d dec = %b binary and %s, and I %s %x %d %% %c",0x0A

strParam1:
    db "it's not surprising", 0x0A

strParam3:
    db "love", 0x0A

strPrarm4:
    db "%b", 0x0A

strPrarmN:
    db 113113

