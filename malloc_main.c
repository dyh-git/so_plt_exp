#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <malloc.h>
#include <fcntl.h>
#include <string.h>

#define BUF_LENGTH	30

int g_count = 2;

extern int g_flag0;
extern int g_flag1;

extern void *malloc_so(size_t size);
extern void free_so(void *ptr);
extern void malloc_free_so(size_t size);

void func(void)
{
	char *p = NULL;
		
	p = (char *)malloc_so(BUF_LENGTH);		//动态库出现的内存泄漏
	free_so(p);
	malloc_free_so(BUF_LENGTH);
	
	return;
}

int main(int argc, char *argv[])
{
	char *str = "are you ok.\n";
	char buf[20] = {0x00};
	
	memcpy(buf, str, (strlen(str) + 1));
	printf("data addr: %p, flag addr: %p, %p\n", &g_count, &g_flag0, &g_flag1);
	
	func();
	
	g_flag0 += 2;
	g_flag1 += 3;

//GOT表被修改	
#if 0
	buf[0] = 0xaa;
	buf[1] = 0xf7;
	buf[2] = 0x9c;
	buf[3] = 0xf7;
	
	memcpy((char *)((char *)(&g_count) - 0x30), buf, 4);	//将malloc_so替换malloc_free_so
#endif
	(void)malloc_so(BUF_LENGTH);
	printf("flag=%d, flag1=%d\n", g_flag0, g_flag1);

	return 0;	
}