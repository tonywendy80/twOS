#include <iostream>
#include <ucontext.h>
#include <unistd.h>
#include <string.h>

using namespace std;

#define STACK_SIZE 1024

typedef void(*FUNC)();

ucontext_t env_main, env_foo, env_fun;
char stack_foo[STACK_SIZE], stack_fun[STACK_SIZE];

void foo(const char* name, const char* value)
{
    cout << "entering foo..." << endl;
    cout << "NAME: " << name << "; VALUE: " << value << endl;
    
    //setcontext(&env_main);

    cout << "leaving foo..." << endl;

}

void fun()
{
    cout << "fun body..." << endl;
}

/*
OUTPUT:
entering main...
fun body...
entering foo...
NAME: year; VALUE: 2022
leaving foo...
leaving main...
*/

int main(int argc, char* argv[])
{
    char* name = new char[16];
    char* value = new char[16];
    strcpy(name, "age");
    strcpy(value, "16");
    cout << "entering main..." << endl;

    getcontext(&env_foo);
    env_foo.uc_link = &env_main;
    env_foo.uc_stack.ss_flags = 0;
    env_foo.uc_stack.ss_sp = stack_foo;
    env_foo.uc_stack.ss_size = STACK_SIZE;
    makecontext(&env_foo, (FUNC)&foo, 2, name, value);

    getcontext(&env_fun);
    env_fun.uc_link = &env_foo;
    env_fun.uc_stack.ss_flags = 0;
    env_fun.uc_stack.ss_sp = stack_fun;
    env_fun.uc_stack.ss_size = STACK_SIZE;
    makecontext(&env_fun, (FUNC)&fun, 0);

    /*
    ** The following statements modify the contents of name and value. In consequence, the foo will
    ** print out 'year' and '2022' accordingly.
    */
    strcpy(name, "year");
    strcpy(value, "2022"); 


    swapcontext(&env_main, &env_fun);
    cout << "leaving main..." << endl;


    return 0;
}