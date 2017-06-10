#include <stdio.h>
#include <stdlib.h>
#include "face.h"

#define BUF_SIZE 500

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s FILENAME [ARGS...]\n", argv[0]);
        return 1;
    }

    // open and check input file
    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        fprintf(stderr, "cannot open file %s for reading\n", argv[1]);
        return 1;
    }

    // read file into memory
    size_t len = 0, read;
    char *data = NULL, *newdata;
    do {
        if (!(newdata = realloc(data, len += BUF_SIZE))) {
            fprintf(stderr, "call to realloc() failed - out of memory?\n");
            free(data);
            fclose(fp);
            return 1;
        }
        data = newdata;
    } while ((read = fread(data + len - BUF_SIZE, 1, BUF_SIZE, fp)) == BUF_SIZE);

    // check for errors
    if (ferror(fp)) {
        fprintf(stderr, "error while reading file %s\n", argv[1]);
        free(data);
        fclose(fp);
        return 1;
    } else if (!feof(fp)) {
        fprintf(stderr, "something weird happened, giving up\n");
        free(data);
        fclose(fp);
        return 1;
    }
    fclose(fp);

    // run the input file and arguments as face code
    face_run(data, len - BUF_SIZE + read, argc - 2, argv + 2);

    // cleanup
    free(data);
    return 0;
}
