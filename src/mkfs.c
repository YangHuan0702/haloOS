#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "kernel/fs.h"

int nlog = NLOG;
int nInode = NINODE;
int bitmapn = BITMAPN;
int nmeta;
int nblocks;

struct superblock sb;

int main(int argc,char *argv[]){
    printf("---------- mkfs start -------------\n");
    for(int i =0;i< argc;i++){
        printf(argv[i]);
        printf("\n");
    }

    if(argc < 2){
        printf("argc params panic...");
        exit(1);
    }

    int fsfd = open(argv[1],O_RDWR | O_CREAT | O_TRUNC,0666);
    if(fsfd < 0 ){
        printf("open img panic...");
        exit(1);
    }    

    nmeta = 2 + nlog + nInode + bitmapn;
    nblocks = FSSIZE - nmeta;

    sb.magic = FSMAGIC;
    


    exit(0);
}