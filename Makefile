NAME = face
TARGET = bin/$(NAME)
MANPAGE = $(NAME).1
PREFIX ?= /usr/local
CC ?= gcc
LIBS = -lm -lffi
SEARCH = -I/usr/lib/libffi-3.2.1/include
.PHONY: all debug release install clean test

all: $(TARGET)

bin/%.o: src/%.c $(wildcard src/*.h)
	@mkdir -p bin
	$(CC) $(FLAGS) -std=c99 -Wall -Wextra -Wpedantic -Werror -c $< -o $@ $(SEARCH)

$(TARGET): $(patsubst src/%.c, bin/%.o, $(wildcard src/*.c))
	@mkdir -p bin
	$(CC) $(FLAGS) -std=c99 -Wall -Wextra -Wpedantic -Werror $^ -o $@ $(LIBS)

debug: FLAGS = -g -O0

debug: $(TARGET)

release: FLAGS = -O3

release: $(TARGET)
	strip -s -R .comment -R .gnu.version $(TARGET)

install: $(TARGET)
	install -D $(TARGET) $(DESTDIR)$(PREFIX)/$(TARGET)
	install -Dm644 $(MANPAGE) $(DESTDIR)$(PREFIX)/share/man/man1/$(MANPAGE)

clean:
	rm -rf bin

test: $(TARGET)
	tests/test.sh

doc/$(NAME).txt: ./$(NAME).1
	echo === NOTE: this file was automatically generated from the file $< === > $@
	echo >> $@
	MANWIDTH=80 man ./$< | col -bx >> $@
