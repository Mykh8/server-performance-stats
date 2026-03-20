#!/usr/bin/env bash

echo "――――――――――――――――――――――――――――――――――――――――"
echo "       Server performance stats         "
echo "――――――――――――――――――――――――――――――――――――――――"

total_cpu_usage() {
	snapshot_one=$(grep -i 'cpu' /proc/stat | head -n 1)
	sleep 1
	snapshot_two=$(grep -i 'cpu' /proc/stat | head -n 1)

	read -a array_one <<< "$snapshot_one"
	read -a array_two <<< "$snapshot_two"

	for i in ${array_one[@]:1}; do 
		sum_one=$(($sum_one + $i));
	done

	for i in ${array_two[@]:1}; do
		sum_two=$(($sum_two + $i))
	done

	idle_one=${array_one[4]}
	idle_two=${array_two[4]}

	final_sum=$(( $sum_two - $sum_one ))
	final_idle=$(( $idle_two - $idle_one ))

	total_cpu=$(echo "scale=2; ($final_sum - $final_idle) * 100 / $final_sum" | bc)

	echo "Total CPU usage: $total_cpu%"
}


total_mem_usage() {
	total_mem_kb=$(awk 'NR==1 { print $2 }' /proc/meminfo)
	total_available_kb=$(awk 'NR==3 { print $2 }' /proc/meminfo)
	total_used_kb=$(( total_mem_kb - total_available_kb ))

	total_mem_gb=$(echo "scale=2; ($total_mem_kb / 1024 / 1024)" | bc)
	total_available_gb=$(echo "scale=2; ($total_available_kb / 1024 / 1024)" | bc)
	total_used_gb=$(echo "scale=2; ($total_used_kb / 1024 / 1024)" | bc)

	echo "Total memory: $total_mem_gb GB"
	echo "- Free: $total_available_gb GB"
	echo "- Used: $total_used_gb GB"
}

main() {
	total_cpu_usage
	total_mem_usage
}

main
