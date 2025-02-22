class WordBreaker
  # Инициализирует класс со словарем слов
  def initialize(dictionary)
    # Преобразуем массив словаря в Set для оптимизации поиска
    # Операция include? на множестве (Set) работает за O(1) в среднем случае,
    # в то время как для массива - O(n). Это ускоряет проверку принадлежности слова.
    @dictionary = dictionary.to_set
  end

  # Метод проверяет, можно ли разбить строку на слова из словаря
  def breakable?(s)
    # Используем динамическое программирование, создавая массив dp,
    # где dp[i] - true, если подстрока s[0...i] может быть разобрана
    dp = Array.new(s.length + 1, false)
    dp[0] = true
    
    # Перебираем все возможные окончания подстроки s[0...i]
    (1..s.length).each do |i|
      # Перебираем все возможные разбиения s[0...i], где j - точка разбиения
      (0...i).each do |j|
        # Проверяем, разборна ли подстрока s[0...j] и существует ли слово s[j...i] в словаре
        if dp[j] && @dictionary.include?(s[j...i])
          # Если условие выполняется, значит строка s[0...i] разборна
          dp[i] = true
          # Прерываем внутренний цикл, так как достаточно найти одно разбиение
          break
        end
      end
    end
    
    # Возвращаем, можно ли разобрать всю строку s
    dp[s.length]
  end
end

# Примеры использования
d = ["две", "сотни", "тысячи", "сто", "пятьдесят", "рублей", "долларов", "миллион", "двадцать", "три", "тысячи", "рублей"]
puts "Словарь: #{d.inspect}\n\n"
word_breaker = WordBreaker.new(d)

# Тестовые строки
test_cases = [
  "двесотни", # Ожидается true
  "двесотня", # Ожидается false
  "пятьдесятрублей", # Ожидается true
  "двадцатитритьысячирублей", # Ожидается true
  "стоодинрубль" # Ожидается false
]

# Вывод результатов
puts "Результаты проверки строк:\n\n" 
test_cases.each do |test|
  result = word_breaker.breakable?(test)
  puts "  \"#{test}\" -> #{result}"
end

