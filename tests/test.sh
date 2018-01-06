#!/bin/bash

TIMEOUT=0.1 # may need adjusting on slower systems?

out=
lnum=0
fail=()
total=0

while IFS= read -r line
do
    lnum=$((lnum+1))
    if [ "${line:0:1}" = ' ' ]
    then
        line="$(sed 's/^ *//' <<<"$line")"
        if [ -z "$out" ]
        then
            if [ "${line:0:1}" = '!' ]
            then
                out="x$(timeout $TIMEOUT bash -c "${line:1}")"
            else
                out="x$(timeout $TIMEOUT bin/face <(echo "$line"))"
            fi
            if [ $? -eq 124 ]
            then
                out='x*timeout*'
            fi
            out="${out//$'\n'/\\n}"
        else
            if [ "$out" != "x$line" ]
            then
                fail+=("test failure on line $lnum (expected $line, got ${out:1})")
                echo -n !
            else
                echo -n .
            fi
            total=$((total+1))
            out=
        fi
    fi
done <tests/data.txt

echo
if [ -z "$fail" ]
then
    echo -e "\\e[1m\\e[32m$total tests passed\\e[m"
else
    printf '%s\n' "${fail[@]}"
    echo -e "\\e[1m\\e[31m${#fail[@]}/$total tests failed\\e[m"
    exit 1
fi
