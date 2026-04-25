#!/bin/bash

for i in `seq 1 10`
do
        PER=$(expr $i \* 10)
        echo -ne "$PER% |"
					
        START=1
        while [ $START -le $i ]
        do
                echo -ne "=="
                START=`expr $START + 1`
        done
					
        if [ $i -ne 10 ] ; then
                echo -ne ">"
        else
                echo -ne "| \"Complete !!!\"\n"
        fi
					
        echo -ne "\r" 		 # "\n"은  다음줄    /   "\r"은  처음으로 repeat
					        
		sleep 0.5
done

