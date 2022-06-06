;тип приложения
     format PE console
;точка входа
     entry      start
;подключение макробиблиотек
     include 'includes\win32ax.inc'
;секция данных
     section '.data' data readable writeable
CMsg          db      'Input string : '
lenCMsg       = $ - CMsg
CMsg2         db  'String correct'
lenCMsg2      = $ - CMsg2
CMsg3         db  'String is not correct'
lenCMsg3      = $ - CMsg3
stdin         dd    ?
stdout        dd    ?
buffer        db    3 dup(?);?,?,?
lenbuf        =     $-buffer
cntread       dd    ?
n             =100
first         db    n dup(?)

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
       mov      esi,first
       mov      ecx,[cntread]
       mov      byte[esi+ecx],'$'
SA:
	   inc 		esi
       cmp      byte[esi],'a'
       je       SA
       cmp      byte[esi],'b'
       je 		BC
       jmp      Err1
BC:
       inc      esi
       cmp      byte[esi],'a'
       je       BC
       cmp      byte[esi],'b'
       je 		BC
       cmp      byte[esi],'$'
       je       K
       jmp      Err1
K:
       invoke   WriteConsole,[stdout],CMsg2,lenCMsg2,NULL,NULL
       jmp      exit
Err1:
       invoke   WriteConsole,[stdout],CMsg3,lenCMsg3,NULL,NULL
;выход с задержкой
exit:
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
