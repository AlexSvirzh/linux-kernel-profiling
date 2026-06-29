#!/bin/bash

# Ожидание запуска процесса linpack
while [ -z "$(pidof linpack)" ]; do
    sleep 1
done

linpack_pid=$(pidof linpack)
my_pid=$$

while true; do
    for pid_path in /proc/[0-9]*; do
        pid=${pid_path#/proc/}
        
        # Пропускаем сам linpack и этот управляющий скрипт
        if [ "$pid" = "$linpack_pid" ] || [ "$pid" = "$my_pid" ]; then
            continue
        fi
        
        # Привязываем остальные процессы к ядрам 0-4 и 6-10
        sudo taskset -p -a --cpu-list 0-4,6-10 "$pid" 2>/dev/null
    done
    
    sleep 3
done
