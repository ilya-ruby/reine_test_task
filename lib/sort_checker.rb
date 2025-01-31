# sort_checker.rb
require_relative 'transaction'
require_relative 'config'

class SortChecker
  def self.file_sorted?(file_path)
    previous_amount = Float::INFINITY  # Начинаем с максимального значения

    File.open(file_path, 'r') do |file|
      file.each_slice(BUFFER_SIZE) do |lines|  # Читаем блоками по BUFFER_SIZE
        transactions = lines.map { |line| Transaction.new(line) }

        transactions.each do |txn|
          if txn.amount > previous_amount  # Если порядок нарушен
            puts "Файл не отсортирован!"
            return false
          end
          previous_amount = txn.amount
        end
      end
    end

    puts "Файл отсортирован!"
    true
  end
end

if __FILE__ == $0
  file_path = ARGV[0] || 'transactions.txt'
  SortChecker.file_sorted?(file_path)
end

