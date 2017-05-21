
# (c) 2017 Pavel Suchmann <pavel@suchmann.cz>
# Licensed under the terms of the GNU GPL version 3 (or later)

require_relative 'person'

def parse_ged filename
  mode, given, surname, sex, birth, death, ref, bd = nil, nil, nil, nil, nil, nil, nil, nil
  husband, wife, children = nil, nil, [] 
  people = {
             '__?M?__' => Person.new('???', '', 'M', nil, nil),
             '__?F?__' => Person.new('???', '', 'F', nil, nil)
           }
  File.readlines(filename).each do |row|
    line = row.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
    level, token, *rest = line.chomp.split /\s+/
    rest = rest.join ' '
    level = level.to_i
 
    if level == 0
      case mode
      when :person
        people[ref] = Person.new(given, surname, sex, birth, death)
      when :family
        children.each do |child_ref| 
          child = people[child_ref]
          child.add_parent husband
          child.add_parent wife
        end
        unless husband.nil?
          wife = '__?F?__' if wife.nil?
          people[husband].add_family(wife, children)
        end
        unless wife.nil?
          husband = '__?M?__' if husband.nil?
          people[wife].add_family(husband, children) unless wife.nil?
        end
      end

      case rest
      when 'INDI'
        mode = :person
        given, surname, sex, birth, death, bd = nil, nil, nil, nil, nil, nil
      when 'FAM'
        mode = :family
        husband, wife, children = nil, nil, []
      else
        mode = nil
      end
      ref = token     
    else
      case token
      when 'GIVN'
        given = rest
      when 'SURN'
        surname = rest
      when 'SEX'
        sex = rest
      when 'BIRT'
        bd = :birth
        birth = nil
      when 'DEAT'
        bd = :death
        death = nil
      when 'DATE'
        case bd
        when :birth
          birth = rest if level == 2
        when :death
          death = rest if level == 2
        end
        bd = nil
      when 'HUSB'
        husband = rest
      when 'WIFE'
        wife = rest
      when 'CHIL'
        children << rest
      end
    end
  end
  people
end

