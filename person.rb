
class Person
  attr_reader :name, :sex, :birth, :death, :families, :parents 
  
  def initialize(given, surname, sex, birth, death)
    @name = given.nil? ? '' : given
    @name = surname.nil? ? @name : "#{@name} #{surname}"
    @sex = (sex == 'M') ? :male : :female 
    @birth = Person.parse_date birth
    @death = Person.parse_date death
    @families = {}
    @parents = []
  end
  
  def add_parent parent_ref
    @parents << parent_ref unless parent_ref.nil?
  end

  def add_family(spouse_ref, children_refs)
    raise 'unknown spouse' if spouse_ref.nil?
    @families[spouse_ref] = children_refs.clone unless spouse_ref.nil?
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
    return nil if date.nil?
    tokens = date.split /\s+/
    case tokens.size
    when 4
      return "#{@@pref[tokens.first]} #{tokens[1]}. #{@@months[tokens[2]]}. #{tokens.last}"
    when 3
      return "#{@@pref[tokens.first]} #{@@months[tokens[1]]}. #{tokens.last}" if @@pref.has_key? tokens.first and @@months.has_key? tokens[1]
      return "#{tokens.first}. #{@@months[tokens[1]]}. #{tokens.last}" if @@months.has_key? tokens[1]
    when 2
      return "#{@@pref[tokens.first]} #{tokens.last}" if @@pref.has_key? tokens.first
      return "#{@@months[tokens.first]}. #{tokens.last}" if @@months.has_key? tokens.first
    else  
      return tokens.first        
    end
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

