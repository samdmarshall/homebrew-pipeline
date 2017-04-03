require 'digest'
require 'claide'
require 'octokit'

args = CLAide::ARGV.new(ARGV)

command = args.shift_arguments

case command
when 'new'
  puts 'creating a new formula!'
when 'update'
  puts 'updating an existing formula!'
else
  puts 'Invalid command issued!'
