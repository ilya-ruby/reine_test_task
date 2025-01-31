require 'tempfile'
require 'ruby-progressbar'
require_relative 'transaction'

class ChunkManager
  CHUNK_SIZE = 500_000

  def self.split_and_sort_chunks(input_file)
    chunk_files = []
    chunk = []
    chunk_count = 0
    progress = ProgressBar.create(title: "Создание чанков", total: nil, format: "%t: |%B| %c чанков")

    File.foreach(input_file) do |line|
      chunk << Transaction.new(line)

      if chunk.size >= CHUNK_SIZE
        chunk_files << write_sorted_chunk(chunk)
        chunk_count += 1
        chunk.clear
        progress.increment
      end
    end

    unless chunk.empty?
      chunk_files << write_sorted_chunk(chunk)
      chunk_count += 1
      progress.increment
    end

    progress.finish
    puts "[#{Time.now.strftime('%H:%M:%S')}] Создано #{chunk_count} чанков."
    chunk_files # Возвращаем список временных файлов
  end

  private

  def self.write_sorted_chunk(chunk)
    chunk.sort_by! { |txn| -txn.amount }
    file = Tempfile.new(['chunk', '.txt'])
    chunk.each { |txn| file.puts(txn) }
    file.flush
    file.rewind
    file
  end
end

