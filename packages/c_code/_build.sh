#!/usr/bin/bash

# clang -o dirnav dirnav.c
# gcc -o dirnav dirnav.c

# CC="zig cc"
CC="gcc"

"$CC" -o _bin/dirnav.exe dirnav.c
"$CC" -o _bin/libget_vcpkg.exe libget_vcpkg.c
"$CC" -o _bin/compare_exe.exe compare_exe.c
"$CC" -o _bin/fileinfo.exe fileinfo.c
"$CC" -o _bin/pdf_info.exe pdf_info.c
