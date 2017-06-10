TARGET = bin/face
.PHONY: all clean

all: $(TARGET)

bin/%.o: src/%.c $(wildcard src/*.h)
	@mkdir -p bin
	gcc $(FLAGS) -Wall -Wpedantic -c $< -o $@

$(TARGET): $(patsubst src/%.c, bin/%.o, $(wildcard src/*.c))
	@mkdir -p bin
	gcc $(FLAGS) -Wall -Wpedantic $^ -o $@

debug: FLAGS = -g

debug: $(TARGET)

release: FLAGS = -Os

release: $(TARGET)
	strip -s -R .comment -R .gnu.version $(TARGET)

clean:
	rm -rf bin
