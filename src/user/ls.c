#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "src/kernel/file.h"
#include "src/kernel/fs.h"
#include "src/user/users.h"


int main(int argc,char *args[]){
    int fd ;
    if((fd = open("/",0)) < 0){
        printf("ls: cannot open\n");
        exit(0);
        return 0;
    }
    struct stat st;
    if(fstat(fd,&st) < 0){
        printf("ls: connot to stat");
        close(fd);
        exit(0);
        return 0;
    }
    struct dirent d;
    while (read(fd,&d,sizeof(d)) == sizeof(d)) {
        if(d.inum == 0){
            continue;
        }
        printf("%s %d %d %d\n",d.name,st.type,st.ino,st.size);
    }
    close(fd);    
    exit(0);
    return 0;
}