#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "src/user/users.h"

int main(){
    if(open("console",O_RDWR) < 0){
        mknod("console",1,0);
        open("console",O_RDWR);
    }
    dup(0); // std out
    dup(0); // std error

    int pid =0,wpid;
    for(;;){
        printf("init: start sh...\n");
        pid = fork();
        if(pid < 0){
            printf("init: fork failed\n");
        }
        if(pid == 0){
            exec("ls",0);
        } 
        for(;;){
            wpid = wait((int *) 0);
            if(wpid == pid){
                break;
            }else if(wpid < 0){
                printf("init: wait returned an error\n");
            }else{

            }
        }
    }
    return 0;
}