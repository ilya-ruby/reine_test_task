require_relative '../lib/transaction_sorter'

RSpec.describe TransactionSorter do
  let(:input_file) { 'test_input.txt' }
  let(:output_file) { 'test_output.txt' }

  before do
    File.open(input_file, 'w') do |file|
      file.puts "2023-09-03T12:45:00Z,txn1,user1,500.25"
      file.puts "2023-09-03T12:46:00Z,txn2,user2,1000.50"
      file.puts "2023-09-03T12:47:00Z,txn3,user3,750.75"
    end
  end

  after do
    File.delete(input_file) if File.exist?(input_file)
    File.delete(output_file) if File.exist?(output_file)
  end

  it 'сортирует транзакции по amount в порядке убывания' do
    TransactionSorter.new(input_file, output_file).sort_transactions
    sorted_data = File.readlines(output_file).map(&:strip)

    expect(sorted_data).to eq([
      "2023-09-03T12:46:00Z,txn2,user2,1000.5",
      "2023-09-03T12:47:00Z,txn3,user3,750.75",
      "2023-09-03T12:45:00Z,txn1,user1,500.25"
    ])
  end
end

