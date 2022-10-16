#include <stdio.h>
#include <iostream>
#include <windows.h>
#include <cstring>
using namespace std;
int main()
{	
	char* str1 = new char[100];
	int length1 = 0;
	cin.getline(str1, 100);
	char* ans = new char[100]{ };
	int left = 0;
	int right = 0;
	int n = 0;
	__asm
	{
			xor		edi, edi
			mov		edi, str1
		m1 :
			cmp		[edi], 0; '\0'
			je		m2
			inc		[length1]
			inc		edi
			jmp		m1
		m2 :
			xor		esi, esi
			xor		eax, eax
			xor		ebx, ebx
			mov		esi, str1
			mov		edi, ans
			mov		ecx, [length1]
			mov		eax, 0
			dec		ecx
		m3 :
			mov		bh, byte ptr[esi + ecx]
			cmp		bh, byte ptr ' '
			jne		m4
			jmp		m10
		m4 :
			mov		[right], ecx
		m5 :
			cmp		ecx, 0
			jl		m6
			mov		bh, byte ptr[esi + ecx]
			cmp		bh, byte ptr ' '
			je		m6
			dec		ecx
			jmp		m5
		m6 :
			mov		[left], ecx
			mov		edx, [left]
			inc		edx
		m7 :
			cmp		edx, [right]
			jg		m8
			mov		bh, byte ptr[esi + edx]
			mov		byte ptr[edi + eax], bh
			inc		eax
			inc		edx
			jmp		m7
		m8 :
			cmp		[left], -1
			jne		m9
			jmp		m10
		m9 :
			mov		bh, byte ptr ' '
			mov		byte ptr[edi + eax], bh
			inc		eax
		m10 :
			dec		ecx
			cmp		ecx, 0
			jge		m3
		mov		n, eax
	}
	int i = 0;
	for (int i = 0; i < n; i++)
	{
		cout << ans[i];
	}
	cout << endl;
	return 0;
}
