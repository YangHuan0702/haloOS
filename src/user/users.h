
// system call
int write(int,char*,int);
int open(char*,int);
int dup(int);
int mknod(char*,int,int);
int fork();
int exec(char*,char**);
int wait(int*);

// printf.c
void printf(char*,...);