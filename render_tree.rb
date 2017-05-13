
require 'builder'
require_relative 'person'

RECT_WIDTH = 150
RECT_HEIGHT = 40
MARGIN_X = 20
MARGIN_Y = 10
RECT_STYLE = 'fill:lavender;stroke:black'
RECT_ROUND = 5
TEXT_COLOR = 'black'
TEXT_NAME_SIZE = 13
TEXT_LIFE_SIZE = 9 
TEXT_NAME_Y = RECT_HEIGHT*3/7 
TEXT_LIFE_Y = RECT_HEIGHT*6/7
LINE_STYLE = 'stroke:black;stroke-width:2'

XY = Struct.new(:x, :y)

def compute_size(people, ref)
  person = people[ref]
  raise "ref '#{ref}' not found" if person.nil? 
  person_size = XY.new(RECT_WIDTH + 2 * MARGIN_X + person.spouses.size * (RECT_WIDTH + MARGIN_X), 
                       RECT_HEIGHT + 2 * MARGIN_Y)
  children = person.children 
  return person_size if children.empty?

  children_xy = children.map {|child_ref| compute_size(people, child_ref) }
  ch_x = children_xy.inject(0) {|sum, xy| sum + xy.x } 
  max_xy = children_xy.max {|a, b| a.y <=> b.y }
  XY.new( [person_size.x, ch_x].max, person_size.y + max_xy.y )
end 

def render_person(svg, people, ref, person_size, x=0, y=0)
  person = people[ref]
  raise "ref '#{ref}' not found" if person.nil? 
  spouses = person.spouses
  raise 'num of spouses > 2 not supported' if spouses.size > 2
  shift_x = (spouses.size == 2) ? MARGIN_X+RECT_WIDTH : 0 

  x = RECT_WIDTH/2 + MARGIN_X
  svg.line(x1: x+shift_x, y1: 0, x2: x+shift_x, y2: MARGIN_Y, style: LINE_STYLE)
  svg.g(transform: "translate(#{MARGIN_X+shift_x},#{MARGIN_Y})") {|g| render_rect(g, person) }
  if spouses.size > 0
    svg.g(transform: "translate(#{MARGIN_X*2+RECT_WIDTH+shift_x},#{MARGIN_Y})") {|g| render_rect(g, people[spouses.first]) }
    y = MARGIN_Y+RECT_HEIGHT/2
    svg.line(x1: MARGIN_X+RECT_WIDTH+shift_x, y1: y, x2: 2*MARGIN_X+RECT_WIDTH+shift_x, y2: y, style: LINE_STYLE)
  end
  if spouses.size == 2
    svg.g(transform: "translate(#{shift_x-RECT_WIDTH},#{MARGIN_Y})") {|g| render_rect(g, people[spouses.last]) }
    y = MARGIN_Y+RECT_HEIGHT/2
    svg.line(x1: shift_x, y1: y, x2: MARGIN_X+shift_x, y2: y, style: LINE_STYLE)
  end
end

def render_rect(svg, person, x=0, y=0)
  rounding = (person.sex == :male) ? 0 : RECT_ROUND 
  svg.rect(x: x, y: y, rx: rounding, ry: rounding, width: RECT_WIDTH, height: RECT_HEIGHT, style: RECT_STYLE)
  svg.text(fill: TEXT_COLOR, 'text-anchor': 'middle') do |text|
    text.tspan(person.name, x: RECT_WIDTH/2, y: TEXT_NAME_Y, 'font-size': TEXT_NAME_SIZE)
    text.tspan(person.livespan, x: RECT_WIDTH/2, y: TEXT_LIFE_Y, 'font-size': TEXT_LIFE_SIZE)
  end
end

def render_tree(people, root_ref)
  output = ''
  xml = Builder::XmlMarkup.new(target: output, indent: 2)
  xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'

  root_size = compute_size(people, root_ref)
  xml.svg(xmlns: 'http://www.w3.org/2000/svg', version: '1.1', width: root_size.x, height: root_size.y) do |svg|
    render_person(svg, people, root_ref, root_size)
  end
  output
end

