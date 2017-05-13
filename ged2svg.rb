#!/usr/bin/env ruby

require_relative 'parse_ged'
require_relative 'render_tree'

abort "Usage:\n #$0 file.ged" unless ARGV.size == 2
filename, root_ref = ARGV

people = parse_ged filename
#people.each_value {|p| puts p.birth; puts p.death }
#p people


#people = { 
#  'root' => Person.new('Wacslav', 'Ssuchmann', 'M', '1 JAN 1900', '1 JAN 2000'), 
#  'wife' => Person.new('Catharina', 'Ssuchmann', 'F', nil, 'EST 1 JAN 1900'),
#  'wife2' => Person.new('Ludmila', 'Ssuchmann', 'F', '1 JAN 2000', nil),

#  'ch1' => Person.new('Alice', 'Ssuchmann', 'F', nil, nil), 
#  'ch2' => Person.new('Bohous', 'Ssuchmann', 'M', nil, nil),
#  'ch3' => Person.new('Cilka', 'Ssuchmann', 'F', nil, nil)
#}
#people['root'].add_family('wife2', ['ch1', 'ch2', 'ch2', 'ch1'])
#people['root'].add_family('wife', ['ch3', 'ch1', 'ch2'])


puts render_tree(people, root_ref)




