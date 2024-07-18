#!/bin/bash

# Функция для вывода сообщения об ошибке и завершения скрипта
function error_exit {
  echo "$1" 1>&2
  exit 1
}

# Проверка наличия аргументов
if [ $# -lt 5 ]; then
  error_exit "Usage: $0 <vmid> <name> <cpu> <memory> <disk_size>"
fi

# Получение аргументов
VMID=$1
NAME=$2
CPU=$3
MEMORY=$4
DISK_SIZE=$5

# Назначение хранилища и образа для установки ОС
STORAGE="hdd-share"  
ISO="hdd-share:ubuntu-24.04-live-server-amd64.iso"  

# Функция для выполнения команды и проверки на ошибку
function run_command {
  eval "$1"
  if [ $? -ne 0 ]; then
    error_exit "Error executing: $1"
  fi
}

# Создание VM
run_command "qm create $VMID --name $NAME --memory $MEMORY --cores $CPU --net0 virtio,bridge=vmbr0 --ostype l26"

# Добавление диска
run_command "qm set $VMID --scsihw virtio-scsi-single --scsi0 $STORAGE:${DISK_SIZE}G"

# Установка CD-ROM с образом ISO
run_command "qm set $VMID --ide2 $ISO,media=cdrom"

# Установка загрузочного устройства
run_command "qm set $VMID --boot c --bootdisk scsi0"

# Создание устройства серийного порта
run_command "qm set $VMID --serial0 socket"

# Установка графического интерфейса (VGA)
run_command "qm set $VMID --vga qxl"

# Установка Cloud-Init (опционально)
run_command "qm set $VMID --ciuser admin --cipassword adminpass"

# Запуск VM
run_command "qm start $VMID"

echo "VM with ID $VMID and name $NAME has been created and started."
