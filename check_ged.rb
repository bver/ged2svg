#!/usr/bin/env ruby

# (c) 2021 Pavel Suchmann <pavel@suchmann.cz>
# Licensed under the terms of the GNU GPL version 3 (or later)

require 'set'
require_relative 'parse_ged'

TOO_OLD_FOR_CHILDREN = 65

abort "Usage:\n #$0 file.ged" unless ARGV.size == 1
file_ged = ARGV.first

people = parse_ged file_ged
puts "checking consistencies (parent/child birth/death dates, marriage dates)"

people.each_pair do |id, person|
  next if person.birth_range.nil?
  puts "inconsistent: person #{person.name} born #{person.birth} after death #{person.death}" if person.birth_range.after person.death_range
  person.parents.each do |parent_id|
    parent = people[parent_id]
    raise "id #{parent_id} not found" if parent.nil?
    puts "warning: child #{person.name} born #{person.birth} after parent #{parent.name} death #{parent.death}" if person.birth_range.after parent.death_range
    puts "inconsistent: child #{person.name} born #{person.birth} before parent #{parent.name} birth #{parent.birth}" if person.birth_range.before parent.birth_range
    next if parent.birth_range.nil?
    parent_too_old = parent.birth_range.add_years TOO_OLD_FOR_CHILDREN
    puts "warning: parent #{parent.name} too old (>=#{TOO_OLD_FOR_CHILDREN}) when #{person.name} was born" if person.birth_range.after parent_too_old
  end
  person.marriages.each_value do |marriage|
    text, range = marriage
    next if range.nil? or person.birth_range.nil?
    puts "inconsistent: marriage of #{person.name} at #{text} before birth #{person.birth}" if range.before person.birth_range
    next if person.death_range.nil?
    puts "inconsistent: marriage of #{person.name} at #{text} after death #{person.death}" if range.after person.death_range
  end
  person.families.each_value do |children|
    names = children.map { |child| people[child].given }
    s = Set.new
    duplicates = names.find { |name| !s.add? name }
    puts "warning: person #{person.name} born #{person.birth} has more children named #{duplicates}" if duplicates
  end
end
