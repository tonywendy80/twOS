#include <iostream>
#include <ucontext.h>
#include <string.h>
#include <unistd.h>

using namespace std;

ucontext_t env;

void foo()
{
	cout << "entering foo..." << endl;
	setcontext(&env);
	cout << "leaving foo..." << endl;
}

int main(int argc, char* argv[])
{
	getcontext(&env);

	sleep(1);
	cout << "entering main..." << endl;

	foo();

	return 0;
}

