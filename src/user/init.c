#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "src/user/users.h"


int main(){
    printf("join init");
    if(open("console",O_RDWR) < 0){

    }
    dup(0);
    dup(0);

    for(;;){
        printf("init: starting sh\n");
    }
    return 0;
}