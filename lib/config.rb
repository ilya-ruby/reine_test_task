# --- Разбиение входного файла на чанки ---
CHUNK_SIZE = 500_000 # Количество строк в одном чанке

# --- Ограничение на количество одновременно открытых файлов ---
MAX_OPEN_FILES = 256  # Обычно 256 на macOS, 1024+ на Linux, можно изменить

# --- Размер буфера для записи в выходной файл ---
BUFFER_SIZE = 10_000  # Запись каждые 10 000 строк

# --- Настройки прогресс-бара ---
PROGRESS_FORMAT = "%t: |%B| %c/%C (ETA: %E)"  # Формат для ruby-progressbar

