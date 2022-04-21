#include <iostream>
#include <unistd.h>
#include <string.h>


using namespace std;


typedef void(*WORKFUNC)();

typedef struct task
{
	long rsp;
	long rip;
	long stack[1024];
	char name[64];
	task* prev;
	task* next;
} task_struct;

#define NR_TASKS 8
task_struct TASKS[NR_TASKS];
task_struct *ROOT_TASK = &TASKS[0];
task_struct *FIRST_TASK=&TASKS[1];
task_struct *LAST_TASK=&TASKS[NR_TASKS-1];
task_struct *FIRST_EMPTY_TASK = FIRST_TASK;
task_struct *CURRENT_TASK = ROOT_TASK;


void yield(bool quit = 0)
{
	task_struct *current = CURRENT_TASK;
	task_struct *next = CURRENT_TASK->next;
	if( current == next )
		return;

	CURRENT_TASK = CURRENT_TASK->next;

	if( quit )
	{
		next->prev = current->prev;
		current->prev->next = next;

		FIRST_EMPTY_TASK->prev->next = current;
		current->prev = FIRST_EMPTY_TASK->prev;
		FIRST_EMPTY_TASK->prev = current;
		current->next = FIRST_EMPTY_TASK;
	}

	long next_rip = next->rip;
	long next_rsp = next->rsp;

	__asm__ __volatile("leaq 1f, %%rax\n\t"
		"movq %%rax, %[current_rip]\n\t"
		"movq %%rsp, %[current_rsp]\n\t"
		"movq %[next_rsp], %%rsp\n\t"
		"jmp *%[next_rip]\n\t"
		"1:\n"
		:[current_rip]"=m"(current->rip), [current_rsp]"=m"(current->rsp)
		:[next_rip]"r"(next->rip), [next_rsp]"r"(next->rsp)
		:"%rsp", "%rax"
	);
}

void work()
{
	int number = 100;
	for(int i=0; i<10; i++)
	{
		sleep(1);
		cout << "[" << CURRENT_TASK->name << "] " << i << endl;
		if( i==5 )
			yield();
	}
}

void quit()
{
	cout << "[" << CURRENT_TASK->name << "] quited" << endl;
	yield(1);
}

void init()
{
	memset(TASKS, 0, sizeof(TASKS));
	for(int i=1; i<NR_TASKS-1; i++)
	{
		TASKS[i].next = &TASKS[i+1];
		TASKS[i+1].prev = &TASKS[i];
	}
	FIRST_TASK->prev = LAST_TASK;
	LAST_TASK->next = FIRST_TASK;
	FIRST_EMPTY_TASK = FIRST_TASK;

	CURRENT_TASK = ROOT_TASK;
	CURRENT_TASK->next = CURRENT_TASK;
	CURRENT_TASK->prev = CURRENT_TASK;
}

task_struct* get_empty_task()
{
	if( NULL == FIRST_EMPTY_TASK )
		return NULL;
	
	task_struct* task = FIRST_EMPTY_TASK;
	if( FIRST_EMPTY_TASK->next == FIRST_EMPTY_TASK )
		FIRST_EMPTY_TASK = NULL;
	else
	{		
		FIRST_EMPTY_TASK->prev->next = FIRST_EMPTY_TASK->next;
		FIRST_EMPTY_TASK->next->prev = FIRST_EMPTY_TASK->prev;
		FIRST_EMPTY_TASK = FIRST_EMPTY_TASK->next;
	}
	
	CURRENT_TASK->prev->next = task;
	task->prev = CURRENT_TASK->prev;
	CURRENT_TASK->prev = task;
	task->next = CURRENT_TASK;
}

void task_create(WORKFUNC worker, string name)
{
	task_struct *task = get_empty_task();
	if( NULL != task )
	{
		strncpy(task->name, name.c_str(), 64);
		task->rip = (long)worker;
		task->rsp = (long)(task->stack + 1023);
		task->stack[1023] = (long)quit;
	}
}

int main(int argc, char* argv[])
{
	init();

	task_create(&work, "FIRST");
	task_create(&work, "SECOND");

	int i = 1;
	while( i<10 )
	{
		cout << i++ << " yield called" << endl;
		yield();
	}

	return 0;
}

