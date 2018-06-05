
#!/bin/bash

#check if queue is empty
c=""
s=$( squeue -n timer | awk 'NR > 1 {print $1}')
if  [[ $s == $c ]];
then

        #check if data has been removed correctly
        for f in data.*;
        do
                if [ -e $f ]
                then
                        rm $f
                        echo $f" has been removed"
                fi
        done

        #check for source file and compile timer
        if [ -e timer.c ]
        then
                echo "compiling timer"
                cc timer.c -o timer
                echo "timer is ready"
        else
                echo "source file is missing"
        fi

        #run timer
        srun -C gpu -N 2 -n 2 timer

        #finish transcription, make directory for data
        nid=$( sacct --name timer -o nodelist | awk 'END{print}')
        timestamp=$(date|tr "  " . | tr " " .)
        echo "data_"$timestamp"_"$nid >> data.EV
        echo "" >> data.EV
        echo "" >> data.EV
        mkdir "data_"$timestamp"_"$nid

        #cp data and remove from home directory
        cp data.* "data_"$timestamp"_"$nid
        echo "data has been generated and copied to data_"$timestamp"_"$nid
        for f in data.*;
        do
                if [ -e $f ]
                then
                        rm $f
                        echo $f" has been removed"
                fi
        done
        echo "all done"
else
        #don't execute if timer is already in queue
        echo "there is still a timer in the queue"
        echo "job has not been run"
fi
