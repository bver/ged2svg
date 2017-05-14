
require 'builder'
require_relative 'person'

RECT_WIDTH = 150
RECT_HEIGHT = 40
MARGIN_X = 20
MARGIN_Y = 35
RECT_STYLE = 'fill:lavender;stroke:black'
RECT_ROUND = 5
TEXT_COLOR = 'black'
TEXT_NAME_SIZE = 13
TEXT_LIFE_SIZE = 9 
TEXT_NAME_Y = RECT_HEIGHT*3/7 
TEXT_LIFE_Y = RECT_HEIGHT*6/7
CHILD_LINES_DIFF_Y = 10
RESTRICT_DOWN_Y = 10
LINE_STYLE = 'stroke:black;stroke-width:2'

XY = Struct.new(:x, :y)

class Restriction < Struct.new(:trunk, :level, :current_ref, :offset)
  def prune?
    self.level < self.trunk.size and not self.trunk.include? self.current_ref 
  end
  def ancient?
    self.level < self.trunk.size - 1
  end
  def advance(new_ref, offset_x=nil)
    new_offset = offset_x.nil? ? self.offset : offset_x 
    Restriction.new(self.trunk, self.level+1, new_ref, new_offset)
  end
  def is_root?
    self.level == 0
  end
end

def compute_size(people, ref, restriction, shallow=false)
  person = people[ref]
  raise "ref '#{ref}' not found" if person.nil? 
  person_size = XY.new(RECT_WIDTH + 2 * MARGIN_X + person.spouses.size * (RECT_WIDTH + MARGIN_X), 
                       RECT_HEIGHT + 2 * MARGIN_Y)
  children = person.children
  return person_size if children.empty?
  
  children_xy = children.map {|child_ref| compute_size(people, child_ref, restriction.advance(child_ref), restriction.ancient?) }
  ch_x = children_xy.inject(0) {|sum, xy| sum + xy.x }
  max_x = children_xy.max {|a, b| a.x <=> b.x }
  max_y = children_xy.max {|a, b| a.y <=> b.y } 
  shallow ? XY.new( [person_size.x, max_x.x].max, person_size.y + max_y.y ) : XY.new( [person_size.x, ch_x].max, person_size.y + max_y.y )
end 

def render_children(svg, people, children, down_x, child_y, restriction, offset_x=0)
    return offset_x if children.empty?
    # center a single child ... make sure it does not cause colisions with other spouse's children
    offset_x = [offset_x, down_x-RECT_WIDTH/2-MARGIN_X].max if children.size == 1 and people[children.first].children.empty?
    down_y = RECT_HEIGHT/2 + MARGIN_Y 
    svg.line(x1: down_x, y1: down_y, x2: down_x, y2: (restriction.prune? ? (down_y + RESTRICT_DOWN_Y) : child_y), style: LINE_STYLE)

    return offset_x if restriction.prune? 

    connect_points = [ down_x ]
    children.each do |child_ref| 
        xy = compute_size(people, child_ref, restriction, restriction.ancient?)
        reset_offset = offset_x
        reset_offset -= restriction.offset if restriction.ancient?
        svg.g(transform: "translate(#{reset_offset},#{child_y})") {|g| render_person(g, people, child_ref, xy, restriction.advance(child_ref, offset_x)) }
        mid_point = (people[child_ref].spouses.size == 1) ? (xy.x - RECT_WIDTH - MARGIN_X)/2 : xy.x/2
        connect_points << (reset_offset + mid_point)
        offset_x += xy.x
    end
    svg.line(x1: connect_points.min, y1: child_y, x2: connect_points.max, y2: child_y, style: LINE_STYLE)
    offset_x
end

def render_person(svg, people, ref, xy, restriction)
  person = people[ref]
  raise "ref '#{ref}' not found" if person.nil? 

  middle_x = xy.x/2
  marriage_y = RECT_HEIGHT/2 + MARGIN_Y
  child_y = RECT_HEIGHT + 2*MARGIN_Y

  spouses = person.spouses
  case spouses.size
  when 0
    svg.line(x1: middle_x, y1: 0, x2: middle_x, y2: MARGIN_Y, style: LINE_STYLE) unless restriction.is_root? 
    svg.g(transform: "translate(#{(xy.x-RECT_WIDTH)/2},#{MARGIN_Y})") {|g| render_rect(g, person) }
  when 1
    connect_x = (xy.x - RECT_WIDTH - MARGIN_X) / 2
    svg.line(x1: connect_x, y1: 0, x2: connect_x, y2: MARGIN_Y, style: LINE_STYLE) unless restriction.is_root? 
    svg.g(transform: "translate(#{connect_x-RECT_WIDTH/2},#{MARGIN_Y})") {|g| render_rect(g, person) }

    svg.g(transform: "translate(#{(xy.x+MARGIN_X)/2},#{MARGIN_Y})") {|g| render_rect(g, people[spouses.first]) }
    svg.line(x1: (xy.x-MARGIN_X)/2, y1: marriage_y, x2: (xy.x+MARGIN_X)/2, y2: marriage_y, style: LINE_STYLE)

    render_children(svg, people, person.children(spouses.first), middle_x, child_y, restriction)
  when 2
    svg.line(x1: middle_x, y1: 0, x2: middle_x, y2: MARGIN_Y, style: LINE_STYLE) unless restriction.is_root? 
    svg.g(transform: "translate(#{(xy.x-RECT_WIDTH)/2},#{MARGIN_Y})") {|g| render_rect(g, person) }

    svg.g(transform: "translate(#{middle_x-MARGIN_X-1.5*RECT_WIDTH},#{MARGIN_Y})") {|g| render_rect(g, people[spouses.first]) }
    svg.line(x1: middle_x-RECT_WIDTH/2-MARGIN_X, y1: marriage_y, x2: middle_x-RECT_WIDTH/2, y2: marriage_y, style: LINE_STYLE)

    svg.g(transform: "translate(#{middle_x+MARGIN_X+RECT_WIDTH/2},#{MARGIN_Y})") {|g| render_rect(g, people[spouses.last]) }
    svg.line(x1: middle_x+RECT_WIDTH/2, y1: marriage_y, x2: middle_x+RECT_WIDTH/2+MARGIN_X, y2: marriage_y, style: LINE_STYLE)

    offset_x = render_children(svg, people, person.children(spouses.first), (xy.x-RECT_WIDTH-MARGIN_X)/2, child_y, restriction)
    render_children(svg, people, person.children(spouses.last), (xy.x+RECT_WIDTH+MARGIN_X)/2, child_y-CHILD_LINES_DIFF_Y, restriction, offset_x)
  else
   'num of spouses > 2 not supported'    
  end
end

def render_rect(svg, person)
  rounding = (person.sex == :male) ? 0 : RECT_ROUND 
  svg.rect(x: 0, y: 0, rx: rounding, ry: rounding, width: RECT_WIDTH, height: RECT_HEIGHT, style: RECT_STYLE)
  svg.text(fill: TEXT_COLOR, 'text-anchor': 'middle') do |text|
    text.tspan(person.name, x: RECT_WIDTH/2, y: TEXT_NAME_Y, 'font-size': TEXT_NAME_SIZE)
    text.tspan(person.lifespan, x: RECT_WIDTH/2, y: TEXT_LIFE_Y, 'font-size': TEXT_LIFE_SIZE)
  end
end

def render_tree(people, root_ref, trunk=[])
  output = ''
  xml = Builder::XmlMarkup.new(target: output, indent: 2)
  xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'

  restriction = Restriction.new(trunk, 0, root_ref, 0)
  root_size = compute_size(people, root_ref, restriction)
  xml.svg(xmlns: 'http://www.w3.org/2000/svg', version: '1.1', width: root_size.x, height: root_size.y) do |svg|
    render_person(svg, people, root_ref, root_size, restriction)
  end
  output
end

