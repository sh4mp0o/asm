format PE console

entry start

include 'includes\win32ax.inc'

section '.data' data readable writeable

aMsg	db		'a = '
laMsg	=		$-aMsg
a		dd		?
bMsg	db		'b = '
lbMsg	=		$-bMsg
b		dd		?
xMsg	db		'x = '
lxMsg	=		$-xMsg
result	dd		?

Err0	db		'Input Error.'
lErr0	=		$-Err0
Err1	db		'Division by zero.'
lErr1 	= 		$-Err1

stdin	dd		?
stdout	dd		?

buffer  db    	15 dup(?);?,?,?
lenbuf  =     	$-buffer
cntread dd    	?

errorIn dd    	?

section '.code' code readable executable

start:
			invoke	GetStdHandle, STD_INPUT_HANDLE
			mov		[stdin], eax
			invoke	GetStdHandle, STD_OUTPUT_HANDLE
			mov		[stdout], eax
			
;X = 52*b/a+b, if a > b
;X = -125, if a = b
;X = (a-5)/b, if a < b
			invoke WriteConsole,[stdout],aMsg,laMsg,NULL,NULL
			stdcall	readInt,a,errorIn
			cmp		dword[errorIn],0
			jne 	o1
			invoke WriteConsole,[stdout],bMsg,lbMsg,NULL,NULL
			stdcall	readInt,b,errorIn
			cmp		dword[errorIn],0
			jne 	o1
			
			mov		ebx,[a]
			mov		ecx,[b]
			cmp		ebx,ecx
			jg		r1
			je		r2
			jl		r3
			
r1:
			cmp		ebx,0
			je		o2
			imul	ecx,52
			mov		eax,ecx
			mov		esi,ebx
			cdq
			idiv	esi
			mov		[result],eax
			mov		ecx,[b]
			add		[result],ecx
			jmp		e1
	
r2:
			mov		[result],-125
			jmp		e1
			
r3:
			cmp		ecx,0
			je		o2
			sub		ebx,5
			mov		eax,ebx
			mov		esi,ecx
			cdq
			idiv	esi
			mov		[result],eax
			jmp		e1
			
e1:
			invoke 	WriteConsole,[stdout],xMsg,lxMsg,NULL,NULL
			stdcall writeInt, [result]
			jmp 	exit
			
o1:
			invoke WriteConsole,[stdout],Err0,lErr0,NULL,NULL
			jmp exit
			
o2:
			invoke WriteConsole,[stdout],Err1,lErr1,NULL,NULL
			jmp exit
			
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

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL'
        import  kernel32,\
                GetStdHandle,'GetStdHandle',\
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'
