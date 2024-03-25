#! /bin/bash

## Create the aggregate log file
datehr=$(date "+%Y%m%d%k")
hr="metrics_$datehr.log"
touch "$hr"
chmod 700 "$hr"
min=$1

echo "type,mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" >"$hr"

## Generate min, max, and avg
cat "$min" | awk 'BEGIN{FS=","; OFS=","} 
    NR>1{ min=$4;
        if ($4>=max) {smax=$0} 
        max=($4>max)?$4:max 

        if ($4<=min){smin=$0} 
        min=($4<min)?$4:min 
    }
    END {print "minimum", smax; print "maximum", smax }
' >>"$hr"
cat "$min" | awk -v usr="$USER" 'BEGIN{FS=","; OFS=","} 
    NR>1{ for(i = 1; i <= NF; i++) sum[i]+=$i } 
    END { print "average"; for(i = 1; i <= NF; i++) {
            if (i!=10)  {print sum[i]/(NR-1)} 
            else {print "/home/" usr}
        }
    }
' | paste -s -d "," >>"$hr"