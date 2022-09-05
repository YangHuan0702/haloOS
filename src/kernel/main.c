#include "proc.h"
#include "defs.h"

int main(){
    print("OS: Start\n");
    user_init();
    while(1){
        println("OS Running...");
    }    
    return 0;
}