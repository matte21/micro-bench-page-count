#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

gcc ubench.c -o ubench
chmod +x ubench

declare -A footprint_to_num_pages=()
footprint_to_num_pages["10 MiB"]=2560
footprint_to_num_pages["1 GiB"]=262144
footprint_to_num_pages["10 GiB"]=2621440
footprint_to_num_pages["50 GiB"]=13107200

declare -a footprints=(
    "10 MiB"
    "1 GiB"
    "10 GiB"
    "50 GiB"
)

readonly raw_file="raw_data_seconds.csv"
echo "10 MiB, 1 GiB, 10 GiB, 50 GiB," > $raw_file

for i in {1..1000}; do
    row=""
    for footprint in "${footprints[@]}"; do
        latency_secs=$(./ubench ${footprint_to_num_pages["$footprint"]} | grep Elapsed | cut -d ' ' -f 3)
        row+="$latency_secs,"
    done
    echo $row >> $raw_file

    if (( i % 250 == 0 )); then
        echo "Done $i/4 of iterations."
    fi
done

readonly avg_file="cgrps_lat_ubench_avg_usecs.csv"
echo "10 MiB, 1 GiB, 10 GiB, 50 GiB," > $avg_file

avg_row=""
for i in {1..4}; do
    avg=$(tail -n +2 $raw_file | \
        cut -d ',' -f $i | \
        awk '{ sum += $1; count++ } END { if (count>0) printf "%.6f\n", 1000000*(sum/count); else print "No data"; }')
    avg_row+="$avg,"
done
echo $avg_row >> $avg_file

# Compute and print standard deviations on new lines
readonly stddev_file="cgrps_lat_ubench_stddev_usecs.csv"
echo "10 MiB, 1 GiB, 10 GiB, 50 GiB," > $stddev_file

stddev_row=""
for i in {1..4}; do
    stddev=$(tail -n +2 $raw_file | \
        cut -d ',' -f $i | \
        awk '{
            x = $1; sum += x; sumsq += x*x; count++
        }
        END {
            if (count>0) {
                mean = sum/count
                var = (sumsq/count) - (mean*mean)
                if (var < 0) var = 0
                printf "%.6f", sqrt(var) * 1000000
            } else {
                printf "No data"
            }
        }')
    stddev_row+="$stddev,"
done
echo $stddev_row >> $stddev_file
