
class Person
  attr_reader :name, :sex, :birth, :death, :families 
  
  def initialize(given, surname, sex, birth, death)
    @name = given.nil? ? '' : given
    @name = surname.nil? ? @name : "#{@name} #{surname}"
    @sex = (sex == 'M') ? :male : :female 
    @birth = Person.parse_date birth
    @death = Person.parse_date death
    @families = {}
  end
  
  def add_family(spouse_ref, children_refs)
    raise 'unknown spouse' if spouse_ref.nil? # TODO
    @families[spouse_ref] = children_refs.clone unless spouse_ref.nil?
  end

  def spouses
    @families.keys
  end

  def children spouse_ref=nil
    spouse_ref.nil? ? @families.values.flatten : @families[spouse_ref]
  end

  def livespan
    if @birth.nil?
      @death.nil? ? '' : "+ #{@death}"
    else  
      @death.nil? ? "* #{@birth}" : "#{@birth} - #{@death}" 
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
      if @@pref.has_key? tokens.first
        return "#{@@pref[tokens.first]} #{@@months[tokens[1]]}. #{tokens.last}"
      else
        return "#{tokens.first}. #{@@months[tokens[1]]}. #{tokens.last}"
      end  
    when 2
      if @@pref.has_key? tokens.first
        return "#{@@pref[tokens.first]} #{tokens.last}"
      else
        return "#{@@months[tokens.first]}. #{tokens.last}"
      end  
    else  
      return tokens.first        
    end
  end
end

