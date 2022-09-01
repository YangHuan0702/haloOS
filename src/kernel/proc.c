#include "proc.h"
#include "defs.h"

void user_task0()
{
	print("Task0: Context Switch Success !\n");
	while (1) {} // stop here.
}