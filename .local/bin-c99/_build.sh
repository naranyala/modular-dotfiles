#!/usr/bin/bash

# clang -o dirnav dirnav.c
# gcc -o dirnav dirnav.c

zig cc -o dirnav dirnav.c 
zig cc -o libget_vcpkg libget_vcpkg.c 
