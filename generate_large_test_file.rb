require 'securerandom'
require 'time'

# Файл, который будет создан
output_file = 'transactions_5gb.txt'

# Ожидаемый размер
target_size = 5 * 1024 * 1024 * 1024 # 5 ГБ
line_count = 0

start_time = Time.parse("2023-01-01T00:00:00Z")
end_time = Time.parse("2024-01-01T00:00:00Z")

File.open(output_file, 'w') do |file|
  while file.size < target_size
    timestamp = Time.at(rand(start_time.to_i..end_time.to_i)).utc.iso8601
    transaction_id = "txn#{SecureRandom.hex(8)}"
    user_id = "user#{rand(1..1_000_000)}"
    amount = rand(0.01..10_000.0).round(2)

    file.puts "#{timestamp},#{transaction_id},#{user_id},#{amount}"
    line_count += 1

    puts "Создано строк: #{line_count}, текущий размер: #{(file.size / (1024 * 1024.0)).round(2)} MB" if (line_count % 500_000).zero?
  end
end

puts "Файл #{output_file} успешно создан, размер: #{(File.size(output_file) / (1024 * 1024.0)).round(2)} MB"

