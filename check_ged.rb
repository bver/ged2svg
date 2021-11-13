#!/usr/bin/env ruby

# (c) 2017 Pavel Suchmann <pavel@suchmann.cz>
# Licensed under the terms of the GNU GPL version 3 (or later)

require_relative 'parse_ged'

abort "Usage:\n #$0 file.ged" unless ARGV.size == 1
file_ged = ARGV.first

people = parse_ged file_ged

people.each_pair do |id, person|
  person.parents.each do |parent_id|
    parent = people[parent_id]
    raise "id #{parent_id} not found" if parent.nil?
    next if parent.death_range.nil? or person.birth_range.nil?
    puts "child #{person.name} born #{person.birth} after parent #{parent.name} death #{parent.death}" if person.birth_range.after(parent.death_range)
    puts "child #{person.name} born #{person.birth} before parent #{parent.name} birth #{parent.birth}" if person.birth_range.before(parent.birth_range)
  end
  person.marriages.each_value do |marriage|
    text, range = marriage
    next if range.nil? or person.birth_range.nil?
    puts "marriage of #{person.name} at #{text} before birth #{person.birth}" if range.before(person.birth_range)
    next if person.death_range.nil?
    puts "marriage of #{person.name} at #{text} after death #{person.death}" if range.after(person.death_range)
  end
end
