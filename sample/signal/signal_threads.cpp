#include <iostream>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <ucontext.h>

using namespace std;


void foo()
{
    cout << "thread <foo> ..." << endl;
}

void fun()
{
    cout << "thread <func> ..." << endl;
}

int idx = 0;
ucontext_t context[2];
ucontext_t *context_foo = &context[0], *context_fun = &context[1];
ucontext_t context_orig;

int initContext(ucontext_t* pContext = &context_orig);

void sig_act(int signum, siginfo_t* info, void* pContext)
{
    cout << "received one signal " << signum << endl;
    cout << pContext << endl;

    ucontext_t *pnext = &context[(idx++)%2];
    
    swapcontext(&context_orig, pnext);
    initContext((ucontext_t*)&context_orig);
    cout << "leaving ..." << endl;
    alarm(1);
}


#define STACK_SIZE 4096
char stack_foo[STACK_SIZE], stack_fun[STACK_SIZE];


int initContext(ucontext_t* pContext)
{
    getcontext(context_foo);
    getcontext(context_fun);

    context_foo->uc_link = pContext;
    context_foo->uc_stack.ss_flags = 0;
    context_foo->uc_stack.ss_size = STACK_SIZE;
    context_foo->uc_stack.ss_sp = stack_foo;
    context_fun->uc_link = pContext;
    context_fun->uc_stack.ss_flags = 0;
    context_fun->uc_stack.ss_size = STACK_SIZE;
    context_fun->uc_stack.ss_sp = stack_fun;
    makecontext(context_foo, foo, 0);
    makecontext(context_fun, fun, 0);

    return 0;
}

int initSignal() 
{
    struct sigaction act;
    act.sa_flags = SA_SIGINFO;
    act.sa_sigaction = sig_act;
    sigaction(SIGQUIT, &act, NULL);
    sigaction(SIGALRM, &act, NULL);

    return 0;
}

int main(int argc, char* argv[])
{
    initSignal();
    initContext();

    alarm(1);
    
    while(true)
    {
        sleep(1);
    }

    return 0;
}
