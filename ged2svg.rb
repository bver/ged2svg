#!/usr/bin/env ruby

require_relative 'parse_ged'
require_relative 'render_tree'

case ARGV.size
when 4
  root_ref, central_ref, file_ged, file_svg = ARGV
when 3
  root_ref, file_ged, file_svg = ARGV
else
  abort "Usage:\n #$0 root_ref [central_ref] file.ged file.svg"
end

people = parse_ged file_ged

trunk = central_ref.nil? ? [] : find_trunk(people, root_ref, central_ref)
#$stderr.puts trunk.join ' '

File.open(file_svg, 'w') {|f| f.puts render_tree(people, root_ref, trunk) }

