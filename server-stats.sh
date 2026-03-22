#!/usr/bin/env bash

echo "――――――――――――――――――――――――――――――――――――――――――――――――"
echo "            Server performance stats            "
echo "――――――――――――――――――――――――――――――――――――――――――――――――"

cpu_usage() {
	snapshot_one=$(head -n 1 /proc/stat)
	sleep 1
	snapshot_two=$(head -n 1 /proc/stat)

	read -a array_one <<< "$snapshot_one"
	read -a array_two <<< "$snapshot_two"
	
	sum_one=0
	sum_two=0

	for i in ${array_one[@]:1}; do 
		sum_one=$(( sum_one += i ));
	done

	for i in ${array_two[@]:1}; do
		sum_two=$(( sum_two += i ))
	done

	idle_one=${array_one[4]}
	idle_two=${array_two[4]}

	final_sum=$(( sum_two -= sum_one ))
	final_idle=$(( idle_two -= idle_one ))

	total_cpu=$(echo "scale=2; ($final_sum - $final_idle) * 100 / $final_sum" | bc)

	echo "> Total CPU usage: $total_cpu%"
}


mem_usage() {
	snapshot=$(head -n 3 /proc/meminfo)
	total_mem_kb=$(awk 'NR==1 { print $2 }' <<< "$snapshot")
	total_available_kb=$(awk 'NR==3 { print $2 }' <<< "$snapshot")
	total_used_kb=$((total_mem_kb - total_available_kb))

	total_mem_gb=$(echo "scale=2; ($total_mem_kb / 1024 / 1024)" | bc)
	available_mem_gb=$(echo "scale=2; ($total_available_kb / 1024 / 1024)" | bc)
	used_mem_gb=$(echo "scale=2; ($total_used_kb / 1024 / 1024)" | bc)
	
	available_mem_percentage=$(echo "scale=2; $available_mem_gb / $total_mem_gb * 100" | bc)
	used_mem_percentage=$(echo "scale=2; $used_mem_gb / $total_mem_gb * 100" | bc)

	echo "> Total memory: $total_mem_gb GB"
	echo "-- Free: $available_mem_gb GB ($available_mem_percentage%)"
	echo "-- Used: $used_mem_gb GB ($used_mem_percentage%)"
}

disk_usage() {
	snapshot=$(df / | awk 'NR==2 { print $2, $3, $4 }')
	
	read disk_size_kb used_disk_kb available_disk_kb <<< "$snapshot"

	total_disk_size_gb=$(echo "scale=2; $disk_size_kb / 1024 / 1024" | bc)
	used_disk_gb=$(echo "scale=2; $used_disk_kb / 1024 / 1024" | bc)	
	available_disk_gb=$(echo "scale=2; $available_disk_kb / 1024 / 1024" | bc)	
	
	available_disk_percentage=$(echo "scale=2; $available_disk_gb / $total_disk_size_gb * 100" | bc)
	used_disk_percentage=$(echo "scale=2; $used_disk_gb / $total_disk_size_gb * 100" | bc)

	echo "> Total disk size: $total_disk_size_gb GB"
	echo "-- Free: $available_disk_gb GB ($available_disk_percentage%)"
	echo "-- Used: $used_disk_gb GB ($used_disk_percentage%)"
}

t5_processes_by_cpu() {
	list=$(ps -eo pid,ppid,comm,%cpu --sort=-%cpu | head -n 6)
	
	echo "> Top 5 processes sorted by the CPU usage:"
	echo "――――――――――――――――――――――――――――――――――――――――――――――――"
	echo "$list"
	echo "――――――――――――――――――――――――――――――――――――――――――――――――"
}


t5_processes_by_mem() {
	list=$(ps -eo pid,ppid,comm,%mem --sort=-%mem | head -n 6)
	
	echo "> Top 5 processes sorted by the memory usage:"
	echo "――――――――――――――――――――――――――――――――――――――――――――――――"
	echo "$list"
	echo "――――――――――――――――――――――――――――――――――――――――――――――――"
}


main() {
	cpu_usage
	echo
	mem_usage
	echo	
	disk_usage
	echo	
	t5_processes_by_cpu
	echo
	t5_processes_by_mem
	echo
}

main
