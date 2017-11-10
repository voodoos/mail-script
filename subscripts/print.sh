#!/bin/bash

numC=$(($(echo "$1" | wc -m)-1+8))

echo ""

i=$numC
while [ "$i" -gt 0 ]
do 
    echo -n "#" 
    i=$(($i-1))
done

echo ""

i=3
while [ "$i" -gt 0 ]
do 
    echo -n "#" 
    i=$(($i-1))
done

echo -n " $1 "

i=3
while [ "$i" -gt 0 ]
do 
    echo -n "#" 
    i=$(($i-1))
done

echo ""

i=$numC
while [ "$i" -gt 0 ]
do 
    echo -n "#" 
    i=$(($i-1))
done

echo ""
