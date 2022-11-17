struct stat;
struct rtcdate;


// system call
int write(int,void*,int);
int open(const char*,int);
int dup(int);
int mknod(char*,int,int);
int fork();
int exec(char*,char**);
int wait(int*);
int read(int,void*,int);
int exit(int) __attribute__((noreturn));
char* sbrk(int);
int fstat(int, struct stat*);
int close(int);

// printf.c
// void fprintf(int,char*,...);
// void println(char*);
// void printf(char*,...);
// void fprintf(int, const char*, ...);
void printf(const char*, ...);

// int stat(const char*, struct stat*);
// char* strcpy(char*, const char*);
// void *memmove(void*, const void*, int);
// char* strchr(const char*, char c);
// int strcmp(const char*, const char*);
// char* gets(char*, int max);
// uint strlen(const char*);
// void* memset(void*, int, uint);
// void* malloc(uint);
// void free(void*);
// int atoi(const char*);
// int memcmp(const void *, const void *, uint);
// void *memcpy(void *, const void *, uint);
