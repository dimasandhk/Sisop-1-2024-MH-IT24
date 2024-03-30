#! /bin/bash

## Create the aggregate log file
time=$(date "+%Y%m%d%k")
file="metrics_$time.log"
touch "$file"
chmod 700 "$file"

# Add header to log
echo "type,mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" >"$file"

# Counting ammount of records for the awk cmd later
islog=$(ls | wc -l) 
nonlog=$(ls | grep -v -E metrics_${time}[0-9]{4} | wc -l)
records=$(($islog-$nonlog))

## Calculating and printing min, max, and avg to log file
cd ~/log && cat $(ls | grep -E metrics_${time}[0-9]{4} | paste -s -d " ") | awk -v n=$records 'BEGIN{FS=","; OFS=","}
    NR==2 { max=min=$4 }
    $1 !~ /[a-z]/ { 
        if ($4 >= max) { smax = $0; } 
        max = ($4 > max) ? $4 : max

        if ($4 <= min){ smin = $0; } 
        min = ($4 < min) ? $4 : min

        for(i = 1; i <= NF; i++) sum[i]+=$i
    }
    END { print "minimum", smin; print "maximum", smax ; print "average", sum[1]/n, sum[2]/n, sum[3]/n, sum[4]/n, sum[5]/n, sum[6]/n, sum[7]/n, sum[8]/n, sum[9]/n, $10, sum[11]/n "G"}
' >>"$file"

exit 0