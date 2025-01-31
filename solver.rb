def print_data(data, original_data)
  data.each_with_index do |line, i|
    line.split('').each_with_index do |c, j|
      if c == original_data[i][j]
        print c
      else
        print "\e[31m#{c}\e[0m"
      end
    end
    puts
  end
end

def validate_line(line)
  if line.count('S') > 3
    return false
  elsif line.count('M') > 3
    return false
  elsif line.include?('SxS') || line.include?('MxM') || line.include?('S=M') || line.include?('M=S')
    return false
  elsif line.match?(/S.S.S/) || line.match?(/M.M.M/)
    return false
  end

  return true
end

def validate_data(data)
  if data.size != 11
    puts "Invalid data: only #{data.size} lines"
    return false
  end
  data.each do |line|
    if line.size != 11
      puts "Invalid data: line has #{line.size} characters"
      return false
    end
  end

  data.each do |line|
    if !validate_line(line)
      return false
    end
  end

  (0..5).each do |col_id|
    col = data.map { |line| line[col_id * 2] }.join
    if !validate_line(col)
      return false
    end
  end

  return true
end

puts "Reading #{ARGV[0]}"

text = File.read(ARGV[0])
original_data = text.split("\n")
print_data(original_data, original_data)

if !validate_data(original_data)
  $stderr.puts "Invalid data cannot solve"
  exit 1
end

data = original_data.map { |line| line.dup }

i = 0
j = 0

def next_data(original_data, i, j)
  while i < 11 && j < 11 && (original_data[i][j] == 'S' || original_data[i][j] == 'M')
    j += 2
    if j > 10
      j = 0
      i += 2
    end
  end

  if i == 12
    return nil, nil
  end

  return i, j
end

def prev_data(original_data, i, j)
  while i >= 0 && j >= 0 && (original_data[i][j] == 'S' || original_data[i][j] == 'M')
    j -= 2
    if j < 0
      j = 10
      i -= 2
    end
  end

  if i == -2
    return nil, nil
  end

  return i, j
end

def solve(data, original_data)
  i = 0
  j = 0
  loop do
    # skip already filled cells
    i, j = next_data(original_data, i, j)
    return true if i.nil?

    current_value = data[i][j]
    if current_value == '0'
      data[i][j] = 'S'
    elsif current_value == 'S'
      data[i][j] = 'M'
    elsif current_value == 'M'
      data[i][j] = '0'
      if i == 0 && j == 0
        puts "No solution"
        return false
      else
        # go back
        j -= 2
        if j < 0
          j = 10
          i -= 2
        end

        i, j = prev_data(original_data, i, j)
        if i.nil?
          puts "No solution"
          return false
        end
        next
      end
    end

    if validate_data(data)
      j += 2
      if j > 10
        j = 0
        i += 2
      end
    end
  end
end

if solve(data, original_data)
  puts "Solution:"
  print_data(data, original_data)
else
  if data.join.include?('0')
    puts "No solution found"
    print_data(data, original_data)
    exit 1
  end
end
