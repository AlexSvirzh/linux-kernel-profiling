#!/bin/bash
FILESYSTEMS="ext4 xfs btrfs f2fs"
DISK_IMAGE="test_disk.img"
DISK_SIZE="2G"
MOUNT_POINT="/mnt/fstester"
NUM_FILES=10000
RESULTS_FILE="results.csv"

if [[ $EUID -ne 0 ]]; then
    echo "Need sudo."
    exit 1
fi

echo "Начинаем тестирование файловых систем..."
echo "filesystem,create_time_sec,list_time_sec,delete_time_sec" > "$RESULTS_FILE"

for fs in $FILESYSTEMS; do
    echo "Тестирование $fs;"
    echo "Создание образа диска $DISK_IMAGE размером $DISK_SIZE..."
    rm -f "$DISK_IMAGE"
    fallocate -l "$DISK_SIZE" "$DISK_IMAGE"

    echo "Форматирование в $fs;"
    case "$fs" in
        ext4)
            mkfs.ext4 -F "$DISK_IMAGE" &>/dev/null
            ;;
        xfs)
            mkfs.xfs -f "$DISK_IMAGE" &>/dev/null
            ;;
        btrfs)
            mkfs.btrfs -f "$DISK_IMAGE" &>/dev/null
            ;;
        f2fs)
            mkfs.f2fs -f "$DISK_IMAGE" &>/dev/null
            ;;
        *)
            echo "Неизвестная файловая система: $fs. Skip"
            continue
            ;;
    esac

    mkdir -p "$MOUNT_POINT"
    mount -o loop "$DISK_IMAGE" "$MOUNT_POINT"

    echo "Выполнение тестов ($NUM_FILES файлов);"

    # Измерение времени создания файлов
    CREATE_TIME=$( (time -p for i in $(seq 1 "$NUM_FILES"); do touch "$MOUNT_POINT/file$i"; done) 2>&1 | grep real | awk '{print $2}' )
    echo "Время создания: $CREATE_TIME секунд."

    # Измерение времени листинга
    LIST_TIME=$( (time -p ls -lR "$MOUNT_POINT" > /dev/null) 2>&1 | grep real | awk '{print $2}' )
    echo "Время листинга: $LIST_TIME секунд."

    # Измерение времени удаления
    DELETE_TIME=$( (time -p rm -rf "$MOUNT_POINT"/*) 2>&1 | grep real | awk '{print $2}' )
    echo "Время удаления: $DELETE_TIME секунд."

    echo "$fs,$CREATE_TIME,$LIST_TIME,$DELETE_TIME" >> "$RESULTS_FILE"

    umount "$MOUNT_POINT"
    echo "Тестирование $fs завершено."
    echo ""
done

rm -f "$DISK_IMAGE"
rmdir "$MOUNT_POINT"
echo "End."
