#!/bin/bash
DISC="nvme0n1"
TEST_FILE="testfile.bin"
LOG_FILE="io_test_results.log"

if [ "$EUID" -ne 0 ]; then
    echo "need sudo"
    exit 1
fi

SCHEDULERS=$(cat /sys/block/$DISC/queue/scheduler | sed 's/\[//g' | sed 's/\]//g')
> $LOG_FILE

echo "Начинаем тестирование диска $DISC" | tee -a $LOG_FILE
echo "Планировщики для теста: $SCHEDULERS" | tee -a $LOG_FILE
echo "----------------------------------" | tee -a $LOG_FILE

# Функция очистки кэша
clear_caches() {
    sync
    echo 3 > /proc/sys/vm/drop_caches
    hdparm -F /dev/$DISC > /dev/null 2>&1
    sleep 3
}

for S in $SCHEDULERS; do
    echo "Тестируем планировщик: [$S]" | tee -a $LOG_FILE
    echo $S > /sys/block/$DISC/queue/scheduler

    clear_caches
    echo "[Тест 1] Последовательное чтение (dd):" | tee -a $LOG_FILE
    dd if=$TEST_FILE of=/dev/null bs=1M status=progress 2>&1 | tee -a $LOG_FILE

    clear_caches
    echo "[Тест 2] Последовательная запись (dd):" | tee -a $LOG_FILE
    dd if=/dev/zero of=$TEST_FILE bs=1M count=1024 status=progress 2>&1 | tee -a $LOG_FILE

    clear_caches
    echo "[Тест 3] Случайное чтение:" | tee -a $LOG_FILE
    ./random_read_test | tee -a $LOG_FILE

    clear_caches
    echo "[Тест 4] Случайное чтение под нагрузкой (конкурентная запись):" | tee -a $LOG_FILE
    ionice -c 3 dd if=/dev/urandom of=write_load.tmp bs=4k count=100000 status=none &
    DD_PID=$!

    ionice -c 1 -n 0 ./random_read_test | tee -a $LOG_FILE
    kill $DD_PID > /dev/null 2>&1
    wait $DD_PID 2>/dev/null
    rm -f write_load.tmp

    echo "" | tee -a $LOG_FILE
done

echo "Тестирование завершено. Результаты сохранены в файле $LOG_FILE"
