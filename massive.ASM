;òèï ïðèëîæåíèÿ
     format PE console
;òî÷êà âõîäà
     entry      start
;ïîäêëþ÷åíèå ìàêðîáèáëèîòåê
     include 'WIN32A.INC'   ;'includes\win32ax.inc'
;ñåêöèÿ äàííûõ
     section '.data' data readable writeable
cMsg1        db      'N = '
lencMsg1     =$ - cMsg1
cMsg2        db      'Input array :', '\n', '\r'
lencMsg2     =$ - cMsg2
cMsg3        db      'Summa = '
lencMsg3     =$ - cMsg3
cMsg4        db      'Error input'
lencMsg4     =$ - cMsg4

MaxSize         =  100
Array        dd     MaxSize dup(?)
n            dd     ?

stdin         dd    ?
stdout        dd    ?

buffer        db    15 dup(?);?,?,?
lenbuf        =     $-buffer
cntread       dd    ?

errorIn       dd    ?



;ñåêöèÿ êîäà
      section   '.code' code    readable executable
 start:
 ;ïîëó÷åàì äåñêðèïòîðû ïîòêîâ ââîäà è âûâîäà
       invoke   GetStdHandle,STD_INPUT_HANDLE
       mov      [stdin],eax
       invoke   GetStdHandle,STD_OUTPUT_HANDLE
       mov      [stdout],eax
;ââîä ìàññèâà
       invoke     WriteConsole,[stdout],cMsg1,lencMsg1,NULL,NULL
       stdcall    readInt,n,errorIn
       cmp        [errorIn],0
       jne        wrErr
       cmp        [n],MaxSize
       jg         wrErr
       cmp        [n],1
       jl         wrErr
       invoke     WriteConsole,[stdout],cMsg2,lencMsg2,NULL,NULL

       mov        ecx,[n]
       mov        esi,Array
readAr:
       stdcall    readInt,esi,errorIn
       cmp        [errorIn],0
       jne        wrErr
       add        esi,4
       loop       readAr

;ñóììà ÷åòíûõ ýëåìåíòîâ
       mov    ecx, [n]
       mov    esi,0;idx
       xor    eax,eax

SummAr:
       test     dword [Array+4*esi],1;ïîáèòîâàÿ êîíúþíêöèÿ
       jnz      ends1
       add      eax,[Array+4*esi]

ends1:
       inc      esi
       loop     SummAr

       push    eax
       invoke  WriteConsole,[stdout],cMsg3,lencMsg3,NULL,NULL
       pop     eax
       stdcall writeInt,eax
       jmp     exit

wrErr:
       invoke     WriteConsole,[stdout],cMsg4,lencMsg4,NULL,NULL
;âûõîä ñ çàäåðæêîé
exit:
       invoke   ReadConsole,[stdin],buffer,lenbuf,cntread,NULL
       invoke   ExitProcess,0
;ïîäïðîãðàììà âûâîäà ÷èñëà, â ñåêöèè äàííûõ èñïëüçóåòñÿ ñòðîêà
;   buffer
proc    writeInt        number
;ïðîëîã - ñîõðàíÿåì ðåãèñòðû
        push        eax
        push        edx
        push        ebp
        push        ecx
        push        esi
        push        ebx
;îáðàáîòêà ÷èñëà
        mov     eax,[number]
        mov     esi, buffer
        xor     ebp,ebp
        xor     ecx,ecx
        mov     ebx,10
;çíàê
        cmp     eax,0
        jge     m1
        mov     [esi],byte '-'
        inc     esi
        inc     ebp
        neg     eax
m1:
;ïîëó÷åíèå öèôð
        cdq
        div     ebx
        push    edx
        inc     ecx
        cmp     eax,0
        jne     m1
;ôîðìèðîâàíèå ñòðîêè
        add   ebp,ecx ;äëèíà íà âûâîä
m2:
        pop     edx
        add     dl,'0'
        mov     [esi],dl
        inc     esi
        loop    m2

        invoke  WriteConsole,[stdout],buffer,ebp,NULL,NULL


; ýïèëîã - âîñòàíàâëèâàåì ðåãèñòðû
         pop        ebx
         pop        esi
         pop        ecx
         pop        ebp
         pop        edx
         pop        eax
        ret
        endp
;ïîäïðîãðàììà ââîäà öåë ÷èñëà ñ êîíòðîëåì ââåäåííûõ ñèìâîëîâ è ïåðåïîëíåíèÿ
proc    readInt number, errorIn
        pusha
;ââîä ÷èëñà
        invoke ReadConsole,[stdin],buffer,lenbuf,cntread,NULL
        mov    ecx,[cntread]
        sub    ecx,2
        xor    eax,eax
        xor    ebx,ebx
        xor    esi,esi
        mov    edi,10;[esi] [buffer+esi]
;àíàëèç çíàêà
        cmp     byte [buffer+esi],'-'
        jne     m3
        inc     esi
        dec     ecx
;îáðàáîòêà öèôð
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



;ñåêöèÿ èìïîðòà
        section '.idata' import data readable writeable
        library kernel32,'KERNEL32.DLL'
        import  kernel32,\
                GetStdHandle,'GetStdHandle',\
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'
