
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

XY = Struct.new(:x, :y)

def compute_size(people, ref)
  XY.new(RECT_WIDTH+2*MARGIN_X, RECT_HEIGHT+2*MARGIN_Y)
end 

def render_person(svg, people, ref, person_size)
  person = people[ref]
  svg.g(transform: "translate(#{MARGIN_X},#{MARGIN_Y})") {|g| render_rect(g, person) }
end

def render_rect(svg, person)
  rounding = (person.sex == :male) ? 0 : RECT_ROUND 
  svg.rect(x: 0, y: 0, rx: rounding, ry: rounding, width: RECT_WIDTH, height: RECT_HEIGHT, style: RECT_STYLE)
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

