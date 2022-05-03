;сортировка выбором??????
;тип приложения
     format PE console
;точка входа
     entry      start
;подключение макробиблиотек
     include 'WIN32AX.INC'   ;'includes\win32ax.inc'
;секция данных
     section '.data' data readable writeable

Array        dd    ?      ;адрес выделенного блока памяти
n            dd    ?
hHeap        dd    ?      ;дескриптор кучи, с которой будем работать



buffer        db    16 dup(?);?,?,?
lenbuf        =     $-buffer
cntread       dd    ?
errorIn       dd    ?



;секция кода
      section   '.code' code    readable executable
start:
       cinvoke printf,"N = "
       cinvoke scanf,"%d",n
       cinvoke printf,"Input Array %c%c",10,13 ;под символы %c%c подставляем символы 10(\n), 13(\r)
       ;cmp     eax,1
       ;jne     erIn
       ;jmp     exit
;работа с кучей
;создание кучи
       invoke   HeapCreate,0,0,0
;проверка корректности создания
       cmp      eax,NULL
       jne      goodHeap
       invoke   printf,"Error create heap"
       jmp      exit
goodHeap:
       mov      [hHeap],eax ;дескриптор кучи
;выделяем память под массив
       mov      ecx,[n]
       shl      ecx,2
       invoke   HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,ecx ;хотим обнулить столько битов, сколько в ecx
;сохраняем адрес
       mov      [Array],eax ;Array - адрес нашего динамического массива

;ввод массива
      push      dword [n]
      push      dword [Array]
      call      readArray

;сортировка массива
      push      dword [n]
      push      dword [Array]
      call      SelectSort


;вывод массива
      push      dword [n]
      push      dword [Array]
      call      writeArray

;как создавали статический массив:
;Array dd     10 dup(?)
;MOV   esi,   Array - адрес массива
;MOV   [ESI], 0
;
;Array dd     ?
;mov   esi,   [Array]
;mov   [esi], 0

;освобождение памяти
       invoke   HeapFree,[hHeap],0,[Array]  ;[Array] - где хотим очистить память
       invoke   HeapDestroy,[hHeap]         ;Уничтожаем кучу

erIn:
       cinvoke printf,"Input error "
exit:
       cinvoke   getchar       ;после scanf не ждёт, т.к. в буффере ещё остаётся \n\r
       cinvoke   getchar
       invoke   ExitProcess,0


       proc  SelectSort
;пролог
        push    ebp
        mov     ebp,esp
        pusha

;stack:
; ebp           +0
;address ret    +4
;address Array  +8
;n              +12

;параметры
        mov     ecx,[ebp+12] ;n
        mov     esi,[ebp+8]  ;Array
        dec     ecx
sArr:
        mov     eax,[esi]
        mov     ebx,esi
        mov     edi,esi
        add     edi,4
        push    ecx
minArr:
        cmp     eax,[edi]
        jle     mArr
        mov     eax,[edi]
        mov     ebx,edi
mArr:
        add     edi,4
        loop    minArr
       ;xchg    eax,[esi]
       ;xchg    eax,[ebx]
        mov     edi,[esi]
        mov     [esi],eax
        mov     [ebx],edi
        add     esi,4
        pop     ecx

        loop    sArr


;эпилог
        popa
        pop    ebp
        ret    8  ;две переменные очищаем
        endp




       proc readArray
;пролог
        push    ebp
        mov     ebp,esp
        pusha

;stack:
; ebp           +0
;address ret    +4
;address Array  +8
;n              +12

;параметры
        mov     ecx,[ebp+12] ;n
        mov     esi,[ebp+8]  ;Array
rArr:
        push    ecx ;save ecx,esi, т.к. scanf их портит
        push    esi
        cinvoke scanf,"%d",esi
        pop     esi
        pop     ecx

        add     esi,4
        loop    rArr


;эпилог
        popa
        pop    ebp
        ret    8  ;две переменные очищаем
        endp


       proc  writeArray
;пролог
        push    ebp
        mov     ebp,esp
        pusha

;stack:
; ebp           +0
;address ret    +4
;address Array  +8
;n              +12

;параметры
        mov     ecx,[ebp+12] ;n
        mov     esi,[ebp+8]  ;Array
wArr:
        push    ecx ;save ecx,esi, т.к. scanf их портит
        push    esi
        cinvoke printf,"%d ",dword[esi]
        pop     esi
        pop     ecx

        add     esi,4
        loop    wArr


;эпилог
        popa
        pop    ebp
        ret    8  ;две переменные очищаем
        endp



;секция импорта
        section '.idata' import data readable writeable
        library kernel32,'KERNEL32.DLL',\
        msvcrt,'msvcrt.dll'

        import  kernel32,\
                ExitProcess,'ExitProcess',\
                GetProcessHeap,'GetProcessHeap',\
                HeapCreate,'HeapCreate',\
                HeapDestroy,'HeapDestroy',\
                HeapAlloc,'HeapAlloc',\
                HeapFree,'HeapFree'

        import  msvcrt,\
                printf,'printf',\
                scanf,'scanf',\
                getchar,'getchar'
