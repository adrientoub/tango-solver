$line_size = $tango_size * 2 - 1

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

def duplicate_puzzle(data)
  data.map { |line| line.dup }
end

def validate_line(line)
  if line.count('S') > $tango_size / 2
    return false
  elsif line.count('M') > $tango_size / 2
    return false
  elsif line.include?('SxS') || line.include?('MxM') || line.include?('S=M') || line.include?('M=S')
    return false
  elsif line.match?(/S.S.S/) || line.match?(/M.M.M/)
    return false
  end

  return true
end

def validate_data(data)
  if data.size != $line_size
    puts "Invalid data: #{data.size} lines instead of #{$line_size}"
    return false
  end
  data.each_with_index do |line, i|
    if line.size != $line_size
      puts "Invalid data: line #{i + 1} has #{line.size} characters instead of #{$line_size}"
      return false
    end
  end

  data.each do |line|
    if !validate_line(line)
      return false
    end
  end

  (0..$tango_size-1).each do |col_id|
    col = data.map { |line| line[col_id * 2] }.join
    if !validate_line(col)
      return false
    end
  end

  return true
end


def next_data(original_data, i, j)
  while i < $line_size && j < $line_size && (original_data[i][j] == 'S' || original_data[i][j] == 'M')
    j += 2
    if j >= $line_size
      j = 0
      i += 2
    end
  end

  if i > $line_size
    return nil, nil
  end

  return i, j
end

def prev_data(original_data, i, j)
  while i >= 0 && j >= 0 && (original_data[i][j] == 'S' || original_data[i][j] == 'M')
    j -= 2
    if j < 0
      j = $line_size - 1
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
          j = $line_size - 1
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
      if j >= $line_size
        j = 0
        i += 2
      end
    end
  end
end

def generate_puzzle(contraint_count)
  i = 0
  time = Time.now
  loop do
    i += 1
    puzzle = generate_puzzle_internal(contraint_count)
    if puzzle
      puts "Generated in #{i} tries (#{Time.now - time}s)"
      return puzzle
    end
  end
end

def generate_puzzle_internal(contraint_count)
  base_puzzle = Array.new($line_size) do |i|
    if i % 2 == 0
      Array.new($tango_size, '0').join('|')
    else
      Array.new($line_size, '-').join
    end
  end

  contraint_count.times do
    i, j = rand($line_size), rand($line_size)
    if i % 2 == 1 && j % 2 == 1
      # do not allow to change the horizontal lines
      redo
    elsif base_puzzle[i][j] == '0'
      base_puzzle[i][j] = rand(2) == 0 ? 'S' : 'M'
    elsif base_puzzle[i][j] == '-' || base_puzzle[i][j] == '|'
      base_puzzle[i][j] = rand(2) == 0 ? '=' : 'x'
    else
      # the cell is already filled
      redo
    end
  end
  data = duplicate_puzzle(base_puzzle)

  if solve(data, base_puzzle, nil)
    second_try = duplicate_puzzle(base_puzzle)

    if solve(second_try, base_puzzle, data)
      puts "Failed: found 2 solutions: trying again" if DEBUG
      return nil
    else
      puts "Generated a valid #{$tango_size}x#{$tango_size} Tango puzzle with #{contraint_count} constraints:"
      print_data(base_puzzle, base_puzzle)
      puts "Solution:"
      print_data(data, base_puzzle)
    end
  else
    puts "Failed: found 0 solution: trying again" if DEBUG
    return nil
  end
end
