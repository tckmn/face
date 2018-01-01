#!/bin/bash

out=
lnum=0
fail=0
total=0

while IFS= read -r line
do
    lnum=$((lnum+1))
    if [ "${line:0:1}" = ' ' ]
    then
        line="$(sed 's/^ *//' <<<"$line")"
        if [ -z "$out" ]
        then
            out="x$(bin/face <(echo "$line"))"
        else
            if [ "$out" != "x$line" ]
            then
                echo "test failure on line $lnum (expected $line, got ${out:1})"
                fail=$((fail+1))
            fi
            total=$((total+1))
            out=
        fi
    fi
done <tests/data.txt

if [ $fail -eq 0 ]
then
    echo -e "\\e[1m\\e[32m$total tests passed\\e[m"
else
    echo -e "\\e[1m\\e[31m$fail/$total tests failed\\e[m"
    exit 1
fi
