#!/bin/bash

out=
lnum=0
fail=0

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
                echo "test failure on line $lnum"
                fail=$((fail+1))
            fi
            out=
        fi
    fi
done <tests/data.txt

echo -ne '\e[1m'
if [ $fail -eq 0 ]
then
    echo -e '\e[32mall tests passed'
else
    s=s
    if [ $fail -eq 1 ]; then s=; fi
    echo -e "\\e[31m$fail test$s failed"
    fail=1
fi
echo -ne '\e[m'

exit $fail
