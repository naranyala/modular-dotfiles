#!/usr/bin/bash

# clang -o dirnav dirnav.c
# gcc -o dirnav dirnav.c

zig build-exe dirnav.zig -lc -I /usr/include -L /usr/lib

