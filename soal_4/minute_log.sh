#! /bin/bash

## Making the log file and dir required
cd ~; if [! -d log] ;then mkdir log ; fi; cd log
date=$(date "+%Y%m%d%k%M%S")
min="metrics_$date.log"
touch "$min"
chmod 700 "$min"

## Header of log file
echo "mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" >"$min"

## Runs on infinite loop
while true ; do
    ## Output log for every minute loop
    { free -m; du -sh ~;} | awk 'NR==2 {print $2","$3","$4","$5","$6","$7}
    NR==3 {print $2","$3","$4}
    NR==4 {print $2","$1}
    ' | paste -s -d ',' >> "$min" 
    #paste : combine all output lines into one and seperated by commas ","
        
    ## Adding 'i' counter every minute
    i=$(($i+1))
    sleep 60

    ## Create aggregate log file every hour
    if [ $(($i % 60)) -eq 0 ] ; then
        sh aggregate_minutes_to_hourly_log.sh "$min"
    fi
done