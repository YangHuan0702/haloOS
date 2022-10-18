#include "type.h"
#include "defs.h"
#include "memlayout.h"
#include "file.h"
#include "spinlock.h"
#include "proc.h"

uint64 task_stack[MAX_TASK][STACK_SIZE];
struct context tasks[MAX_TASK];
struct context *current_task;
struct context os_task;
static int taskTop = 0; 


void run_os_task(){
	printf("Swtch OS TASK ... ");
	struct context *now = current_task;
	current_task = &os_task;
	swtch(now,&os_task);
}


void run_target_task_num(int num){
	printf("run_target_task_num:%d\n",num);
	current_task = &(tasks[num]);
	printP(current_task->ra);
	swtch(&os_task,current_task);
}

int get_tasks(){
	return taskTop;
}


void user_task0() {
	print("Task0: Created!\n");
	print("Task0: Now, return to kernel mode`\n");
	run_os_task();
	while (1) {
		print("Task0: Running...\n");
		for(int i = 0; i < 10000000;i++){
		}
		run_os_task();
	}
}

void user_task1() {
	print("Task1: Created!\n");
	print("Task1: Now, return to kernel mode\n");
	run_os_task();
	while (1) {
		print("Task1: Running...\n");
		for(int i = 0; i < 10000000;i++){
		}
		run_os_task();
	}
}


int task_create(void (*task)()) {
	int i=taskTop++;
	tasks[i].ra = (uint64) task;
	tasks[i].sp = (uint64) &task_stack[i][STACK_SIZE-1];
	return i;
}

void user_init() {
	task_create(&user_task0);
	task_create(&user_task1);
}


