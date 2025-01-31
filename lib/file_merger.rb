require 'ruby-progressbar'
require_relative 'transaction'
require_relative 'config'  # Подключаем конфиг

class FileMerger
  def self.merge_sorted_chunks(chunk_files, output_file)
    progress = ProgressBar.create(title: "Слияние файлов", total: chunk_files.size, format: PROGRESS_FORMAT)

    File.open(output_file, 'w') do |output|
      chunk_groups = chunk_files.each_slice(MAX_OPEN_FILES).to_a

      chunk_groups.each do |group|
        merge_group(group, output, progress)
        delete_temp_files(group)
      end
    end

    progress.finish unless progress.finished?
    puts "[#{Time.now.strftime('%H:%M:%S')}] Слияние завершено."
  end

  private

  def self.merge_group(chunk_files, output, progress)
    readers = open_files(chunk_files)
    heap = initialize_heap(readers)

    merge_heap(heap, readers, output, progress)
    close_files(readers)

    chunk_files.size.times { progress.increment unless progress.finished? }
  end

  def self.open_files(chunk_files)
    chunk_files.map { |file| File.open(file.path, 'r') }
  end

  def self.close_files(readers)
    readers.each(&:close)
  end

  def self.delete_temp_files(chunk_files)
    chunk_files.each(&:unlink)
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

  def self.merge_heap(heap, readers, output, progress)
    buffer = []
    total_lines = 0

    while heap.any?
      txn, index = heap.shift
      buffer << txn.to_s
      total_lines += 1

      if buffer.size >= BUFFER_SIZE
        output.write(buffer.join("\n") + "\n")
        buffer.clear
      end

      next_line = readers[index].gets
      heap << [Transaction.new(next_line), index] if next_line
      heap.sort_by! { |txn, _| -txn.amount }

      progress.increment if (total_lines % 10_000).zero? && !progress.finished?
    end

    output.write(buffer.join("\n") + "\n") unless buffer.empty?
  end
end

