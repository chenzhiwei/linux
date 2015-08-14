# GCC

## Typical C++ Makefile

```
CXX = g++
CXXFLAGS = -g -O0 -pthread -std=c++0x
LDFLAGS += -lmesos -lpthread -lprotobuf
CXXCOMPILE = $(CXX) $(INCLUDES) $(CXXFLAGS) -c -o $@
ME_INCLUDES = -I/usr/local/mesos/include/ -L/usr/local/mesos/build/src/.libs/
CXXLINK = $(CXX) $(INCLUDES) $(ME_INCLUDES) $(CXXFLAGS) -o $@

default: all
all: rendler crawl_executor render_executor

HEADERS = rendler_helper.hpp


crawl_executor: crawl_executor.cpp $(HEADERS)
    $(CXXLINK) $<  $(LDFLAGS) -lboost_regex -lcurl

%: %.cpp $(HEADERS)
    $(CXXLINK) $< $(LDFLAGS)

clean:
    (rm -f core crawl_executor render_executor rendler)
```

* -O0 means no compiler Optimization, usually used in debug mode.
* -lmesos means dynamic libs, i.e. `libmesos.so`
* -I/dir the /dir contains header files, i.e. `*.h`
* -L/dir the /dir contains `*.so` or `*.a` file, i.e. `libmesos.so`
