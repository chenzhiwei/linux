# Python

At first, let's fuck Python before using it.

## Pep8

Python code syntax format.

I hate to wrap a line when it exceeds 79 characters.

[pep8 document][pep8-doc]

[pep8-doc]: http://pep8.readthedocs.org/en/latest/

可以顺便了解一下`flake8`。

## Python internationalization

[Babel](https://pypi.python.org/pypi/Babel/)用着不错。

## Debug python code

```python
def add(x, y):
    return x + y

a = 'abc'
b = 'efg'
import pdb
pdb.set_trace()
ab = add(a, b)
print ab
```

When you execute these code, the pdb debugger will appear.

You can use `help` in pdb to show available commands, and use `help command` to show detailed help message of the command.
