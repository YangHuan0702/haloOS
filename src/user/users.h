struct stat;



// system call
int write(int,void*,int);
int open(const char*,int);
int dup(int);
int mknod(char*,int,int);
int fork();
int exec(char*,char**);
int wait(int*);
int read(int,char*,int);
int exit(int) __attribute__((noreturn));
char* sbrk(int);
int fstat(int, struct stat*);
int close(int);

// printf.c
// void fprintf(int,char*,...);
// void println(char*);
// void printf(char*,...);
void fprintf(int, const char*, ...);
void printf(const char*, ...);


// str.c
void* memset(void*,int,int);
uint strlen(const char*);
void* memmove(void*,const void*,int);
int atoi(const char*);
int memcmp(const void *, const void *, uint);
void *memcpy(void *, const void *, uint);
char* gets(char*, int);
int stat(const char *, struct stat*);
char* strchr(const char*, char c);
char* strcpy(char*, const char*);


// umem.c
void free(void*);
void* malloc(uint);