class Transaction
  attr_reader :timestamp, :transaction_id, :user_id, :amount

  def initialize(line)
    parts = line.strip.split(',')
    @timestamp = parts[0]
    @transaction_id = parts[1]
    @user_id = parts[2]
    @amount = parts[3].to_f
  end

  def to_s
    "#{@timestamp},#{@transaction_id},#{@user_id},#{@amount}"
  end
end
