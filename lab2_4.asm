Format PE console
entry start
include 'includes\win32ax.inc'
section '.data' data readable writeable
stdin dd ?
stdout dd ?
Z dd ?
N dd ?
Y dd 0
array dd ?
hHeap dd ?
first db 100 dup(?),?

section '.code' code readable executable
start:
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov [stdout],eax
invoke GetStdHandle, STD_INPUT_HANDLE
mov [stdin], eax
cinvoke scanf, "%d", Z
cinvoke scanf, "%d", N
cmp eax,1
jne er1
invoke HeapCreate,0,0,0
cmp eax,NULL
jne GoodCreateHeap
cinvoke printf,"Error create heap"
jmp exit
GoodCreateHeap:
mov [hHeap],eax
mov ebx,[N]
shl ebx,2
invoke HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,ebx
mov [array],eax
push [N]
push [array]
call readArray
push[N]
push [array]
call SortArray

mov esi, [array]
mov ecx, [N]
mov edi, [Y]
mov ebx, [Z]
mov ebp, 0
m1: 		;большие числа
mov eax, 4 ;расстояние между наибольшим подходящим и наименьшим подходыящим элементом
imul ecx
push ecx
sub eax, 4 ;
add esi, eax ;перемещаемся в последний элемент, который не равен нулю
cmp ebx,[esi] ;сравнение доступного места и размера файла
jl m2
m3:			;маленькие числа
sub ebx,[esi]
mov ebp,[esi] ;последний элемент из подходящих
mov [esi], edi ;меняем значение в массиве на 0
cmp ecx,1
jle exit1
sub esi, eax  ;вовзрат к начальному(не к первому) элементу
cmp ebx,[esi] ;53
jl exit1
sub ebx, [esi]
mov ebp, [esi]
mov [esi], edi
add esi, 4
pop ecx
dec ecx
loop m1
jmp exit1
m2: 	;поиск максимально возможного
pop ecx
dec ecx
push ecx
sub eax, 4
sub esi, 4
cmp ebx, [esi]
jg m3
loop m2
exit1:
pop ecx

mov esi, [array]
mov ecx, [N]
mov eax, 0
mov edx, [Y]
mark:
push ecx
cmp [esi], edx
jne mark1
inc eax
mark1:
add esi, 4
pop ecx
loop mark
cinvoke printf,"%d %d %c%c", eax, ebp, 10, 13
xor eax,eax
mov [hHeap],eax
invoke HeapReAlloc,[array],HEAP_ZERO_MEMORY,[array],ebx
mov [array],eax
mov ecx,[N]
mov esi,[array]

invoke HeapFree,[hHeap],0,[array]
cmp eax,0
je er1
invoke HeapDestroy,[hHeap]
exit:
invoke ReadConsole,[stdin],first,1,array,NULL
invoke ExitProcess,0
er1: cinvoke printf,"Error input"
jmp exit

proc readArray
push ebp
mov ebp,esp
pusha
mov ecx,[ebp+12]
mov esi,[ebp+8]
readArr:
push ecx
cinvoke scanf,"%d",esi
add esi,4
pop ecx
loop readArr
popa
pop ebp
ret 8
endp

proc SortArray
push ebp
mov ebp,esp
pusha
mov ecx,[ebp+12]
mov esi,[ebp+8]
dec ecx
l1:
mov edi,esi
mov eax,[esi]
mov ebp,esi
add ebp,4
push ecx
l2: cmp eax,[ebp]
jle _l2
mov eax,[ebp]
mov edi,ebp
_l2: add ebp,4
loop l2
mov ebx,[esi]
mov [esi],eax
mov [edi],ebx
pop ecx
add esi,4
loop l1
popa
pop ebp
ret 8
endp

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
HeapReAlloc,'HeapReAlloc',\
HeapFree,'HeapFree',\
CreateFile, 'CreateFileA',\
CloseHandle,'CloseHandle',\
ReadFile, 'ReadFile',\
GetFileSize, 'GetFileSize'
import msvcrt, printf,'printf', scanf,'scanf', \
getchar, 'getchar'
