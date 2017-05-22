#!/bin/bash

id=$1
if [[ -z $id ]]; then
    id=110000200010101019
fi

factor=(0:7 1:9 2:10 3:5 4:8 5:4 6:2 7:1 8:6 9:3 10:7 11:9 12:10 13:5 14:8 15:4 16:2)
remainders=(0:1 1:0 2:x 3:9 4:8 5:7 6:6 7:5 8:4 9:3 10:2)

# Get the final number of ID
final=${id:(-1)}

# Calculate sum of first 17 numbers
sum=0
for fact in ${factor[@]}; do
    index=${fact%:*}
    value=${fact##*:}
    num=${id:$index:1}
    sum=$(( sum + $((num * value)) ))
done

# Calculate the remainer
remainer=$((sum % 11))

# Get the expected final number
expect_final=0
for rem in ${remainders[@]}; do
    index=${rem%:*}
    value=${rem##*:}
    if [[ $index -eq $remainer ]]; then
        expect_final=$value
    fi
done

if [[ "$final" == "$expect_final" ]]; then
    echo
    echo "The ID number($id) is a valid number"
    echo
else
    echo
    echo "The expected final number is $expect_final"
    echo "The ID number($id) is invalid"
    echo
fi
