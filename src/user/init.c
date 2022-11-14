#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "src/user/users.h"


char *argv[] = { "sh", 0 };


int main(){
    // 标准输入
    if(open("console",O_RDWR) < 0){
        mknod("console",1,0);
        open("console",O_RDWR);
    }
    dup(0); // 标准输出
    dup(0); // 异常输出
    int pid = 0,wpid;
    for(;;){
        printf("init: starting sh\n");
        pid = fork();
        if(pid < 0){
            printf("init: fork failed\n");
        }
        if(pid == 0) {
            exec("/sh",argv);
            printf("--------init exec sh panic-------\n");
            exit(1);
        } 
        printf("--------init exec sh panic-------\n");
        for(;;){
            wpid = wait((int *) 0);
            if(wpid == pid){
                break;
            }else if(wpid < 0){
                printf("init: wait returned an error\n");
                exit(1);
            }else{

            }
        }
    }
    return 0;
}