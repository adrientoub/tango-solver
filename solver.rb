$tango_size = 6
$line_size = $tango_size * 2 - 1

DEBUG = false

require_relative './helpers'

if $tango_size % 2 != 0 || $tango_size <= 2
  $stderr.puts "$tango_size must be an even number greater than 2"
  exit 1
end

if ARGV.size != 1
  $stderr.puts "Usage: ruby solver.rb <file>"
  exit 1
end

puts "Reading #{ARGV[0]}"

text = File.read(ARGV[0])
original_data = text.split("\n")
print_data(original_data, original_data)

if !validate_data(original_data)
  $stderr.puts "Invalid data cannot solve"
  exit 1
end

data = duplicate_puzzle(original_data)

if solve(data, original_data, nil)
  puts "Solution:"
  print_data(data, original_data)
  solved_grid = data

  data = duplicate_puzzle(original_data)

  if solve(data, original_data, solved_grid)
    puts "Not a valid tango: found a second solution:"
    print_data(data, solved_grid)
  end
else
  if data.join.include?('0')
    puts "Not a valid tango: No solution found"
    print_data(data, original_data)
    exit 1
  end
end
