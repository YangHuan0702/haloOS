#include "proc.h"
#include "defs.h"


void start_task(){
    print("OS start\n");
	user_init();
}

int os_main(){

    start_task();


    int current_task = 0;

    while (1) {
        print("OS: Activate next task\n");
        run_target_task_num(current_task);
        print("OS: Back to OS\n");
        int tasks = get_tasks();
		current_task = (current_task + 1) % tasks;
		print("\n");
    }
    
    return 0;
}