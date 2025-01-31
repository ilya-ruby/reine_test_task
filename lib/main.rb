require_relative 'transaction_sorter'

input_file = ARGV[0] || 'transactions.txt'
output_file = ARGV[1] || 'sorted_transactions.txt'

TransactionSorter.new(input_file, output_file).sort_transactions

puts "Файл отсортирован и сохранён в #{output_file}"

