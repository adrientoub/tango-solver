DEBUG = false

if ARGV.size < 1 || ARGV[0].to_i <= 0 || (ARGV.size >= 2 && ARGV[1].to_i <= 3)
  $stderr.puts "Usage: ruby generator.rb <contraint_count> [tango_size (default = 6)]"
  exit 1
end

$tango_size = ARGV[1]&.to_i || 6

if $tango_size % 2 != 0 || $tango_size <= 2
  $stderr.puts "$tango_size must be an even number greater than 2"
  exit 1
end

require_relative './helpers'

contraint_count = ARGV[0].to_i
if contraint_count > $tango_size * $tango_size
  $stderr.puts "contraint_count must be lower than #{$tango_size * $tango_size}"
  exit 1
end

puts "Generating a tango with #{$tango_size}x#{$tango_size} grid and #{contraint_count} contraints"
generate_puzzle(contraint_count)
