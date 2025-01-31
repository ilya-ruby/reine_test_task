require 'ruby-progressbar'
require_relative 'transaction'

class FileMerger
  MAX_OPEN_FILES = 256

  def self.merge_sorted_chunks(chunk_files, output_file)
    progress = ProgressBar.create(title: "Слияние файлов", total: chunk_files.size, format: "%t: |%B| %c/%C")

    File.open(output_file, 'w') do |output|
      chunk_groups = chunk_files.each_slice(MAX_OPEN_FILES).to_a

      chunk_groups.each do |group|
        merge_group(group, output, progress)
        delete_temp_files(group, progress)
      end
    end

    progress.finish
    puts "[#{Time.now.strftime('%H:%M:%S')}] Слияние завершено."
  end

  private

  def self.merge_group(chunk_files, output, progress)
    readers = open_files(chunk_files)
    heap = initialize_heap(readers)

    merge_heap(heap, readers, output)
    close_files(readers)

    # Обновляем прогресс после обработки всей группы файлов
    progress.increment(chunk_files.size)
  end

  def self.open_files(chunk_files)
    chunk_files.map { |file| File.open(file.path, 'r') }
  end

  def self.close_files(readers)
    readers.each(&:close)
  end

  def self.delete_temp_files(chunk_files, progress)
    chunk_files.each do |file|
      file.unlink
      progress.increment
    end
  end

  def self.initialize_heap(readers)
    heap = []
    readers.each_with_index do |reader, index|
      line = reader.gets
      heap << [Transaction.new(line), index] if line
    end
    heap.sort_by! { |txn, _| -txn.amount }
    heap
  end

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

