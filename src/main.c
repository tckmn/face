/*
 * face - fairly awful c-based esolang
 * Copyright (C) 2017  Keyboard Fire <andy@keyboardfire.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "face.h"

#define BUF_SIZE 500

int main(int argc, char **argv) {
    int arg, help = 0, version = 0;
    FILE *fp;
    for (arg = 1; arg < argc; ++arg) {
        if (*argv[arg] != '-') {
            // first bare argument is the input filename
            fp = fopen(argv[arg], "r");
            if (!fp) {
                fprintf(stderr, "cannot open file `%s' for reading\n", argv[arg]);
                return 1;
            }
            break;
        }
        if (argv[arg][1] == '-') {
            // stop parsing if -- is encountered
            if (!argv[arg][2]) break;
            // test for long options
            if (!strcmp(argv[arg]+2, "help")) help = 1;
            else if (!strcmp(argv[arg]+2, "version")) version = 1;
            else {
                fprintf(stderr, "unknown long option `%s'\n", argv[arg]);
                return 1;
            }
            continue;
        }
        if (!argv[arg][1]) {
            // a plain dash is interpreted as stdin
            fp = stdin;
            break;
        }
        // test for short options
        for (char *opt = argv[arg]+1; *opt; ++opt) {
            switch (*opt) {
            case 'h':
                help = 1;
                break;
            case 'v':
                version = 1;
                break;
            default:
                fprintf(stderr, "unknown short option `-%c'\n", *opt);
                return 1;
            }
        }
    }

    if (help) {
        printf("usage: %s FILENAME [ARGS]...\n"
               "       %s -h|--help\n"
               "       %s -v|--version\n",
               argv[0], argv[0], argv[0]);
        return 0;
    }

    if (version) {
        // TODO update upon release of first actual version
        printf("face version 0.0.0\n");
        return 0;
    }

    if (!fp) {
        fprintf(stderr, "usage: %s FILENAME [ARGS]...\n"
                        "see `%s --help' or `man face' for more information\n",
                        argv[0], argv[0]);
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
