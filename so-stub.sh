#!/bin/sh

set -e
set -x

# This has been tested on FreeBSD 12.2

if [ "$#" -ne 1 ] ; then
  echo "Usage: $0 /usr/local/lib/libsome.so" >&2
  exit 1
fi

ORIG_LIB="${1}"
STUB_LIB=$(basename "${ORIG_LIB}")
LIB_NAME=$(basename "${STUB_LIB}" | cut -d "." -f 1 | sed -e 's|-|_|g' )

# Read all symbols that are defined in the original library
nm "${ORIG_LIB}" --dynamic --defined-only | awk '{print $3}' > symbols.txt

# Create an input file for the compiler
while IFS= read -r line; do
    # echo '-Wl,--defsym='$line'=stub'
    echo "-Wl,--defsym=${line}=${LIB_NAME}"
done < symbols.txt > compilerinput.txt

# Compile and strip
c++ -shared -Wall -fPIC -DLNAME="${STUB_LIB}" -DFNAME="${LIB_NAME}" stubs.c \@compilerinput.txt -o "${STUB_LIB}"
strip "${STUB_LIB}"
ls -lh $(readlink -f "${ORIG_LIB}")
ls -lh "${STUB_LIB}"
