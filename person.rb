
# (c) 2017 Pavel Suchmann <pavel@suchmann.cz>
# Licensed under the terms of the GNU GPL version 3 (or later)

require 'date'

DateRange = Struct.new(:from, :to) do # <from, to)
  def to_s
    return "?" if from.nil? and to.nil?
    return from.to_s if from and from.next_day() == to
    "#{from}-#{to}"
  end
  def after other
    return false if other.nil? or self.to.nil? or other.from.nil?
    (self.to <=> other.from) == 1  # -1 <, 1 >
  end
  def before other
    return false if other.nil? or self.from.nil? or other.to.nil?
    (self.from <=> other.to) == -1  # -1 <, 1 >
  end
end

class Person
  attr_reader :name, :sex, :birth, :death, :families, :parents, :given, :surname, :birth_range, :death_range, :marriages

  def initialize(given, surname, sex, birth, death)
    @given = given
    @surname = surname
    @name = given.nil? ? '' : given
    @name = surname.nil? ? @name : "#{@name} #{surname}"
    @sex = (sex == 'M') ? :male : :female
    @birth, @birth_range = Person.parse_date birth
    @death, @death_range = Person.parse_date death
    @families = {}
    @parents = []
    @marriages = {}
  end

  def add_parent parent_ref
    @parents << parent_ref unless parent_ref.nil?
  end

  def add_family(spouse_ref, children_refs, marriage)
    raise 'unknown spouse' if spouse_ref.nil?
    @families[spouse_ref] = children_refs.clone unless spouse_ref.nil?
    @marriages[spouse_ref] = Person.parse_date marriage  # [text, DateRange]
  end

  def spouses
    @families.keys
  end

  def children spouse_ref=nil
    spouse_ref.nil? ? @families.values.flatten : @families[spouse_ref]
  end

  def lifespan
    if @birth.nil?
      @death.nil? ? '' : "+ #{@death}"
    else
      @death.nil? ? "#{@birth}" : "#{@birth} - #{@death}"
    end
  end

  @@months = { 'JAN'=>1, 'FEB'=>2, 'MAR'=>3, 'APR'=>4, 'MAY'=>5, 'JUN'=>6,
               'JUL'=>7, 'AUG'=>8, 'SEP'=>9, 'OCT'=>10, 'NOV'=>11, 'DEC'=>12 }
  @@pref = { 'ABT' => '~', 'EST' => '~', 'BEF' => '<', 'AFT' => '>' }
  def self.parse_date date
    return [ nil, nil ] if date.nil?
    tokens = date.split /\s+/
    raise "BET date range not supported: '#{date}'" if tokens.first == 'BET'
    case tokens.size
    when 4
      # ABT 1 JAN 1970
      return nil, nil unless @@pref.key? tokens.first
      date = Date.new(tokens.last.to_i, @@months[tokens[2]], tokens[1].to_i)
      range = case tokens.first
      when 'ABT', 'EST'
        DateRange.new(date, date)
      when 'BEF'
        DateRange.new(nil, date)
      when 'AFT'
        DateRange.new(date, nil)
      end
      return [ "#{@@pref[tokens.first]} #{tokens[1]}. #{@@months[tokens[2]]}. #{tokens.last}", range ]
    when 3
      if @@months.key? tokens[1]
        if @@pref.key? tokens.first
        # ABT JAN 1970
          date = Date.new(tokens.last.to_i, @@months[tokens[1]], 1)
          range = case tokens.first
          when 'ABT', 'EST'
            DateRange.new(date, date.next_month().prev_day())
          when 'BEF'
            DateRange.new(nil, date.next_month().prev_day())
          when 'AFT'
            DateRange.new(date, nil)
          end
          return [ "#{@@pref[tokens.first]} #{@@months[tokens[1]]}. #{tokens.last}", range ]
        end
        # 1 JAN 1970
        date = Date.new(tokens.last.to_i, @@months[tokens[1]], tokens.first.to_i)
        range = DateRange.new(date, date)
        return [ "#{tokens.first}. #{@@months[tokens[1]]}. #{tokens.last}", range ]
      end
    when 2
      if @@pref.key? tokens.first
        # ABT 1970
        date = Date.new(tokens.last.to_i, 1, 1)
        range = case tokens.first
        when 'ABT', 'EST'
          DateRange.new(date, date.next_year().prev_day())
        when 'BEF'
          DateRange.new(nil, date.next_year().prev_day())
        when 'AFT'
          DateRange.new(date, nil)
        end
        return [ "#{@@pref[tokens.first]} #{tokens.last}", range ]
      elsif @@months.key? tokens.first
        # JAN 1970
        date = Date.new(tokens.last.to_i, @@months[tokens.first], 1)
        range = DateRange.new(date, date.next_month().prev_day())
        return [ "#{@@months[tokens.first]}. #{tokens.last}", range ]
      end
    when 1
      # 1970
      date = Date.new(tokens.last.to_i, 1, 1)
      return [ tokens.first, DateRange.new(date, date.next_year().prev_day()) ]
    end
    [nil, nil]  # not parsable
  end
end

def find_trunk(people, root_ref, central_ref)
  paths = [ [central_ref] ]
  until paths.empty?
    current = paths.pop
    people[current.first].parents.each do |parent_ref|
      extended = current.clone
      extended.unshift parent_ref
      return extended if parent_ref == root_ref
      paths.push extended
    end
  end
  raise 'cannot find trunk'
end
