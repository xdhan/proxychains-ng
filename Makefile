#
# Makefile for proxychains (requires GNU make), stolen from musl
#
# Use config.mak to override any of the following variables.
# Do not make changes here.
#

exec_prefix = /usr/local
bindir = $(exec_prefix)/bin

prefix = /usr/local/
includedir = $(prefix)/include
libdir = $(prefix)/lib
syslibdir = /lib

SRCS = $(sort $(wildcard src/*.c))
OBJS = $(SRCS:.c=.o)
LOBJS = $(OBJS:.o=.lo)

CFLAGS  += -Wall -O0 -g -std=c99 -D_GNU_SOURCE -pipe 
LDFLAGS = -shared -fPIC -ldl
INC     = 
PIC     = -fPIC -O0
AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib

SHARED_LIBS = lib/libproxychains.so
ALL_LIBS = $(SHARED_LIBS)
ALL_TOOLS = proxychains

LDSO_PATHNAME = libproxychains.so.3

-include config.mak

CFLAGS_MAIN=-DLIB_DIR=\"$(libdir)\"


all: $(ALL_LIBS) $(ALL_TOOLS)

#install: $(ALL_LIBS:lib/%=$(DESTDIR)$(libdir)/%) $(DESTDIR)$(LDSO_PATHNAME)
install: 
	install -D -m 644 proxychains $(bindir)
	install -D -m 644 src/proxyresolv $(bindir)
	install -D -m 644 lib/libproxychains.so $(libdir)
	ln -sf $(libdir)/libproxychains.so $(libdir)/libproxychains.so.3

clean:
	rm -f $(OBJS)
	rm -f $(LOBJS)
	rm -f $(ALL_LIBS) lib/*.[ao] lib/*.so

%.o: %.c
	$(CC) $(CFLAGS) $(CFLAGS_MAIN) $(INC) -c -o $@ $<

%.lo: %.c
	$(CC) $(CFLAGS) $(CFLAGS_MAIN) $(INC) $(PIC) -c -o $@ $<

lib/libproxychains.so: $(LOBJS)
	$(CC) $(LDFLAGS) -Wl,-soname=libproxychains.so -o $@ $(LOBJS) -lgcc

lib/%.o:
	cp $< $@

$(ALL_TOOLS): $(OBJS)
	$(CC) src/main.o -o proxychains

$(DESTDIR)$(libdir)/%.so: lib/%.so
	install -D -m 755 $< $@

$(DESTDIR)$(libdir)/%: lib/%
	install -D -m 644 $< $@

$(DESTDIR)$(LDSO_PATHNAME): lib/libproxychains.so
	ln -sf $(libdir)/libproxychains.so $@ || true

.PHONY: all clean install
