# bubblemon configuration
EXTRA =

# where to install this program
PREFIX = /usr/local

# no user serviceable parts below
EXTRA += $(WMAN)
# optimization cflags
USER_CFLAGS = -O3 -ansi -Wall
# profiling cflags
# USER_CFLAGS = -ansi -Wall -pg -O3 -DPRO
# test coverage cflags
# USER_CFLAGS = -fprofile-arcs -ftest-coverage -Wall -ansi -g -DPRO
BUILD_CFLAGS = 
CFLAGS = $(USER_CFLAGS) $(BUILD_CFLAGS) ${EXTRA}

BINARY=bubblemon
SHELL=sh
OS = $(shell uname -s)
OBJS = bubblemon.o wmx11pixmap.o
CC = gcc

# special things for Linux
ifeq ($(OS), Linux)
    OBJS += sys_linux.o
    LIBS = -lX11
    INSTALL = -m 755
endif

# special things for FreeBSD
ifeq ($(OS), FreeBSD)
    OBJS += sys_freebsd.o
    LIBS = -lX11 -lkvm
    INSTALL = -c -g kmem -m 2755 -o root
endif

# special things for OpenBSD
ifeq ($(OS), OpenBSD)
    OBJS += sys_openbsd.o
    LIBS = -lX11
endif

#special things for SunOS
ifeq ($(OS), SunOS)

    # try to detect if gcc is available (also works if you call gmake CC=cc to
    # select the sun compilers on a system with both)
    COMPILER=$(shell \
        if [ `$(CC) -v 2>&1 | egrep -c '(gcc|egcs|g\+\+)'` = 0 ]; then \
	    echo suncc; else echo gcc; fi)

    # if not, fix up CC and the CFLAGS for the Sun compiler
    ifeq ($(COMPILER), suncc)
	CC=cc
	USER_CFLAGS=-v -xO3
    endif

    ifeq ($(COMPILER), gcc)
	USER_CFLAGS=-O3 -Wall
    endif
    CFLAGS = $(USER_CFLAGS) $(BUILD_CFLAGS) ${EXTRA}
    OBJS += sys_sunos.o
    LIBS = -lX11 -lkstat -lm
    INSTALL = -m 755
endif

CFLAGS += -DNAME=\"$(BINARY)\"

all: $(BINARY)

$(BINARY): $(OBJS)
	$(CC) $(CFLAGS) -o $(BINARY) $(OBJS) $(LIBS)

bubblemon.o: bubblemon.c wmx11pixmap.h include/bubblemon.h			\
 include/sys_include.h include/clockfont.h include/numbers-2.h	\
 include/ducks.h include/digits.h misc/load_58.c misc/mem_58.c	\
 misc/numbers.xpm

wmx11pixmap.o: wmx11pixmap.c wmx11pixmap.h

sys_%.o: sys_%.c include/bubblemon.h include/sys_include.h

clean:
	rm -f $(BINARY) *.o *.bb* *.gcov gmon.* *.da *~

install:
	install $(INSTALL) $(BINARY) $(PREFIX)/bin
