#!/usr/bin/env ruby

# (c) 2021 Pavel Suchmann <pavel@suchmann.cz>
# Licensed under the terms of the GNU GPL version 3 (or later)

require 'set'
require_relative 'parse_ged'

abort "Usage:\n #$0 file.ged 'query string'" unless ARGV.size == 2
file_ged, query = ARGV

people = parse_ged file_ged
puts "finding '#{query}' in person 'GIVEN SURNAME' or in 'INDI'"

def format_dates person
  if person.birth
    person.death ? "[ #{person.birth} -- #{person.death} ]" : "* #{person.birth}"
  else
    person.death ? "+ #{person.death}" : ""
  end
end

people.each_pair do |id, person|
  next unless person.name.include?(query) or id.include?(query)
  puts "\n* given: '#{person.given}' surname: '#{person.surname}' INDI: #{id}"
  puts "  birth date: #{person.birth}" if person.birth
  puts "  death date: #{person.death}" if person.death
  person.families.each_pair do |spouse_id, children|
    spouse = people[spouse_id]
    puts "  spouse: #{spouse.name} #{format_dates spouse} INDI: #{spouse_id}"
    puts "  mariage: #{person.marriages[spouse_id].first}" if person.marriages.key? spouse_id
    children.each do |child_id|
      child = people[child_id]
      puts "    child: #{child.name} #{format_dates child} INDI: #{child_id}"
    end
  end
end
