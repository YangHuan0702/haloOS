#include "src/kernel/type.h"
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "user/users.h"


int main(){
    if(open("console",O_RDWR) < 0){

    }
    dup(0);
    dup(0);

    for(;;){
        printf("init: starting sh\n");
    }
    return 0;
}