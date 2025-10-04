FROM stupean/yandex-terraform:latest

# Копируем файлы из папки terraform в рабочую директорию контейнера
COPY terraform/ /app/

# Устанавливаем рабочую директорию
WORKDIR /app

# Скрипт запуска, который будет запрашивать переменные
COPY entrypoint.sh /entrypoint.sh

# Делаем скрипт точкой входа
ENTRYPOINT ["/entrypoint.sh"]