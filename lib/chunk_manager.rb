require 'tempfile'
require 'ruby-progressbar'
require_relative 'transaction'
require_relative 'config'  # Подключаем конфиг

class ChunkManager
  def self.split_and_sort_chunks(input_file)
    chunk_files = []
    chunk = Array.new(CHUNK_SIZE) # Оптимизированный массив фиксированного размера
    index = 0

    progress = ProgressBar.create(title: "Создание чанков", total: nil, format: PROGRESS_FORMAT)

    File.open(input_file, 'r') do |file|
      file.each_line do |line|
        chunk[index] = Transaction.new(line)
        index += 1

        if index >= CHUNK_SIZE
          chunk_files << write_sorted_chunk(chunk, index)
          index = 0
          progress.increment
        end
      end
    end

    chunk_files << write_sorted_chunk(chunk, index) if index > 0
    progress.finish

    puts "[#{Time.now.strftime('%H:%M:%S')}] Создано #{chunk_files.size} чанков."
    chunk_files
  end

  private

  def self.write_sorted_chunk(chunk, size)
    chunk = chunk[0...size]
    chunk.sort_by! { |txn| -txn.amount }

    file = Tempfile.new(['chunk', '.txt'], binmode: true)
    file.write(chunk.map(&:to_s).join("\n"))
    file.flush
    file.rewind
    file
  end
end

