
class Person
  attr_reader :name, :sex, :birth, :death
  attr_accessor :spouse_refs, :children_refs
  def initialize(name, sex, birth, death)
    @name, @sex, @birth, @death = name, sex, birth, death 
    @spouse_refs, @children_refs = [], []
  end
end

