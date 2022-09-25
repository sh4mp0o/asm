format 				PE console      
entry  		 		start          
include 			'includes\win32ax.inc'
; одномернный массив
section 			'.data' data    readable writeable
MaxCnt			=	100
N				dd		?
min				dd		?
max 			dd		?
Array			dd		MaxCnt dup(?)

section 			'.code' code    readable  executable
start:
		cinvoke		printf," N = "
		cinvoke		scanf, "%d", N
		cmp			eax,1
		jne 		er1
; ввод массива
		mov			ecx,[N]
		mov			esi, Array
readArr:
		push		ecx
		cinvoke		scanf,"%d",esi
		cmp			eax,1
		jne			er1
		add			esi,4
		pop			ecx
		loop		readArr
; поиск максимального элемента
		mov			eax,[Array]
		mov			ecx,[N]
		dec			ecx
		mov			ebx, 1
lcmp:	
		mov			esi, ebx
		shl			esi, 2
		cmp			eax, [Array+esi]	
		jge			_lcmp
		mov			eax, [Array+esi]
_lcmp:	
		inc			ebx
		loop		lcmp
		mov			[max],eax
		
;поиск минимального элемента
		mov			edx,[Array]
		mov			ecx,[N]
		dec			ecx
		mov			ebx,1
lmin:
		mov			esi,ebx
		shl			esi,2
		cmp			edx,[Array+esi]
		jle			_lmin
		mov			edx, [Array+esi]
		
_lmin:
		inc			ebx
		loop 		lmin
		mov			[min],edx
		
;замена минимального на максимальный
		mov			eax,[Array]
		mov			ecx,[N]
		mov			esi, Array
chng:
		push		ecx
		cmp			eax,[min]
		jne			_chng
		mov			edx,[max]
		mov			[esi],edx
_chng:
		add			esi,4
		mov			eax,[esi]
		pop			ecx
		loop		chng

;вывод
		mov			ecx,[N]
		mov			esi, Array
writeArr1:
		push		ecx
		cinvoke		printf, "%d %c%c", dword [esi],10,13
		add			esi,4
		pop			ecx
		loop		writeArr1
		
		jmp			exit


er1:	cinvoke		printf,"Input Error"		
exit:
        
        cinvoke		getchar
        invoke  	ExitProcess,0
        


section			 '.idata' import data readable writeable
library			kernel32,'kernel32.dll', msvcrt, 'msvcrt.dll'
import  		kernel32,ExitProcess , 'ExitProcess' ,\
				GetStdHandle,'GetStdHandle',\
				WriteConsole,'WriteConsoleA',\
				ReadConsole,'ReadConsoleA',\
				GetProcessHeap, 'GetProcessHeap',\
				HeapCreate , 'HeapCreate' ,\
				HeapDestroy , 'HeapDestroy' ,\
				HeapAlloc , 'HeapAlloc' ,\
				HeapFree , 'HeapFree'
import			msvcrt, printf,'printf',scanf, 'scanf' ,getchar,'getchar'

; %d - целые  %c - cимвол  %s - cтрока
; printf(строка формата, список переменных )  printf(" Z = %d X = %d \n",z,x);  cinvoke printf," Z = %d X = %d %c%c",[z],[x],10,13
; scanf(строка формата, cписок адресов)			scanf("%d", &z);				cinvoke scanf,"%d",z
