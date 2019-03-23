#!/bin/bash

if [ $# -ne 2 ] 
then
	return
fi

cd templates
for i in `ls`
do
	convert $i -fill $1 -opaque '#000000' -fill $2 -opaque '#FFFFFF' ../$i
done
