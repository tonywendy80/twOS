#include <iostream>
#include <setjmp.h>

using namespace std;

jmp_buf env;

int foo(int a, int b)
{
	cout << "starting of foo..." << endl;
	longjmp(env, 2);
	cout << "end of foo..." << endl;
}

int main(int argc, char* argv[])
{

	int a = 23, b = 24;

	int ret = setjmp(env);
	if( ret == 0 )
	{
		foo(a,b);
		cout << "......." << endl;
	}
	else
	{
		cout << "jump back here..." << endl;
	}

	return 0;
}

