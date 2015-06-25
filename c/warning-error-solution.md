# Warnings and Errors

### warning: function declaration isn't a prototype

You may need to change `int foo()` to `int foo(void)`.

In C int foo() and int foo(void) are different functions. int foo() accepts an arbitrary number of arguments, while int foo(void) accepts 0 arguments. In C++ they mean the same thing. I suggest that you use void consistently when you mean no arguments.

If you have a variable a, extern int a; is a way to tell the compiler that a is a symbol that might be present in a different translation unit (C compiler speak for source file), don't resolve it until link time. On the other hand, symbols which are function names are anyway resolved at link time. The meaning of a storage class specifier on a function (extern, static) only affects its visibility and extern is the default, so extern is actually unnecessary.

Link: <http://stackoverflow.com/questions/42125/function-declaration-isnt-a-prototype>

### warning: implicit declaration of function func_name

Add the function declareation on top of the file.

```
#include <stdio.h>

// function declaration
int addNumbers(int, int);

int main()
{
  addNumbers(a, b);
}

int addNumbers(int a, int b)
{
    // definition
}
```

Link: <http://stackoverflow.com/questions/2161304/what-does-implicit-declaration-of-function-mean>
