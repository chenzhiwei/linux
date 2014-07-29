#include <Python.h>
#include "calculate.c"

static PyObject *
PyCal_add(PyObject *self, PyObject *args)
{
    int m;
    int n;
    int t;
    int ret;
    if(!PyArg_ParseTuple(args, "iii", &m, &n, &t))
    {
        return NULL;
    }
    ret = add(m, n);
    return Py_BuildValue("i", ret);
}

static PyObject *
PyCal_square(PyObject *self, PyObject *args)
{
    int n;
    int ret;
    if(!PyArg_ParseTuple(args, "i", &n))
    {
        return NULL;
    }
    ret = square(n);
    return Py_BuildValue("i", ret);
}

static PyObject *
PyCal_message(PyObject *self, PyObject *args)
{
    char *str;
    int n;
    if(!PyArg_ParseTuple(args, "si", &str, &n))
    {
        return NULL;
    }
    message(str, n);
    return Py_None;
}

static PyMethodDef CalMethods[] = {
    {"add", PyCal_add, METH_VARARGS, "Add two integer values."},
    {"square", PyCal_square, METH_VARARGS, "Square of integer value."},
    {"message", PyCal_message, METH_VARARGS, "Output a message and an integer."},
    {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC
initcalculate(void)
{
    PyObject *m;
    m = Py_InitModule("calculate", CalMethods);
    if(m == NULL)
    {
        return;
    }
}
