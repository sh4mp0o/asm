;тип приложения
Format PE console
;точка входа
entry start
;подключение макробибилотек
include 'includes\win32ax.inc'
;секция данных
section '.data' data readable writeable
CMsg db 'Input string : '
lenCMsg = $-CMsg
CMsg2 db 'Correct string '
lenCMsg2 = $-CMsg2
CMsg3 db 'Uncorrect string '
lenCMsg3 = $-CMsg3
stdin dd ?
stdout dd ?
buffer db 3 dup(?);?,?,?
lenbuf = $-buffer
cntread dd ?
n=100
first db n dup(?)
filename db 100 dup(0)
lenfilename dd ?
flength dd ?
fbuf dd ?
hHeap dd ?
hFile dd ?

;секция кода
section '.code' code readable executable
start:
;получаем дискрипторы потоков ввода и вывода
;получаем дескрипторы потоков ввода и вывода
invoke GetStdHandle, STD_INPUT_HANDLE
mov [stdin], eax
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov [stdout], eax


;Вывод строки
cinvoke printf, '%s', <'Input filename : ', 0>
; ввод строки имя файла
invoke ReadConsole, [stdin], filename, 100, lenfilename, NULL
mov esi, filename
mov ecx, [lenfilename]
mov byte[esi+ecx-2], 0
;открытие файла
invoke CreateFile, filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
mov [hFile], eax
cmp eax, -1
jne OpenFile
cinvoke printf, '%s', <'Error open file', 10, 13, 0>
jmp exit
OpenFile:
invoke GetFileSize, [hFile], flength
mov [flength], eax
cinvoke printf, 'Length file = %d %s', [flength], <10, 13, 0>

;работа с кучей
invoke HeapCreate, 0,0,0
cmp eax, NULL
jne goodHeap
cinvoke printf, "Fail Create Heap"
jmp exit

goodHeap:
mov [hHeap], eax

;выделение памяти
mov ecx, [flength]
inc ecx
invoke HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, ecx
mov [fbuf], eax
invoke ReadFile, [hFile], [fbuf], [flength], cntread, NULL
mov esi, [fbuf]
mov ecx, [flength]
mov byte[esi+ecx], 0
cinvoke printf, 'file: %s %s', [fbuf], <10, 13, 0>


;Цикл Обрабтки
mov esi, [fbuf]
mov edi, [flength]
; mov [esi+ecx], byte '$'
add edi, esi
S:
	cmp byte[esi],'a'
	je SA
	jmp ERR2
SA:
	inc esi
	cmp byte[esi],'a'
	je SA
	cmp byte[esi],'b'
	je B
	jmp ERR2
B: 
	inc esi
	cmp byte[esi],'a'
	je BK
	cmp byte[esi],'b'
	je BK
	jmp ERR2
BK:
	inc esi
	cmp byte[esi],'a'
	je BK
	cmp byte[esi],'b'
	je BK
	cmp esi,edi
	je K
	jmp ERR2

K: invoke WriteConsole,[stdout],CMsg2,lenCMsg2,NULL,NULL
jmp exit
ERR2: invoke WriteConsole,[stdout],CMsg3,lenCMsg3,NULL,NULL

;выход с задержкой
exit:
invoke ReadConsole,[stdin],buffer,lenbuf,cntread,NULL
invoke ExitProcess,0
;Секция импорта
section '.idata' import data readable writeable
library kernel32,'KERNEL32.DLL',\
msvcrt, 'msvcrt.dll'
import kernel32, \
GetStdHandle, 'GetStdHandle',\
WriteConsole, 'WriteConsoleA',\
ReadConsole, 'ReadConsoleA',\
ExitProcess, 'ExitProcess',\
GetProcessHeap,'GetProcessHeap',\
HeapCreate,'HeapCreate',\
HeapDestroy,'HeapDestroy',\
HeapAlloc,'HeapAlloc',\
HeapFree,'HeapFree',\
CreateFile, 'CreateFileA',\
CloseHandle,'CloseHandle',\
ReadFile, 'ReadFile',\
GetFileSize, 'GetFileSize'
import msvcrt, printf,'printf', scanf,'scanf', \
getchar, 'getchar'
