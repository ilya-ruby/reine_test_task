require_relative '../lib/transaction'

RSpec.describe Transaction do
  let(:line) { "2023-09-03T12:45:00Z,txn1,user1,500.25" }
  let(:transaction) { Transaction.new(line) }

  it 'парсит строку корректно' do
    expect(transaction.timestamp).to eq("2023-09-03T12:45:00Z")
    expect(transaction.transaction_id).to eq("txn1")
    expect(transaction.user_id).to eq("user1")
    expect(transaction.amount).to eq(500.25)
  end
end
