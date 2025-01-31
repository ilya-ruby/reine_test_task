require_relative 'transaction'

class FileMerger
  MAX_OPEN_FILES = 256 # Ограничение на число одновременно открытых файлоd

  # MacOS: 256 по умолчанию
  # Linux: 1024

  def self.merge_sorted_chunks(chunk_files, output_file)
    File.open(output_file, 'w') do |output|
      chunk_groups = chunk_files.each_slice(MAX_OPEN_FILES).to_a

      chunk_groups.each do |group|
        merge_group(group, output)
        delete_temp_files(group) # Очистка временных файлов
      end
    end
  end

  private

  # Обрабатывает группу чанков (порция файлов, чтобы не превысить лимит)
  def self.merge_group(chunk_files, output)
    readers = open_files(chunk_files)
    heap = initialize_heap(readers)

    merge_heap(heap, readers, output)

    close_files(readers)
  end

  # Открывает файлы для чтения и возвращает массив File объектов
  def self.open_files(chunk_files)
    chunk_files.map { |file| File.open(file.path, 'r') }
  end

  # Закрывает все файлы
  def self.close_files(readers)
    readers.each(&:close)
  end

  # Удаляет временные файлы после обработки
  def self.delete_temp_files(chunk_files)
    chunk_files.each { |file| file.unlink }
  end

  # Инициализирует кучу из первой строки каждого файла
  def self.initialize_heap(readers)
    heap = []
    readers.each_with_index do |reader, index|
      line = reader.gets
      heap << [Transaction.new(line), index] if line
    end
    heap.sort_by! { |txn, _| -txn.amount }
    heap
  end

  # Основной цикл обработки данных из файлов (слияние кучей)
  def self.merge_heap(heap, readers, output)
    while heap.any?
      txn, index = heap.shift
      output.puts txn

      next_line = readers[index].gets
      heap << [Transaction.new(next_line), index] if next_line
      heap.sort_by! { |txn, _| -txn.amount }
    end
  end
end
