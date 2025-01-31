require_relative 'chunk_manager'
require_relative 'file_merger'

class TransactionSorter
  def initialize(input_file, output_file)
    @input_file = input_file
    @output_file = output_file
  end

  def sort_transactions
    chunk_files = ChunkManager.split_and_sort_chunks(@input_file)
    FileMerger.merge_sorted_chunks(chunk_files, @output_file)
  end
end

