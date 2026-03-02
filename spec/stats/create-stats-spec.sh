#!/bin/bash

for file
do
	script=${file%.[0-9]*}
	script=${script##*/}
	echo \
	"$LKP_SRC/programs/$script/parse $file > ${file}.yaml"
	$LKP_SRC/programs/$script/parse $file > ${file}.yaml
done
