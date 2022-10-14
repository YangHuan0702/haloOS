#include "type.h"
#include "memlayout.h"
#include "file.h"
#include "fs.h"
#include "spinlock.h"

#define MAX_TASK 1024

struct context;

struct proc {
  struct spinlock slock;

  char name[16];
  uint pid;
  
  struct context cont;
  struct file *openfs[OPENFILE];
  struct inode *pwd;
};


struct context {
  uint64 ra;
  uint64 sp;

  // callee-saved
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};
