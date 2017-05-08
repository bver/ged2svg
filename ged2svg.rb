#!/usr/bin/env ruby

require_relative 'parse_ged'
require_relative 'render_tree'

abort "Usage:\n #$0 file.ged" unless ARGV.size == 1

#people = parse_ged ARGV.first
#people.each_value {|p| puts p.birth; puts p.death }
#p people

people = { 
  'root' => Person.new('Wacslav', 'Ssuchmann', 'M', '1 JAN 1900', '1 JAN 2000'), 
  'wife' => Person.new('Catharina', 'Ssuchmann', 'F', nil, 'EST 1 JAN 1900'),
  'wife2' => Person.new('Ludmila', 'Ssuchmann', 'F', '1 JAN 2000', nil) 
}
#people['root'].add_family('wife', [])
#people['root'].add_family('wife2', [])

puts render_tree(people, 'root')




