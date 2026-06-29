#!/bin/bash
MOUNT_POINT="/mnt/pifs"
METADATA_DIR="/tmp/pifs_meta"

if [[ $EUID -ne 0 ]]; then
    echo "Ошибка sudo."
    exit 1
fi

if ! command -v pifs &> /dev/null; then
    echo "Ошибка: PIFS не установлен."
    exit 1
fi

echo "Предварительная очистка..."
umount "$MOUNT_POINT" &>/dev/null
rm -rf "$MOUNT_POINT"
rm -rf "$METADATA_DIR"

echo "Создание точек монтирования..."
mkdir -p "$MOUNT_POINT"
mkdir -p "$METADATA_DIR"

pifs -o mdd="$METADATA_DIR" "$MOUNT_POINT"
sleep 1

if ! mountpoint -q "$MOUNT_POINT"; then
    echo "КРИТИЧЕСКАЯ ОШИБКА: Не удалось смонтировать PIFS."
    rm -rf "$MOUNT_POINT"
    rm -rf "$METADATA_DIR"
    exit 1
fi

echo "PIFS успешно смонтирована."
echo "Создание тестового файла 'hello.txt'..."
echo "Hello! This is a test file for the PIFS concept." > hello.txt
TEST_FILE_PATH="$MOUNT_POINT/hello.txt"

# Замеры времени операций
WRITE_TIME=$( (time -p cp hello.txt "$TEST_FILE_PATH") 2>&1 | grep real | awk '{print $2}' )
LIST_TIME=$( (time -p ls -l "$TEST_FILE_PATH" > /dev/null) 2>&1 | grep real | awk '{print $2}' )
DELETE_TIME=$( (time -p rm "$TEST_FILE_PATH") 2>&1 | grep real | awk '{print $2}' )

echo ""
echo "Время 'записи' файла: $WRITE_TIME секунд"
echo "Время чтения метаданных (ls -l): $LIST_TIME секунд"
echo "Время удаления файла: $DELETE_TIME секунд"
echo ""

ORIGINAL_SIZE=$(stat -c%s "hello.txt")
META_SIZE=$(du -sb "$METADATA_DIR" | awk '{print $1}')

echo "Размер исходного файла: $ORIGINAL_SIZE байт"
echo "Реальное место, занятое на диске: $META_SIZE байт"
echo ""

umount "$MOUNT_POINT"
rm -rf "$MOUNT_POINT"
rm -rf "$METADATA_DIR"
rm -f hello.txt
echo "End."
