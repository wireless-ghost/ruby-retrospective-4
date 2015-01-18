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
