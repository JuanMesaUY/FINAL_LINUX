#!/bin/bash


if [ `ls -ld $2 | egrep ^d | cut -c1` == "d" ]
then
   SIZE="---"
   echo $SIZE 
else
   SIZE=`ls -l $2 | tr -s " " | cut -d" " -f5`
   echo $SIZE
fi
ls -ld $2 | egrep ^d | cut -c1