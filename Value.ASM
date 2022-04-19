;тип приложения
     format PE console
;точка входа
     entry      start
;подключение макробиблиотек
     include 'WIN32A.INC'   ;'includes\win32ax.inc'
;секция данных
     section '.data' data readable writeable
X             dd        -10
Y             dd        3
result        dd        ?

stdin         dd    ?
stdout        dd    ?

buffer        db    15 dup(?);?,?,?
lenbuf        =     $-buffer
cntread       dd    ?

errorIn       dd    ?



;секция кода
      section   '.code' code    readable executable
 start:
 ;получеам дескрипторы потков ввода и вывода
       invoke   GetStdHandle,STD_INPUT_HANDLE
       mov      [stdin],eax
       invoke   GetStdHandle,STD_OUTPUT_HANDLE
       mov      [stdout],eax
;вычисления по формуле (x+1)*(y-1)+x%y-x/y
;ввод переменных
       stdcall  readInt,X,errorIn
       cmp      [errorIn],0
       jne      exit
       stdcall  readInt,Y,errorIn
       cmp      [errorIn],0
       jne      exit
       mov     eax,[X]
       inc     eax      ;x+1
       mov     ebx,[Y]
       dec     ebx       ;y-1
       imul    ebx       ;eax=(x+1)*(y-1)
       mov     [result],eax
       mov     eax,[X]
       cdq
       idiv     [Y];    eax = x/y  edx=x%y
       add      [result],edx
       sub      [result],eax

;вывод результата
       stdcall  writeInt,[result]

;выход с задержкой
exit:
       invoke   ReadConsole,[stdin],buffer,lenbuf,cntread,NULL
       invoke   ExitProcess,0
;подпрограмма вывода числа, в секции данных испльзуется строка
;   buffer
proc    writeInt        number
;пролог - сохраняем регистры
        push        eax
        push        edx
        push        ebp
        push        ecx
        push        esi
        push        ebx
;обработка числа
        mov     eax,[number]
        mov     esi, buffer
        xor     ebp,ebp
        xor     ecx,ecx
        mov     ebx,10
;знак
        cmp     eax,0
        jge     m1
        mov     [esi],byte '-'
        inc     esi
        inc     ebp
        neg     eax
m1:
;получение цифр
        cdq
        div     ebx
        push    edx
        inc     ecx
        cmp     eax,0
        jne     m1
;формирование строки
        add   ebp,ecx ;длина на вывод
m2:
        pop     edx
        add     dl,'0'
        mov     [esi],dl
        inc     esi
        loop    m2

        invoke  WriteConsole,[stdout],buffer,ebp,NULL,NULL


; эпилог - востанавливаем регистры
         pop        ebx
         pop        esi
         pop        ecx
         pop        ebp
         pop        edx
         pop        eax
        ret
        endp
;подпрограмма ввода цел числа с контролем введенных символов и переполнения
proc    readInt number, errorIn
        pusha
;ввод чилса
        invoke ReadConsole,[stdin],buffer,lenbuf,cntread,NULL
        mov    ecx,[cntread]
        sub    ecx,2
        xor    eax,eax
        xor    ebx,ebx
        xor    esi,esi
        mov    edi,10;[esi] [buffer+esi]
;анализ знака
        cmp     byte [buffer+esi],'-'
        jne     m3
        inc     esi
        dec     ecx
;обработка цифр
m3:
        mov     bl,[buffer+esi]
        sub     bl,'0'
        cmp     bl,0
        jl      err1
        cmp     bl,9
        jg      err1
        imul    edi
        jo      err2
        add     eax,ebx
        jc      err2
        jo      err2
        inc     esi
        loop    m3
        cmp     byte [buffer],'-'
        jne     m4
        neg     eax
m4:
        mov     edx,[number]
        mov     [edx],eax
        xor     ebx,ebx
        jmp     m5

err1:
        mov     ebx,1
        jmp     m5

err2:
        mov     ebx,2

m5:
        mov     edx,[errorIn]
        mov     [edx],ebx
        popa
        ret
        endp



;секция импорта
        section '.idata' import data readable writeable
        library kernel32,'KERNEL32.DLL'
        import  kernel32,\
                GetStdHandle,'GetStdHandle',\
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'