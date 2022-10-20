#include "type.h"
#include "defs.h"
#include "file.h"
#include "proc.h"

int exec(char *path,char** argv){
    struct inode *node = getInodeByDevAndINum(ROOTDEV,ROOTINO);
    struct proc *p = myproc();
    path+=1;

    
}