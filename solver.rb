TANGO_SIZE = 6
LINE_SIZE = TANGO_SIZE * 2 - 1

if TANGO_SIZE % 2 != 0 || TANGO_SIZE <= 2
  $stderr.puts "TANGO_SIZE must be an even number greater than 2"
  exit 1
end

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
  if line.count('S') > TANGO_SIZE / 2
    return false
  elsif line.count('M') > TANGO_SIZE / 2
    return false
  elsif line.include?('SxS') || line.include?('MxM') || line.include?('S=M') || line.include?('M=S')
    return false
  elsif line.match?(/S.S.S/) || line.match?(/M.M.M/)
    return false
  end

  return true
end

def validate_data(data)
  if data.size != LINE_SIZE
    puts "Invalid data: #{data.size} lines instead of #{LINE_SIZE}"
    return false
  end
  data.each_with_index do |line, i|
    if line.size != LINE_SIZE
      puts "Invalid data: line #{i + 1} has #{line.size} characters instead of #{LINE_SIZE}"
      return false
    end
  end

  data.each do |line|
    if !validate_line(line)
      return false
    end
  end

  (0..TANGO_SIZE-1).each do |col_id|
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

def next_data(original_data, i, j)
  while i < LINE_SIZE && j < LINE_SIZE && (original_data[i][j] == 'S' || original_data[i][j] == 'M')
    j += 2
    if j >= LINE_SIZE
      j = 0
      i += 2
    end
  end

  if i > LINE_SIZE
    return nil, nil
  end

  return i, j
end

def prev_data(original_data, i, j)
  while i >= 0 && j >= 0 && (original_data[i][j] == 'S' || original_data[i][j] == 'M')
    j -= 2
    if j < 0
      j = LINE_SIZE - 1
      i -= 2
    end
  end

  if i == -2
    return nil, nil
  end

  return i, j
end

def solve(data, original_data, solved_grid)
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
        return false
      else
        # go back
        j -= 2
        if j < 0
          j = LINE_SIZE - 1
          i -= 2
        end

        i, j = prev_data(original_data, i, j)
        if i.nil?
          return false
        end
        next
      end
    end

    if validate_data(data) && (solved_grid.nil? || data != solved_grid)
      j += 2
      if j >= LINE_SIZE
        j = 0
        i += 2
      end
    end
  end
end

if solve(data, original_data, nil)
  puts "Solution:"
  print_data(data, original_data)
  solved_grid = data

  data = original_data.map { |line| line.dup }

  if solve(data, original_data, solved_grid)
    puts "Found a second solution:"
    print_data(data, solved_grid)
  else
    puts "The solution is unique"
  end
else
  if data.join.include?('0')
    puts "No solution found"
    print_data(data, original_data)
    exit 1
  end
end
