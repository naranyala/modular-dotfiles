#!/usr/bin/bash

# clang -o dirnav dirnav.c
# gcc -o dirnav dirnav.c

zig cc -o dirnav.exe dirnav.c 
zig cc -o libget_vcpkg.exe libget_vcpkg.c 
