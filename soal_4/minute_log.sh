#! /bin/bash

## Making directory required
cd ~; if [ ! -d log ] ;then 
    mkdir log
fi; cd log

## Making log file and its permission stat to user only
file="metrics_$(date "+%Y%m%d%k%M%S").log"
touch "$file"
chmod 700 "$file"

## Inserting header to log file
echo "mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" >"$file"

## Output log
{ free -m; du -sh ~;} | awk 'NR==2 {print $2","$3","$4","$5","$6","$7}
NR==3 {print $2","$3","$4}
NR==4 {print $2","$1}
' | paste -s -d ',' >> "$file" 

## Make a scheduled job for minute log
if [ -z $(crontab -lu $USER | grep minute_log.sh) ] ; then
    touch cronjobs
    echo "*/1 * * * * sh $(find /home/$USER -type f -name minute_log.sh)" > cronjobs

    ## The same but for hour log
    if [ -z $(crontab -lu $USER | grep aggregate_minutes_to_hourly_log.sh) ]; then
        echo "*/2 * * * * cd ~/log && sh $(find /home/$USER -type f -name aggregate_minutes_to_hourly_log.sh)" >> cronjobs
    fi

    crontab -u $USER cronjobs
    rm cronjobs
fi

## Cleanup script
## Execute this on the terminal if ur done w/ this script.
#crontab -lu $USER | grep -v log.sh | crontab -u $USER -

exit 0