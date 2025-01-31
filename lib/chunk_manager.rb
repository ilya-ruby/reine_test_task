require 'tempfile'
require_relative 'transaction'

class ChunkManager
  CHUNK_SIZE = 100_000

  def self.split_and_sort_chunks(input_file)
    chunk_files = []
    chunk = []

    File.foreach(input_file) do |line|
      chunk << Transaction.new(line)
      
      if chunk.size >= CHUNK_SIZE
        chunk_files << write_sorted_chunk(chunk)
        chunk = []
      end
    end

    chunk_files << write_sorted_chunk(chunk) unless chunk.empty?
    chunk_files
  end

  def self.write_sorted_chunk(chunk)
    chunk.sort_by! { |txn| -txn.amount }
    file = Tempfile.new('chunk')

    chunk.each { |txn| file.puts(txn) }
    
    file.flush
    file.rewind
    file
  end
end

