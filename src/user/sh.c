#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "src/user/users.h"

// struct cmd {
//     int type;
// };

// int fork1(){
//     int pid = fork();
//     if(pid == -1){
//         printf("fork1 error\n");
//     }
//     return pid;
// }

// void runcmd(char *s){
//     exec(s,0);
// }

// int getcmd(char *buf,int sz){
//     printf("$ ");
//     memset(buf,0,sz);
//     char c;
//     int i;
//     for(i = 0; i+1 < sz; i++){
//         int r = read(0,&c,1);
//         if(r < 0){
//             break;
//         }
//         buf[i] = c;
//         if(c == '\n' || c == '\r'){
//             break;
//         }
//     }
//     buf[i+1] = '\0';
//     return 0;
// }

int main(){
    printf("$ ");
    // static char buf[100];
    // int fd;
    // while ((fd = open("console",O_RDWR)) >= 0) {
    //     if(fd > 3){
    //         printf("sh panic: console fd > 3\n");
    //         return 0;
    //     }
    // }
    // while (getcmd(buf,sizeof(buf)) >= 0) {
    //     if(fork1() == 0){
    //         runcmd(buf);
    //     }
    //     wait(0);
    // }
    return 0;
}