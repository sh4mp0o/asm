;тип приложения
     format PE console
;точка входа
     entry      start
;подключение макробиблиотек
     include 'WIN32A.INC'   ;'includes\win32ax.inc'
;секция данных
     section '.data' data readable writeable
CMsg          db      'Input string : '
lenCMsg       = $ - CMsg
CMsg2         db  'Reverse string : '
lenCMsg2      = $ - CMsg2
stdin         dd    ?
stdout        dd    ?
buffer        db    3 dup(?);?,?,?
lenbuf        =     $-buffer
cntread       dd    ?
n             =100
first         db    n dup(?)
second        db    n dup(?)

;секция кода
      section   '.code' code    readable executable
 start:
 ;получеам дескрипторы потков ввода и вывода
       invoke   GetStdHandle,STD_INPUT_HANDLE
       mov      [stdin],eax
       invoke   GetStdHandle,STD_OUTPUT_HANDLE
       mov      [stdout],eax
;вывод строки
       invoke   WriteConsole,[stdout],CMsg,lenCMsg,NULL,NULL
;ввод строки
       invoke   ReadConsole,[stdin],first,n,cntread,NULL
       sub      [cntread],2
;цикл обработки
       mov      ecx,[cntread]
       mov      esi,first
       mov      edi,second
       add      edi,[cntread]
       dec      edi
m1:    mov      al,[esi]
       mov      [edi],al
       inc      esi
       dec      edi
       loop     m1
       invoke   WriteConsole,[stdout],CMsg2,lenCMsg2,NULL,NULL
       invoke   WriteConsole,[stdout],second,[cntread],NULL,NULL
;выход с задержкой
       invoke   ReadConsole,[stdin],buffer,lenbuf,cntread,NULL
       invoke   ExitProcess,0


;секция импорта
        section '.idata' import data readable writeable
        library kernel32,'KERNEL32.DLL'
        import  kernel32,\
                GetStdHandle,'GetStdHandle',\
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'
