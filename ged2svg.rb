#!/usr/bin/env ruby

require_relative 'parse_ged'

abort "Usage:\n #$0 file.ged" unless ARGV.size == 1

people = parse_ged ARGV.first
people.each_value {|p| puts p.birth; puts p.death }



