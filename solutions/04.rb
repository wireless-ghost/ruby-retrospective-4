# Here is my code, but it fails some of the tests.
# My goal was to do it, using class_eval for all 
# of the components but failed.
# From line 116 is the working solution that is
# from the gihub repo for the homeworks.

=begin
module UI
  class TextScreen

    @text = []
    @border = ""
    @is_vertical = 0
    @tex = ""

    def self.draw &block
      @text = []
      @tex = ""
      @is_vertical = 0
      @max_length = 0
      @border = ""
      @nesting = -1
      @vertical_counter = 0

      class_eval(&block)
    end

    def self.vertical hash = nil, &block
      if (hash && hash[:border])
        @border = hash[:border]
        @max_length = 0
      end
      @is_vertical = 1
      before_nesting = @tex.lines.last
      if before_nesting
        @nesting += before_nesting.length - 1
      else
        @nesting += 1
      end
      @vertical_counter = 0
      result = class_eval(&block)
      if before_nesting
        @nesting -= before_nesting.length - 1
      else
        @nesting -= 1
      end
      result
    end

    def self.horizontal hash = nil, &block
      if hash && hash[:border]
        @border = hash[:border]
        @max_length = 0
      end
      @is_vertical = 0
      result = class_eval(&block)
      result
    end

    def self.update_text
      count = 0
      if @tex && @tex.length > 0
        count = @tex.lines.last.chomp.length - 2
      end
      if count > 0 && @nesting > 0
        @tex += " " * count
      end
    end

    def self.label text
      if @vertical_counter == 1
        update_text
      end
      @vertical_counter += 1
      if text[:text]
        @text << text[:text]
      end
      if text[:border]
        @border = text[:border]
      end
      if text[:style]
        case text[:style].to_sym
        when :upcase   then @text.map!(&:upcase)
        when :downcase then @text.map!(&:downcase)
        end
      end
      to_s
    end

    def self.length
      @text.each do |x|
        if x.length > @max_length
          @max_length = x.length
        end
      end
      @max_length
    end

    def self.to_s
      @tex += "" + (@is_vertical == 1 ? "" : @border)
      @text.each do |x|
        if @is_vertical == 1
          @tex += (@border + x).ljust(self.length + 1) + @border + "\n"
        else
          @tex += x
        end
      end
      @text = []
      @tex += (@is_vertical == 1 ? "" : @border)
      @tex
    end
  end
end
=end

module UI
  class Component
    attr_writer :styler

    def initialize(parent)
      @parent = parent
      @styler = -> text { text }
    end

    def stylize(text)
      text = @parent.stylize(text) if @parent
      @styler.call text
    end
  end

  class Label < Component
    def initialize(parent, text)
      super(parent)
      @text = text
    end

    def width
      @text.size
    end

    def height
      1
    end

    def row_to_string(row)
      stylize @text
    end
  end

  class BorderDecorator
    def initialize(component, border)
      @component = component
      @border = border
    end

    def width
      @component.width + 2 * @border.length
    end

    def height
      @component.height
    end

    def stylize(text)
      @component.stylize text
    end

    def row_to_string(row)
      component_string = @component.row_to_string(row)
      "#{@border}#{component_string.ljust(@component.width)}#{@border}"
    end
  end

  class Container < Component
    attr_reader :components

    def initialize(parent = nil, &block)
      super(parent)
      @components = []
      instance_eval(&block)
    end

    def vertical(border: nil, style: nil, &block)
      add decorate(VerticalGroup.new(self, &block), border, style)
    end

    def horizontal(border: nil, style: nil, &block)
      add decorate(HorizontalGroup.new(self, &block), border, style)
    end

    def label(text:, border: nil, style: nil)
      add decorate(Label.new(self, text), border, style)
    end

    private

    def add(component)
      @components << component
    end

    def decorate(component, border, style)
      component.styler = :downcase.to_proc if style == :downcase
      component.styler = :upcase.to_proc   if style == :upcase
      component = BorderDecorator.new(component, border) if border
      component
    end
  end

  class VerticalGroup < Container
    def width
      @components.map(&:width).max
    end

    def height
      @components.map(&:height).reduce(:+)
    end

    def row_to_string(row)
      components_reaches = @components.map.with_index do |component, index|
        [component, @components.first(index + 1).map(&:height).reduce(:+)]
      end.select { |_, component_reach| row < component_reach }
      component, component_reach = components_reaches.first
      component.row_to_string(row - component_reach + component.height)
    end
  end

  class HorizontalGroup < Container
    def width
      @components.map(&:width).reduce(:+)
    end

    def height
      @components.map(&:height).max
    end

    def row_to_string(row)
      @components.map { |component| component_to_s component, row }.join
    end

    private

    def component_to_s(component, row)
      if component.height > row
        component.row_to_string row
      else
        " " * component.width
      end
    end
  end

  class TextScreen < HorizontalGroup
    def self.draw(&block)
      new(&block)
    end

    def to_s
      (0...height).map { |row| "#{row_to_string(row)}\n" }.join
    end
  end
end
